### Java与线程

> Java的并发是依赖多线程来实现的。但是并发不一定要依赖于多线程，比如php就是用多进程来实现并发的。

> 进程和线程的概念：
>
> 进程是获取文件I/O,内存地址等硬件资源的最小单位
>
> 而线程共享所属进程的硬件资源，并且是CPU调度(获取CPU时间片段)的最小单位。



- 线程的实现

  1. 使用内核线程来实现

     一个内核线程对应一个线程，多个线程归属于一个进程。

  2. 使用用户线程来实现

     比较少用

  3. 混合内核线程和用户线程

  > java在linux,windows上是使用1个线程对应一个内核线程去实现线程的。



- Java线程调度

  - 线程调度有两种

    1.协同式线程调度（Cooperative Threads-Scheduling）

    ​	由线程自己决定调度，容易因为程序问题而导致系统崩溃。

    2.抢占式线程调度（Preemptive Threads-Scheduling）

    ​	由系统来决定线程切换，线程的执行时间由系统来决定，Java里可以通过thread.yeild()让出执行时间，但是无法确切获取执行时间片段。设置优先级也无法保证。Java采用这种调度方式。	



- 状态转换

  - 新建(new)

    新创建尚未启动的线程处于这种状态

  - 运行(runnable)

    包含了操作系统线程中的Running和Ready，也就是处于这种状态的线程可能处在获取到CPU片段或者在等待获取CPU片段(区别于waiting)

  - 无限期等待(waiting)

    处于这种状态的线程不会被分配到CPU片段，只有被其他线程唤醒才可以重新获取CPU片段，以下方法会导致无限期等待：

    1. object.wait();
    2. thread.join();
    3. LockSupport().park()方法

  - 有限期等待(Timed Waiting)

    1. thread.sleep(long)方法
    2. object.wait(long)
    3. thread.join(long)
    4. LockSupport.parkNanos(long)
    5. LockSupport.parkUnitl(long)

  - 阻塞(Blocked)

    区别于等待状态，这里的阻塞是指等待着获取排他锁，juc包下的重入锁系列就不是阻塞，而是无限期等待。

  - 结束(Terminated)

    已经终止的线程的状态



- 线程分析
  1. 代码示例demo

```
public class HelloWorld {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		System.out.println("helloworld");
		ReentrantLock r = new ReentrantLock();
		r.lock();
		new Thread(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				r.lock();
			}
		}).start();
		
		try {
			Thread.currentThread().sleep(100000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			
		}
	}
	
}
```

 2.  然后获取进程id并导出线程堆栈

     jps

     jstack pid > xxx.txt

```
"我是等待线程" #9 prio=5 os_prio=0 tid=0x00007f593c0d6800 nid=0x2404 waiting on condition [0x00007f5913729000]
   java.lang.Thread.State: WAITING (parking)
        at sun.misc.Unsafe.park(Native Method)
        - parking to wait for  <0x00000000ecbe5b58> (a java.util.concurrent.locks.ReentrantLock$NonfairSync)
//证明了重入锁等待锁是等待状态，调用的是LockSupport的park方法
//从这个角度看，RentrantLock的等待锁的线程处在等待状态，而不是阻塞状态，会不会是比Synchronized性能好的原因？


//煮线程在等待
"main" #1 prio=5 os_prio=0 tid=0x00007f593c00a000 nid=0x23f1 waiting on condition [0x00007f59425ba000]
   java.lang.Thread.State: TIMED_WAITING (sleeping)
        at java.lang.Thread.sleep(Native Method)
        at HelloWorld.main(HelloWorld.java:18)

```



