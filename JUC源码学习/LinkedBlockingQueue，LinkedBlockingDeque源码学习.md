###LinkedBolckingQueue源码学习
> LinkedBolckingQueue是JUC包下基于链表实现的队列，队列最大容量是int的最大正值，实现了BlockingQueue接口，可以阻塞入队出队，可以用于工作队列，Executors.newFixedThreaadPool就是用此队列作为工作队列的

&nbsp;

- 首先是静态内部类节点Node
```
static class Node<E> {
        E item;

        /**
         * One of:
         * - the real successor Node
         * - this Node, meaning the successor is head.next
         * - null, meaning there is no successor (this is the last node)
         */
        Node<E> next;

        Node(E x) { item = x; }
    }
```
由此看出这是一个单向链表，只持有下一个节点打引用和当前节点保存的元素E

&nbsp;

- 成员变量
```
int capacity //容量
AtomicInteger count //当前元素数量
Node<E> head //指向头节点
Node<E> last //指向尾节点
ReentrantLock takeLock //出对锁
Condition notEmpty = takeLock.newCondition() //由入队锁的Condition
ReentrantLock putLock //入队锁
Condition notFull = putLock.newCondition()//由出队锁打Condtion
```
<br>
- 构造方法
```
    public LinkedBlockingQueue(int capacity) {
        if (capacity <= 0) throw new IllegalArgumentException();
        this.capacity = capacity;
        last = head = new Node<E>(null);
    }
```
构造方法没有什么好说打，如果不传参的话，默认是用int打最大值作为队列最大容量
并且把成员变量last=head设置为null。

&nbsp;

- 入队系列方法

> 首先看一下如何加入队列打头部打私有方法，这个方法将被入队的方法调用

```
private void enqueue(Node<E> node) {
        // assert putLock.isHeldByCurrentThread();
        // assert last.next == null;
        last = last.next = node;
    }
```
非常简单。。因为容量检查，并发检查都被调用它的方法处理啦
 
#####1.带阻塞时间打offer方法
```
    public boolean offer(E e, long timeout, TimeUnit unit)
        throws InterruptedException {
	//不可以入队null
        if (e == null) throw new NullPointerException();
        long nanos = unit.toNanos(timeout);//转换时间单位Condition.awaitNanos()
        int c = -1;
        //入队锁
        final ReentrantLock putLock = this.putLock;
        //获取当前的队列长度
        final AtomicInteger count = this.count;
        //尝试获取可中断的锁
        putLock.lockInterruptibly();
        try {
           //队列满的情况下，进入这个循环
            while (count.get() == capacity) {
               //等待时间已过，返回入队失败
                if (nanos <= 0)
                    return false;
                //否则休眠
                nanos = notFull.awaitNanos(nanos);
            }
            //获取锁并且队列未满，入队
            enqueue(new Node<E>(e));
            //原子增加
            c = count.getAndIncrement();
            //如果发现队列未满，唤醒其他在队列满打状态等待打线程
            if (c + 1 < capacity)
                notFull.signal();
        } finally {
            putLock.unlock();
        }
        //如果c=0,说吗在当前元素入队前队列为空，
        //可能由其他线程在等待出队元素，唤醒
        if (c == 0)
            signalNotEmpty();
        return true;
    }
```
无阻塞参数的offer方法更加简单，就不写啦，当成timeout为0的用就是了

#####2.put方法
```
public void put(E e) throws InterruptedException {
        if (e == null) throw new NullPointerException();
        // Note: convention in all put/take/etc is to preset local var
        // holding count negative to indicate failure unless set.
        int c = -1;
        Node<E> node = new Node<E>(e);
        final ReentrantLock putLock = this.putLock;
        final AtomicInteger count = this.count;
        putLock.lockInterruptibly();
        try {
            /*
             * Note that count is used in wait guard even though it is
             * not protected by lock. This works because count can
             * only decrease at this point (all other puts are shut
             * out by lock), and we (or some other waiting put) are
             * signalled if it ever changes from capacity. Similarly
             * for all other uses of count in other wait guards.
             */
            while (count.get() == capacity) {
                notFull.await();
            }
            enqueue(node);
            c = count.getAndIncrement();
            if (c + 1 < capacity)
                notFull.signal();
        } finally {
            putLock.unlock();
        }
        if (c == 0)
            signalNotEmpty();
    }

```
没啥好写的，傻等的主。。。

&nbsp;

