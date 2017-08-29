### JDK线程池实现

- 先来看线程工厂

> 缺省线程工厂，来自JUC.Executors

```
static class DefaultThreadFactory implements ThreadFactory {
        private static final AtomicInteger poolNumber = new AtomicInteger(1);
        private final ThreadGroup group;
        private final AtomicInteger threadNumber = new AtomicInteger(1);
        private final String namePrefix;

        DefaultThreadFactory() {
            SecurityManager s = System.getSecurityManager();
            group = (s != null) ? s.getThreadGroup() :
                                  Thread.currentThread().getThreadGroup();
            namePrefix = "pool-" +
                          poolNumber.getAndIncrement() +
                         "-thread-";
        }

		/**
		*给线程命名，给设置是否守护线程，设置优先级
		**/
        public Thread newThread(Runnable r) {
            Thread t = new Thread(group, r,
                                  namePrefix + threadNumber.getAndIncrement(),
                                  0);
            if (t.isDaemon())
                t.setDaemon(false);
            if (t.getPriority() != Thread.NORM_PRIORITY)
                t.setPriority(Thread.NORM_PRIORITY);
            return t;
        }
    }

```

> 代码非常简单。



- 再来看ExecutorService接口

> 这是线程执行器(理解成线程池也行)接口，包含了**execute,shutdown**等接口。



