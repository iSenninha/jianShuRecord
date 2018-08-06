### Executor in netty
JDK自带了Executor全家桶，但是netty自己继承了AbstractExecutorService自己实现了Executor，两者之间有什么区别呢

#### 1.AbstractScheduleedEventExecutor
**AbstractScheduleedEventExecutor**实现了JDK的**AbstractExecutorService**这个接口
对比一下JDK和Netty实现的最大不同就是，netty使用了**PiorityQueue**作为工作队列，而JDK是使用了**BlockingQueue**作为工作队列。
更奇怪的是，**PiorityQueue**是一个线程不安全的队列，**AbstractEventExecutor**里也没有对其进行并发处理。看一下对应的提交定时任务的代码可以明白其中的奥秘：
```
    <V> ScheduledFuture<V> schedule(final ScheduledFutureTask<V> task) {
        if (inEventLoop()) {
            scheduledTaskQueue().add(task);
        } else {
            execute(new Runnable() {
                @Override
                public void run() {
                    scheduledTaskQueue().add(task);
                }
            });
        }

        return task;
    }
```
inEventLoop实现:
```
    @Override
    public boolean inEventLoop() {
        return inEventLoop(Thread.currentThread());
    }

   /**
     * Return {@code true} if the given {@link Thread} is executed in the event loop,
     * {@code false} otherwise.
     */
    boolean inEventLoop(Thread thread);

```
顾名思义，**inEventLoop**就是判断调用者是否与**Executor**是否是同一个线程。
如果是同一个线程，直接加入任务队列（不存在并发）。
如果不是同一个线程，加入另外一个队列等待执行。
这里也体现了Netty的**EventLoop**的设计思想。
下面将分析异步**execute()**是如何实现的。

#### 2.execute()是如何实现的？
**execute()**方法并没有在**AbstractScheduledEventExecutor**中实现，直接挑一个**GlobalEventExecutor**看一下是如何实现的：
**GlobalEventExecutor**也有一样任务队列，这是一个**LinkedBlockingQueue**，熟悉的配方，和JDK殊途同归了
```
    @Override
    public void execute(Runnable task) {
        if (task == null) {
            throw new NullPointerException("task");
        }

        addTask(task);
        if (!inEventLoop()) {
            startThread();
        }
    }
```
以上处理非常简单，加入一个**BlockingQueue**，然后**startThread()**是启动消费线程。

```
    private void startThread() {
        if (started.compareAndSet(false, true)) {
            Thread t = threadFactory.newThread(taskRunner);
            // Set the thread before starting it as otherwise inEventLoop() may return false and so produce
            // an assert error.
            // See https://github.com/netty/netty/issues/4357
            thread = t;
            t.start();
        }
    }
```
重点来看一下**taskRunner**:
```
    final class TaskRunner implements Runnable {
        @Override
        public void run() {
            for (;;) {
                Runnable task = takeTask();
                if (task != null) {
                    try {
                        task.run();
                    } catch (Throwable t) {
                        logger.warn("Unexpected exception from the global event executor: ", t);
                    }

                    if (task != quietPeriodTask) {
                        continue;
                    }
                }
		// 省去无关的代码
        }
    }

```

takeTask():

```
    Runnable takeTask() {
        BlockingQueue<Runnable> taskQueue = this.taskQueue;
        for (;;) {
            ScheduledFutureTask<?> scheduledTask = peekScheduledTask();
            if (scheduledTask == null) {	// 1
                Runnable task = null;
                try {
                    task = taskQueue.take();
                } catch (InterruptedException e) {
                    // Ignore
                }
                return task;
            } else {				//2
                long delayNanos = scheduledTask.delayNanos();
                Runnable task;
                if (delayNanos > 0) {
                    try {
                        task = taskQueue.poll(delayNanos, TimeUnit.NANOSECONDS);
                    } catch (InterruptedException e) {
                        // Waken up.
                        return null;
                    }
                } else {
                    task = taskQueue.poll();
                }

                if (task == null) {
                    fetchFromScheduledTaskQueue();
                    task = taskQueue.poll();
                }

                if (task != null) {
                    return task;
                }
            }
        }
    }`
	
```
1.从**PiorityQueue**队列里取任务执行,这里执行的才是正经的任务队列;
2.如果1没有任务，从**BlockingQueue**取任务执行，这里其实就是把**BlockingQueue**的任务挪动到**PiorityQueue**里去，由于是同一个线程，自然不存在兵法问题。使用**BlockingQueue**作为中转，实现了无锁**PiorityQueue**

顺便再看一下GlobalEventExecutor里inEventLoop的实现()
```
    @Override
    public boolean inEventLoop(Thread thread) {
        return thread == this.thread;
    }
```
这里的**this.thread**就是工作线程


#### 3.总结
Netty的Executor通过两个队列的实现，不同于JDK，达到了**PiorityQueue**队列不加锁工作的目的。为什么要这么设计呢？？
在JDK的实现中,工作队列只有一个，这就意味着当出入队**siftUp**的时候，会上锁，在高并发的情况下，可能出现大量调用者线程挂起在**PiorityQueue**调整的过程。
而Netty的实现，调用者线程只会lock在简单的**LinkedBlockingQueue**上，然后就返回，高并发的情况下，也不会出现调用者大量的挂起，顶多只是在执行的过程中延迟很大，这个时候就应该考虑扩容线程数量了。
