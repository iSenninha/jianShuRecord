### 信号量(Semaphore)&计数器(CountdownLatch)

- 信号量

  > 信号量的功能是限定几个信号量进入，这里的信号量是不分线程的，就是说，同一个线程可以申请多个信号量。

  demo:

  ```
  	Semaphore semaphore = new Semaphore(2);
  		try {
  			semaphore.acquire(2);
  			semaphore.acquire(1);
  		} catch (InterruptedException e) {
  			// TODO Auto-generated catch block
  			e.printStackTrace();
  		}
  ```

  > 这里粒子可以很好的说明信号量的功能，允许**2**个信号进入，先申请**2**个信号，然后申请了**2**个信号的线程再次去申请**1**个信号，很好，成功**死锁**了。。个人觉得这个东西是用在类似秒杀或者什么活动的？
  >
  > 底层依然是**AQS**去实现的。应该能猜到这个，用**AQS**的**state**变量来记录还剩余的可进入信号量。一旦**state**等于**0**的情况出现，入队参与竞争尝试获取**锁**，头节点也会挂起，在占有信号量的线程**释放**信号的时候，会调用**代码1**唤醒等待的线程继续竞争信号**代码2**。
  > 之所以可以唤醒全部的等待线程是因为在doAcquireShared()方法里，一个线程如果成功获取锁会调用**setHeadAndPropagate**这个会继续调用doReleaseShared方法继续唤醒后续在队列中等待的线程。
  >
  > ​
  >
  > 内置公平和非公平，主要是新申请信号量的线程是否马上加入竞争还是乖乖**入队**竞争。
  >
  > 还有一个有意思的地方是，这里用的是AQS的**共享Shared**模式，而不是**独占Exclusive**模式，所以调用的方法都是带**share**的方法。

  代码1：

  ```
   private void doReleaseShared() {
          for (;;) {
              Node h = head;
              if (h != null && h != tail) {
                  int ws = h.waitStatus;
                  if (ws == Node.SIGNAL) {
                      if (!compareAndSetWaitStatus(h, Node.SIGNAL, 0))
                          continue;            // loop to recheck cases
                      unparkSuccessor(h);//唤醒队列挂起线程
                  }
                  else if (ws == 0 &&
                           !compareAndSetWaitStatus(h, 0, Node.PROPAGATE))
                      continue;                // loop on failed CAS
              }
              if (h == head)                   // loop if head changed
                  break;
          }
      }
  ```


  代码2：

  ```
   private void doAcquireShared(int arg) {
          final Node node = addWaiter(Node.SHARED);
          boolean failed = true;
          try {
              boolean interrupted = false;
              for (;;) {
                  final Node p = node.predecessor();
                  if (p == head) {
                      int r = tryAcquireShared(arg);
                      if (r >= 0) {
                          setHeadAndPropagate(node, r);
                          p.next = null; // help GC
                          if (interrupted)
                              selfInterrupt();
                          failed = false;
                          return;
                      }
                  }
                  if (shouldParkAfterFailedAcquire(p, node) &&
                      parkAndCheckInterrupt())
                      interrupted = true;
              }
          } finally {
              if (failed)
                  cancelAcquire(node);
          }
      }
  ```

  ​