- 线程执行器的实现类---ThreadPoolExecutor

  1. 成员变量

     > HashSet<Worker> workers //工作线程
     >
     > ReentrantLock mainLock;//访问工作set的时候使用，用于中断，shutdown??
     >
     > BlockingQueue<Runnable> workQueue //任务，一个阻塞队列，具体使用哪一个队列由构造方法提供
     >
     > volatile ThreadFactory threadFactory; //线程工程，构造方法指定
     >
     > volatile RejectedExecutionHandler handler //拒绝策略，构造方法提供
     >
     > volatile int corePoolSize; //核心线程的数量
     > volatile int maximumPoolSize; //最大线程的数量
     >
     > ​
     >
     > **ctl**重要的控制状态（control state）
     >
     > **低29**位储存线程数量
     >
     > **高三位**储存线程池状态：111-runbale(是负数,在几种状态中是最小的)，000-shutdown，001-stop(拒绝接受新任务，并取消队列和中断任务)，010-tiding（清理阶段，调用钩子方法），011-terminated（完全停下来）
     >
     > private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0))

  2. 重要内部类**Worker**

     > Worker继承了AQS，并且自己实现了一个独占锁。。。

     ```
         private final class Worker
             extends AbstractQueuedSynchronizer
             implements Runnable
         {
             Worker(Runnable firstTask) {
                 setState(-1); // inhibit interrupts until runWorker
                 this.firstTask = firstTask;
                 this.thread = getThreadFactory().newThread(this);
             }

             public void run() {
                 runWorker(this);
             }

             // Lock methods
             //
             // The value 0 represents the unlocked state.
             // The value 1 represents the locked state.

             protected boolean isHeldExclusively() {
                 return getState() != 0;
             }

             protected boolean tryAcquire(int unused) {
                 if (compareAndSetState(0, 1)) {
                     setExclusiveOwnerThread(Thread.currentThread());
                     return true;
                 }
                 return false;
             }

             protected boolean tryRelease(int unused) {
                 setExclusiveOwnerThread(null);
                 setState(0);
                 return true;
             }

             public void lock()        { acquire(1); }
             public boolean tryLock()  { return tryAcquire(1); }
             public void unlock()      { release(1); }
             public boolean isLocked() { return isHeldExclusively(); }

             void interruptIfStarted() {
                 Thread t;
                 if (getState() >= 0 && (t = thread) != null && !t.isInterrupted()) {
                     try {
                         t.interrupt();
                     } catch (SecurityException ignore) {
                     }
                 }
             }
         }
     ```

  3. 构造方法

     ```
         public ThreadPoolExecutor(int corePoolSize,
                                   int maximumPoolSize,
                                   long keepAliveTime,
                                   TimeUnit unit,
                                   BlockingQueue<Runnable> workQueue) {
             this(corePoolSize, maximumPoolSize, keepAliveTime, unit, workQueue,
                  Executors.defaultThreadFactory(), defaultHandler);
         }
         //指定核心线程数量，最大的线程数目，保持活跃时间，任务队列
     ```

  4. execute方法

     > 1. 如果当前线程数**少于corePoolSize**，新开一个线程并把当前提交的任务作为新线程的任务，这个操作会检查ctl;
     > 2. 如果成功进入**任务队列**，依然会第二次检查线程是否足够或者是否**shutdown**;
     > 3. 如果入队失败，继续新增**线程**到**Max**，如果新增线程失败，说明shutdown了或者饱和了，执行拒绝策略。

     ```
      public void execute(Runnable command) {
             if (command == null)
                 throw new NullPointerException();
             /*
              * Proceed in 3 steps:
              *
              * 1. If fewer than corePoolSize threads are running, try to
              * start a new thread with the given command as its first
              * task.  The call to addWorker atomically checks runState and
              * workerCount, and so prevents false alarms that would add
              * threads when it shouldn't, by returning false.
              *
              * 2. If a task can be successfully queued, then we still need
              * to double-check whether we should have added a thread
              * (because existing ones died since last checking) or that
              * the pool shut down since entry into this method. So we
              * recheck state and if necessary roll back the enqueuing if
              * stopped, or start a new thread if there are none.
              *
              * 3. If we cannot queue task, then we try to add a new
              * thread.  If it fails, we know we are shut down or saturated
              * and so reject the task.
              */
             int c = ctl.get();
             if (workerCountOf(c) < corePoolSize) {
                 if (addWorker(command, true))
                     return;
                 c = ctl.get();
             }
             if (isRunning(c) && workQueue.offer(command)) {
                 int recheck = ctl.get();
                 if (! isRunning(recheck) && remove(command))
                     reject(command);
                 else if (workerCountOf(recheck) == 0)
                     addWorker(null, false);
             }
             else if (!addWorker(command, false))
                 reject(command);
         }
     ```

     - addWorker()方法

     ```
      private boolean addWorker(Runnable firstTask, boolean core) {
             retry:
             for (;;) {
                 int c = ctl.get();
                 int rs = runStateOf(c);

                 // Check if queue empty only if necessary.
                 if (rs >= SHUTDOWN &&
                     ! (rs == SHUTDOWN &&
                        firstTask == null &&
                        ! workQueue.isEmpty()))
                     return false;

                 for (;;) {
                     int wc = workerCountOf(c);
                     if (wc >= CAPACITY ||
                         wc >= (core ? corePoolSize : maximumPoolSize))
                         return false;
                     if (compareAndIncrementWorkerCount(c))
                         break retry;
                     c = ctl.get();  // Re-read ctl
                     if (runStateOf(c) != rs)
                         continue retry;
                     // else CAS failed due to workerCount change; retry inner loop
                 }
             }
             //以上一大段是为了实现给ctl变量设置要增加的那个值，如果这一步就失败了，直接返回false

             boolean workerStarted = false;
             boolean workerAdded = false;
             Worker w = null;
             try {
                 w = new Worker(firstTask);
                 final Thread t = w.thread;
                 if (t != null) {
                     final ReentrantLock mainLock = this.mainLock;
                     mainLock.lock();//加锁，增加新的线程，并开始
                     try {
                         // Recheck while holding lock.
                         // Back out on ThreadFactory failure or if
                         // shut down before lock acquired.
                         int rs = runStateOf(ctl.get());

                         if (rs < SHUTDOWN ||
                             (rs == SHUTDOWN && firstTask == null)) {
                             if (t.isAlive()) // precheck that t is startable
                                 throw new IllegalThreadStateException();
                             workers.add(w);
                             int s = workers.size();
                             if (s > largestPoolSize)
                                 largestPoolSize = s;
                             workerAdded = true;
                         }
                     } finally {
                         mainLock.unlock();
                     }
                     if (workerAdded) {
                         t.start();
                         workerStarted = true;
                     }
                 }
             } finally {
                 if (! workerStarted)
                     addWorkerFailed(w);
             }
             return workerStarted;
         }
     ```

     > 整个**addWorker**的逻辑就是：
     >
     > 1. cas操作改变ctl为期望的值，如果失败，返回false;
     > 2. 如果1操作成功，新建线程，并且再次检查这个线程是否应该被加入，如果不应该被加入，执行取消操作，这个过程是要加锁的，因为worker set是hashset，不是一个安全的集合。

- Worker是如何工作的？

> 实际上worker最后是到这个方法去不断执行任务的

