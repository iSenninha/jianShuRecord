Executors详解

> Executors里提供了常用的线程池模式

1. ExecutorService系列

| 方法                      | 解析                                       |
| ----------------------- | ---------------------------------------- |
| newFixedThreadPool()    | 直接调用new ThreadPoolExecutor(nThreads, nThreads,0L, TimeUnit.MILLISECONDS,new LinkedBlockingQueue<Runnable>())方法，是固定线程池的。 |
| newSingleThreadExecutor | new FinalizableDelegatedExecutorService()调用的是封装了一层的ThreadPoolExecutor方法，其实只是重写了**finalize**方法。目的是在辣鸡回收的时候做一次shutdown。。。见**1.1** |
| newCachedThreadPool     | return new ThreadPoolExecutor(0, Integer.MAX_VALUE, 60L, TimeUnit.SECONDS, new SynchronousQueue<Runnable>());使用**SynchronousQueue**队列来做工作队列，并且可以开无限线程。。。因为SynchronousQueue实际上是不存东西的。。就是个中转站。。并且存活时间是60s。。 |
|                         |                                          |

​	**1.1**

```
        protected void finalize() {
            super.shutdown();/调用ThreadPoolExecutor的shutdown方法
        }
```



----



2. Schedule系列

| 周期性执行任务                          | 解析                                       |
| -------------------------------- | ---------------------------------------- |
| newSingleThreadScheduledExecutor | 单线程周期性任务，依然用了一个代理类，在finalize的时候加入了shutdown方法 |
| newScheduledThreadPool           | 指定线程数目和线程工程                              |
|                                  |                                          |
|                                  |                                          |

