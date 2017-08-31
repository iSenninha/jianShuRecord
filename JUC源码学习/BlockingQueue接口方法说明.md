###BolckingQueue接口
> BlockingQueue 是juc下所有队列的接口，这些队列包括：

- ArrayBolckingQueue
- DelayedWorkQueue
- DelayQueue
- FariBlockQueue
- LinkedBlockingQueue
- PriorityBolckingQueue
- SychronousQueue
- ​

先来熟悉一下相关的接口方法标准


<br>

- boolean add(E e)
  从函数说明可以看出，这个方法是立即返回操作结果的，如果是在有界队列，队列满的时候，是直接抛出IllegalStateException异常的，所以建议在有界队列的时候，使用offer()
  <br>
- boolean offer(E e) 方法说明又强调了一次，如果是有界队列，这个比add方法好。如果队列满了，直接返回，而不是像add一样抛出异常。
  <br>
- 还有另外一个offer方法
   boolean offer(E e, long timeout, TimeUnit unit)  throws InterruptedException;
   这个offer方法是可设置等待时间，并且是可中断的，成功入队返回true，超时失败false
   <br>
- put(E e) 队列满的时候一直等待直到中断异常
  <br>
- E take() 方法，返回检索获取到队列头的元素并且移除他，如果没有可获取的元素，还是一直傻等，直到抛出中断异常
  <br>
- E poll(long timeout, TimeUnit unit)方法，等待一个指定的时间段，如果在等待过程中中断了，抛出中断异常，如果等待时间还没有获取到，返回null

总结如下:
> put(E e)和take()一个是入队一个出对，是会一直傻等直到抛出中断异常的
>    offer(E e, Long timeout, TimeUnit unit)和poll(long timeout, TimeUnit unit)是在一个时间段内等，不会一直傻等的