```
   final void runWorker(Worker w) {
        Thread wt = Thread.currentThread();
        Runnable task = w.firstTask;
        w.firstTask = null;
        w.unlock(); // allow interrupts
        boolean completedAbruptly = true;
        try {//这是一个死循环。。。
            while (task != null || (task = getTask()) != null) {//注意1
                w.lock();//获取任务执行的时候加锁
                // If pool is stopping, ensure thread is interrupted;
                // if not, ensure thread is not interrupted.  This
                // requires a recheck in second case to deal with
                // shutdownNow race while clearing interrupt
                if ((runStateAtLeast(ctl.get(), STOP) ||   //注意2stop，只线程状态为中断
                     (Thread.interrupted() &&
                      runStateAtLeast(ctl.get(), STOP))) &&
                    !wt.isInterrupted())
                    wt.interrupt();
                try {
                    beforeExecute(wt, task);//前置处理
                    Throwable thrown = null;
                    try {
                        task.run();
                    } catch (RuntimeException x) {
                        thrown = x; throw x;
                    } catch (Error x) {
                        thrown = x; throw x;
                    } catch (Throwable x) {
                        thrown = x; throw new Error(x);
                    } finally {
                        afterExecute(task, thrown);//后置处理，均是空方法
                    }
                } finally {
                    task = null;
                    w.completedTasks++;
                    w.unlock();//结束一个任务的时候解锁，加锁的问题见3
                }
            }
            completedAbruptly = false;
        } finally {
            processWorkerExit(w, completedAbruptly);
        }
    }
```

1. getTask()里通过自检的过程，可以清除空闲**idle**的线程，因为一旦getTask()返回null，这个线程就走向终结了。

2. 如果当前为stop，设置当前线程为**中断**，这样的话，虽然当前的任务可以执行，但是下一次从getTask()里获取直接会返回null，然后这个线程就走向gg了

   ```
    private Runnable getTask() {
           boolean timedOut = false; // Did the last poll() time out?

           for (;;) {
               int c = ctl.get();
               int rs = runStateOf(c);

               // Check if queue empty only if necessary.
               if (rs >= SHUTDOWN && (rs >= STOP || workQueue.isEmpty())) {
                   decrementWorkerCount();
                   return null;//不满足状态的话，返回null
               }

               int wc = workerCountOf(c);

               // Are workers subject to culling?
               boolean timed = allowCoreThreadTimeOut || wc > corePoolSize;//是否允许核心线程维持存货

               if ((wc > maximumPoolSize || (timed && timedOut))
                   && (wc > 1 || workQueue.isEmpty())) {
                   if (compareAndDecrementWorkerCount(c))
                       return null;
                   continue;
               }

               try {
                   Runnable r = timed ?
                       workQueue.poll(keepAliveTime, TimeUnit.NANOSECONDS) :
                       workQueue.take();//keepAliveTime即核心线程的空闲存活时间
                   if (r != null)
                       return r;
                   timedOut = true;
               } catch (InterruptedException retry) {
                   timedOut = false;
               }
           }
       }
   ```

   ​	2.来看Worker里这个锁的用处

   > 这个Worker里的锁不是只有它自己那个线程才会访问的，所以不应该加锁的，但是这里却加了？？
   >
   > 看一下这个锁相关方法还有谁在调用？
   >
   > **tryLock**，发现这个方法在**interruptIdleWorkers**被调用了，最上层暴露出来的是**shutdown**方法，再回去看，如果核心线程被阻塞在**getTask**的时候，是不会获取锁的，那么tryLock()是返回true，所以用这个来判断某个工作线程是否处于**空闲**状态。

- 拒绝策略

> 默认jdk实现的由四种拒绝策略

| 类名                  | 说明                   |
| ------------------- | -------------------- |
| CallerRunsPolicy    | 直接由提交任务的线程去执行        |
| AbortPolicy         | 直接抛出异常               |
| DiscardOldestPolicy | 丢弃最老的一个任务，然后尝试重新提交任务 |
| DiscardPolicy       | 直接丢弃，什么都不做           |



- 总结：

> ThreadPoolExecutor，维护以下几个成员变量：
>
> - ctl 		记录线程池线程数量以及状态
> - mainlock          主要是锁定队workset的操作
> - workerSet        工作线程
> - workQueue     任务队列
>
> 内部类Worker
>
> - 自己实现一个锁，为清理空闲线程作支持
> - while循环不断取出方法，通过getTask()可以自行清除自己。。。