### 周期任务执行器ScheduledExecutorService源码学习

> ScheduledExecutorService可以用来执行**单次**的延时任务，也可以执行**周期**任务
>
> ScheduledExecutorService接口继承了ExecutorService接口，所以有线程执行器的功能，然后新增加了周期执行任务的能力。
>
> 下面通过ScheduledThreadPoolExecutor来学习这个周期性执行器的实现。

