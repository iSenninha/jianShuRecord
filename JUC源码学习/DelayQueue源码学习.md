###DelayQueue源码学习

> DelayQueue是一个提供过期时间的队列，只返回消耗完等待时间的元素，暂时还没发现应用场景。。。。
DelayQueue实现了[BlockingQueue](http://www.jianshu.com/p/716bddf05bd0)接口，所以是支持阻塞操作的


<br>

- 首先想要入队的元素必须实现Delayed接口，先来看Delayed接口:
```
//继承了Comparable接口
public interface Delayed extends Comparable<Delayed> {

    /**
     * Returns the remaining delay associated with this object, in the
     * given time unit.
     *
     * @param unit the time unit
     * @return the remaining delay; zero or negative values indicate
     * that the delay has already elapsed
     *返回小于等于0表示延迟到期了
     */
    long getDelay(TimeUnit unit);
}
```
下面是一个实现了Delayed接口的类：

```
class DelayBean implements Delayed{
	private long time;
	
	

	@Override
	public int compareTo(Delayed o) {
		// 大于返回1，小于返回-1,等于返回0
		return this.getDelay(TimeUnit.NANOSECONDS) > o.getDelay(TimeUnit.NANOSECONDS) ? 1 : 
			(this.getDelay(TimeUnit.NANOSECONDS) < o.getDelay(TimeUnit.NANOSECONDS) ? -1 : 0);
	}

	//返回成员变量的时间和当前时间的差
	@Override
	public long getDelay(TimeUnit unit) {
		// TODO Auto-generated method stub
		return unit.convert(time - System.nanoTime(), TimeUnit.NANOSECONDS);
	}

	public long getTime() {
		return time;
	}

	public void setTime(int time) {
		this.time = time;
	}
	
}

```
---
- 接下来看一下DelayQueue的成员变量：
```
    //重入锁
    private final transient ReentrantLock lock = new ReentrantLock();
    //聚合了一个优先级队列来实现保存元素
    private final PriorityQueue<E> q = new PriorityQueue<E>();
    //用于减少定时等待，优化性能，Leader-Follower模式见，见(这里)[http://www.cs.wustl.edu/~schmidt/POSA/POSA2/]
    private Thread leader = null;
    
    private final Condition available = lock.newCondition();
```
ps:有关[PriorityQueue见这里](http://www.jianshu.com/p/938f8114421a)，由于是聚合了一个PriorityQueue来保存优先级队列，所以DelayQueue类的主要精力是放在如何去实现这个延时的功能的

---

- 入队系列方法
> 由于聚合的PriorityQueue是一个基于数组实现的无界队列，所以这里的offer, put方法都不会阻塞，调用这些方法最终都是到这个方法：

```
 public boolean offer(E e) {
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            q.offer(e);
            //这里对leader的操作有点迷，先看完下面的take(),poll()方法再回来看
            if (q.peek() == e) {
                leader = null;
                available.signal();
            }
            //看完了take()，和poll()方法，回来继续看这个，如果leader处于非null的情况
            //说明那个当前这个leader指向的线程是可以在结束休眠的时候获取到超时结束的元素的
            //先假设为offer以前堆顶元素已经被某个线程预定了可以在结束超时出队
            //这个时候新加的元素直接到了堆顶，说明这个时候队列里出现了两个满足超时等待
            //的元素可以出队列，这个时候把leader置为null，等于告诉后来者的线程
            //你也可以把自己置为leader，预定下一个出队的元素
            return true;
        } finally {
            lock.unlock();
        }
    }
```
---
- poll()方法
```
/**
*发现一个有趣的地方，获取锁后直接从PrirorityQueue(下称pq)里去检索队头的元素
*然后去看他是否满足条件，不满足直接返回null，反之才正从pq里poll出来
*这个条件就是延迟等待是否到达的条件
**/
public E poll() {
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            E first = q.peek();
            if (first == null || first.getDelay(NANOSECONDS) > 0)
                return null;
            else
                return q.poll();
        } finally {
            lock.unlock();
        }
    }
```


---
- 阻塞等待的take()方法
```
 public E take() throws InterruptedException {
        final ReentrantLock lock = this.lock;
        lock.lockInterruptibly();
        try {
            for (;;) {
                E first = q.peek();
                if (first == null)
                    available.await();
                else {
                    long delay = first.getDelay(NANOSECONDS);
                    if (delay <= 0)
                        return q.poll();
                    first = null; // don't retain ref while waiting
                    /**
                    *这里体现了leader的妙用，如果leader不为null，说明有其他线程在等待着出队
                    *直接调用await()，而不是awaitNanos();
                    **/
                    if (leader != null)
                        available.await();
                    else {
                        //如果没有线程在等待获取，调用awaitNanos()等待过期时间后就退出等待，再次循环尝试获取
                        //await()和awaitNanos()结合使用，提高性能
                        Thread thisThread = Thread.currentThread();
                        leader = thisThread;
                        try {
                            available.awaitNanos(delay);
                        } finally {
                            if (leader == thisThread)
                                leader = null;
                        }
                    }
                }
            }
        } finally {
            if (leader == null && q.peek() != null)//最后如果peek()不为null，唤醒其他等待的线程
                available.signal();
            lock.unlock();
        }
    }
```


---

- 超时等待的poll(TimeUnit timeUnit, long timeout)方法：
```
 public E poll(long timeout, TimeUnit unit) throws InterruptedException {
        long nanos = unit.toNanos(timeout);
        final ReentrantLock lock = this.lock;
        lock.lockInterruptibly();
        try {
            for (;;) {
                E first = q.peek();
                if (first == null) {
                    if (nanos <= 0)
                        return null;
                    else
                        nanos = available.awaitNanos(nanos);
                } else {
                    long delay = first.getDelay(NANOSECONDS);
                    if (delay <= 0)
                        return q.poll();
                    if (nanos <= 0)
                        return null;
                    first = null; // don't retain ref while waiting
                    
                    /**
                    *两段注释之间的代码解释了成员变量Thread leader的作用
                    *这里的leader作用和take的方法有点不同
                    **/
                    if (nanos < delay || leader != null)
			//这里是nanos < delay 说明等待时间短于最快过期的那个元素，
			//如果没有新元素入队的话，这次poll是一定返回null的，
			//所以让当前线程等待该等待的时间

			//leader != null，说明有其他线程在等待获取元素，就是当前这个满足条件的
			//元素已经被其他线程预定了，你是拿不到的，该干嘛干嘛去，等待该等待的时间就行
                        nanos = available.awaitNanos(nanos);
                    else {
                        Thread thisThread = Thread.currentThread();
                        leader = thisThread;
                        try {
                            //如果nanos > delay 表示等待delay的时间是有可能获取到出队元素
                            //并且把当前线程置为leader，等于告诉其他线程，这个出队名额已经被我预定了
                            long timeLeft = available.awaitNanos(delay);
                            nanos -= delay - timeLeft;
                        } finally {
                            //结束一次等待后把leader置为null
                            if (leader == thisThread)
                                leader = null;
                        }
                    }
                    /**
                    *这个时候再回去看看offer里对leader的相关代码的含义
                    **/
                }
            }
        } finally {
            if (leader == null && q.peek() != null)
                available.signal();
            lock.unlock();
        }
    }
```
> 所以在poll()方法里leader的作用是让一些无法获取出队超时元素的线程等待该等待的时间然后返回null，让可以获取到出队超时出队元素的线程更好地获取到出队元素。