- 出队系列方法
> 老规矩，先看删除节点的dequeue方法

```
    private E dequeue() {
        // assert takeLock.isHeldByCurrentThread();
        // assert head.item == null;//头节点的元素是空的
        Node<E> h = head;
        Node<E> first = h.next;
        h.next = h; // help GC
        head = first;
        E x = first.item;
        first.item = null;
        return x;
    }
```
操作有点复杂，首先要了解一个概念，头节点是一直是空的，这样做是为了方便统一简化在队列未空时打出队入队操作
明白了这一点，以上方法打逻辑是移除当前打头节点，把接下的那个不为空的节点打item弹出，然后item置为null，把它设置未头节点。
这个过程需要注意把弹出的头节点的next设置为自身，帮助gc

#####1.带阻塞参数的poll方法
```
  public E poll(long timeout, TimeUnit unit) throws InterruptedException {
        E x = null;
        int c = -1;
        long nanos = unit.toNanos(timeout);
        final AtomicInteger count = this.count;
        //出队锁
        final ReentrantLock takeLock = this.takeLock;
        takeLock.lockInterruptibly();
        try {
            while (count.get() == 0) {
                if (nanos <= 0)
                    return null;
                //未超时的话一直等待
                nanos = notEmpty.awaitNanos(nanos);
            }
            //出队
            x = dequeue();
            c = count.getAndDecrement();
            if (c > 1)
                notEmpty.signal();
        } finally {
            takeLock.unlock();
        }
        if (c == capacity)
            signalNotFull();
        return x;
    }
```
不带阻塞参数打poll方法更简单，队列为空就直接返回null

#####2.take方法
```
//无法出队就傻等
public E take() throws InterruptedException {
        E x;
        int c = -1;
        final AtomicInteger count = this.count;
        final ReentrantLock takeLock = this.takeLock;
        takeLock.lockInterruptibly();
        try {
            while (count.get() == 0) {
                notEmpty.await();
            }
            x = dequeue();
            c = count.getAndDecrement();
            if (c > 1)
                notEmpty.signal();
        } finally {
            takeLock.unlock();
        }
        if (c == capacity)
            signalNotFull();
        return x;
    }
```

&nbsp;

- remove方法
```
 public boolean remove(Object o) {
        if (o == null) return false;
        //全局锁定，就是入队出队一起锁定
        fullyLock();
        try {
        //循环遍历
            for (Node<E> trail = head, p = trail.next;
                 p != null;
                 trail = p, p = p.next) {
                if (o.equals(p.item)) {
                    //下面看看unlink方法
                    unlink(p, trail);
                    return true;
                }
            }
            return false;
        } finally {
            fullyUnlock();
        }
    }
    
        //p是要删除打那个节点，而trail是前一个节点
        void unlink(Node<E> p, Node<E> trail) {
        // assert isFullyLocked();
        // p.next is not changed, to allow iterators that are
        // traversing p to maintain their weak-consistency guarantee.
        p.item = null;
        //把trail打next指向p的next
        trail.next = p.next;
        if (last == p)
            last = trail;
        if (count.getAndDecrement() == capacity)
            notFull.signal();
    }
    //上面说的那个头节点之所以要保持未空就是为了删除方便
```

&nbsp;

- 其他方法
#####1.toArray
全局锁定，转换为数组返回

#####2.Iterator
```

 	private Node<E> current;
        private Node<E> lastRet;
        private E currentElement;

public boolean hasNext() {
            return current != null;
        }



 public E next() {
            fullyLock();
            try {
                if (current == null)
                    throw new NoSuchElementException();
                E x = currentElement;
                lastRet = current;
                current = nextNode(current);
                /写入下一次next时候打element值
                currentElement = (current == null) ? null : current.item;
                return x;
            } finally {
                fullyUnlock();
            }
        }
        
/**
*即使调用它的next()方法全局锁定了，但是还可能会出现p节点已经出队的情况
*这个时候直接从事实上的head节点从头开始遍历
**/
private Node<E> nextNode(Node<E> p) {
            for (;;) {
                Node<E> s = p.next;
                if (s == p)
                    return head.next;
                if (s == null || s.item != null)
                    return s;
                p = s;
            }
        }

```

&nbsp;

---
再来看看LinkedBlockingDeque：
> 双端队列，可以在队列头和尾执行插入，既是一个队列，也是一个栈，具体打代码细节和LinkedBlockingQueue相似，只是这个是可以在双向入队的队列。