- 计数器(CountdownLatch)

  > 计数器的目的是等够了计数后就启动阻塞在**await**上的线程

  demo:

  ```
  		CountDownLatch latch = new CountDownLatch(2);
  		long count = latch.getCount();
  		//假设其他线程调用了latch.await()
  		latch.countDown();
  		latch.countDown();
  		//计数两次后所有等待在latch.await()的线程才会被唤醒。
  		latch.countDown();
  		//在这之后调用latch.await()不会再被阻塞，所有这个计数只能计数一次。
  ```

  > 所以CountdownLatch的核心是在达到计数的时候如何**唤醒全部的等待队列**(唤醒动作是在**countDown()**里做的)
  >
  > 这个方法是AQS实现的：doReleaseShared()，这个方法会在最后一次的**countDown**里调用，也会在阻塞唤醒后的线程里**doAcquireShared().setHeadAndPropagate()**方法里调用，加快唤醒，**propagation**可繁殖的。。。

  ```
   private void doReleaseShared() {
          /*
           * Ensure that a release propagates, even if there are other
           * in-progress acquires/releases.  This proceeds in the usual
           * way of trying to unparkSuccessor of head if it needs
           * signal. But if it does not, status is set to PROPAGATE to
           * ensure that upon release, propagation continues.
           * Additionally, we must loop in case a new node is added
           * while we are doing this. Also, unlike other uses of
           * unparkSuccessor, we need to know if CAS to reset status
           * fails, if so rechecking.
           */
          for (;;) {
              Node h = head;
              if (h != null && h != tail) {
                  int ws = h.waitStatus;
                  if (ws == Node.SIGNAL) {
                      if (!compareAndSetWaitStatus(h, Node.SIGNAL, 0))
                          continue;            // loop to recheck cases
                      unparkSuccessor(h);
                  }
                  else if (ws == 0 &&
                           !compareAndSetWaitStatus(h, 0, Node.PROPAGATE))
                      continue;                // loop on failed CAS
              }
              if (h == head)                   // loop if head changed
                  break;
          }
      }
      
      //唤醒后到这里出队：
       protected boolean tryReleaseShared(int releases) {
              // Decrement count; signal when transition to zero
              for (;;) {
                  int c = getState();
                  if (c == 0)//state==0即可出队
                      return false;
                  int nextc = c-1;
                  if (compareAndSetState(c, nextc))
                      return nextc == 0;
              }
          }
  ```

  > 所以用法：
  >
  > CountdownLatch.countdown()到了指定的数量
  >
  > CountdownLatch.await()才会执行。
  >
  > 就是辣么简单。
  >
  > 原理是使用AQS的**共享模式** ，和信号量一样。




- 循环栅栏(CyclicBarrier)

> 循环栅栏的用法是等到特定的线程进入了后再启动(注意是**线程**，不像上面拿两个，只要去调用非阻塞的API就可以消耗计数量)

​	demo:

```
		CyclicBarrier barrier = new CyclicBarrier(2);
		new Thread(new Runnable() {

			@Override
			public void run() {
				// TODO Auto-generated method stub
				try {
					barrier.await();//第一个await()，这是个阻塞方法
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (BrokenBarrierException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}

		}).start();
		try {
			barrier.await();//第二个await
			System.out.println("jfdj");
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (BrokenBarrierException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

```

​	与其他的工具类不同，CyclicBarrier是直接聚合一个ReentrantLock来实现功能的，来看看调用await的时候发生了什么：

```
ReentrantLock.lock()--->检查是否到达了计数值，若到达，若不到，释放锁，并加入condition队列

					--->若到达计数值，执行以下代码：
					 final Runnable command = barrierCommand;
                    if (command != null)
                        command.run();//初始化时，可以往构造方法里填入这个，到达计数值的时候要执行的方法
                    ranAction = true;
                    nextGeneration();//这里来唤醒所有等待在condition队列的线程
                    return 0;
                    
                     private void nextGeneration() {
                        // signal completion of last generation
                        trip.signalAll();//这里是conditon的signalAll方法
                        // set up next generation
                        count = parties;//重新设置计数量，所以这货可以重复计数。
                        generation = new Generation();
                    }
```



另外在由**中断**或者**调用reset**方法的时候，会产生brokenBarrier的动作，这个时候会唤醒所有的等待队列：

```
 public void reset() {
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            breakBarrier();   // break the current generation
            nextGeneration(); // start a new generation
        } finally {
            lock.unlock();
        }
    }
```

> 每次调用await后都会申请Reentrant的锁，然后自减count，如果不满足，进入Condition队列等待，如果到了那个满足的线程，会调用Command（如果指定了），然后调用nextGeneration()继续唤醒其他的等待在Condition上的线程，只有上一代Generation上的才有效，所以只会唤醒上一代的Generation。下一次的循环栅栏线程并不会被唤醒。
