### 周期任务执行器ScheduledExecutorService源码学习

> ScheduledExecutorService可以用来执行**单次**的延时任务，也可以执行**周期**任务
>
> ScheduledExecutorService接口继承了ExecutorService接口，所以有线程执行器的功能，然后新增加了周期执行任务的能力。
>
> 下面通过ScheduledThreadPoolExecutor来学习这个周期性执行器的实现。

​	

- 继承关系

> 可以看到ScheduledThreadPoolExecutor是继承了**ThreadPoolExecutor**的，线程池的功能是由后者来实现的，ScheduleThreadPoolExecutor是用来实现周期性执行任务的。

- 匿名内部类

> 有一个重要的匿名内部类**DelayedWorkQueue**，延时队列的功能就是每次只出队**倒计时**结束的节点，内部是用**小顶堆**来实现排序的。这个是用来实现周期任务的重点工具。
>
> 线程池从这个延时队列取出已经到达延时的队列，然后取出执行，然后马上又按照**周期**的长度作为**延时值**，再次入队，下面看具体的实现。

- 构造方法

> 只选一个暴露在外的构造方法，可以看到，队列已经默认指定为内部类DelayedWorkQueue了，这个构造方法最后调用的是父类**ThreadPoolExecutor**的构造方法，毕竟核心功能是TPE提供的。

```
    public ScheduledThreadPoolExecutor(int corePoolSize) {
        super(corePoolSize, Integer.MAX_VALUE, 0, NANOSECONDS,
              new DelayedWorkQueue());
    }
```

- 重要方法schedule

```
public ScheduledFuture<?> schedule(Runnable command,
                                       long delay,
                                       TimeUnit unit) {
        if (command == null || unit == null)
            throw new NullPointerException();
        RunnableScheduledFuture<?> t = decorateTask(command,
            new ScheduledFutureTask<Void>(command, null,
                                          triggerTime(delay, unit)));
        delayedExecute(t);
        return t;
    }
```



> schedule是暴露在外的周期任务执行的方法，是TPE没有的方法，可以看到，这个方法把提交的Runnable封装成了**RunnableScheduleFuture**(这个接口继承了一堆接口)，然后交给**delayedExeute(t)**执行。

​	delayExecute(t)代码：

```
 private void delayedExecute(RunnableScheduledFuture<?> task) {
        if (isShutdown())
            reject(task);
        else {
            super.getQueue().add(task);//入队
            if (isShutdown() &&
                !canRunInCurrentRunState(task.isPeriodic()) &&
                remove(task))
                task.cancel(false);
            else
                ensurePrestart();//加入队列后，检查是否由足够的线程取执行任务
        }
    }
    
    //ensurePrestart()代码非常简单：
    void ensurePrestart() {
        int wc = workerCountOf(ctl.get());
        if (wc < corePoolSize)
            addWorker(null, true);
        else if (wc == 0)
            addWorker(null, false);
    }
	//其实就是起到TPE的execute方法里的扩展线程的功能，因为schedule跳过了exec方法
```

> 以上把添加任务的功能追踪完了，下面是执行任务的地方，就是Worker工作的地方

- 追踪Worker的工作

> 由于线程池的功能是由ThreadPoolExecutor实现的，按照经验，直接把断点打在TPE的**runWorker**（ThreadPoolExecutor:1149行)里就可以很好地追踪这个执行过程。看看上面封装**Runnable**后是如何执行的。

​	断点执行跳入来到了**ScheduledFutureTask.run()**:

```
 public void run() {
            boolean periodic = isPeriodic();//判断是否周期性任务
            if (!canRunInCurrentRunState(periodic))
                cancel(false);
            else if (!periodic)
                ScheduledFutureTask.super.run();
                //非周期任务走这里，这里实际上走的是FutureTask.run()和TPE的submit调用没什么区别了
            else if (ScheduledFutureTask.super.runAndReset()) {注意1
                setNextRunTime();
                reExecutePeriodic(outerTask);
            }
        }
```

1. 这里就是周期任务的执行的重点了：

   > setNextRunTime()设置下次执行的时间
   >
   > ​
   >
   >          private void setNextRunTime() {
   >            long p = period;
   >             if (p > 0)
   >                 time += p;
   >             else
   >                 time = triggerTime(-p);
   >         }
   > 重新提交任务：
   >
   > ​
   >
   >     void reExecutePeriodic(RunnableScheduledFuture<?> task) {    if (canRunInCurrentRunState(true)) {
   >             super.getQueue().add(task);
   >             if (!canRunInCurrentRunState(true) && remove(task))
   >                 task.cancel(false);
   >             else
   >                 ensurePrestart();
   >         }
   >     }

   ​	

   - 再来回顾TPE的runWorker方法

     > TPE的**runWorker**方法里，每一个工作线程都在这里进行死循环，然后阻塞在task = getTask()，根据延时队列的特性，只有到了执行时间，才会出队，所以利用这个性质实现**周期性**执行任务的功能。
     >
     > Delay接口已经Blocking队列的特点见本分类下。

   - ScheduleExecutorService有四种基本的使用方法

     1. 延迟执行schedule()

        非周期任务，仅仅是延迟执行而已。

     2. 带返回值Future的延迟执行

     3. scheduleAtFixedRate 固定频率执行

     4. scheduleWithFixedDelay固定的延迟执行

     > 3&4的区别在哪里？
     >
     > 文档里关于scheduleAtFixedRate的解释：
     >
     > Creates and executes a periodic action that becomes enabled first after the given initial delay, and subsequently with the given period; that is executions will commence after `initialDelay` then `initialDelay+period`, then `initialDelay + 2 * period`, and so on.
     >
     > **固定频率**的意思是，每次按**initialDelay + n * period**周期去设置延迟时间
     >
     > scheduleWithFixedDelay的文档解释：
     >
     > Creates and executes a periodic action that becomes enabled first after the given initial delay, and subsequently with the given delay between the termination of one execution and the commencement of the next.
     >
     > **固定延迟**的意思是，一次周期任务执行完毕后再以**当前执行完毕**的时间去设置**延时**
     >
     > 还是看看**代码**里是怎么样处理的吧:
     >
     >        //负数代表fixed-delay,正数代表fixed-rate
     >        private final long period;
     >        
     >        private void setNextRunTime() {
     >             long p = period;
     >             if (p > 0)
     >                 time += p;//延迟时间总是直接加周期
     >             else
     >                 time = triggerTime(-p);//进入triggerTime()
     >         }
     >         
     >           long triggerTime(long delay) {
     >             //以当前时间去加周期period
     >             return now() +
     >                 ((delay < (Long.MAX_VALUE >> 1)) ? delay : overflowFree(delay));
     >         }
     > **固定频率**的方式，如果任务执行的事件超过了周期时间，然后还是又提交，可能会导致抢占掉其他的的**固定延时**任务执行的任务

     ​

     - 总结

     > ScheduleExecutorService继承了ThreadPoolExecutor，线程池功能都是TPE提供的，而SES的周期性任务主要是通过一个**延迟执行的任务队列**和任务执行完毕后的**重入**任务队列实现的。通过在**schedule()**的时候把**Runnable**任务封装成**ScheduleFutureTask**任务，里面包含了延迟，返回值这些功能。
     >
     > 有四种工作模式：延迟执行，带返回值的延迟执行，固定执行频率的周期任务，固定延迟周期的周期任务。