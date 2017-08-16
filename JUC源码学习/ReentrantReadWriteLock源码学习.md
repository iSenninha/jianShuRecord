### ReentrantReadWriteLock

> 在读多于写的环境下，可以考虑用读写锁RRW来提高性能

******

- 内部类
  1. Sync----继承自AQS，主要的实现都在Sync;
  2. FairSync，NoFairSync---继承自Sync
  3. ReadLock，WriteLock，内部持有来自于ReentrantReadWriteLock的Sync对象引用



- ReentReadWriteLock的成员变量和构造方法

```
  private final ReentrantReadWriteLock.ReadLock readerLock;
    /** Inner class providing writelock */
    private final ReentrantReadWriteLock.WriteLock writerLock;
    /** Performs all synchronization mechanics */
    final Sync sync;
    
    /** 构造方法 */
    public ReentrantReadWriteLock(boolean fair) {
        sync = fair ? new FairSync() : new NonfairSync();
        readerLock = new ReadLock(this);
        writerLock = new WriteLock(this);
    }
```

> 可以看出来，整个ReentReadWriteLock持有一个AQS的子类，然后有ReadLock和WriteLock共享AQS的子类。所有着重分析AQS的子类。



- 通过Debug小demo分析这个过程

```
		ReentrantReadWriteLock lock = new ReentrantReadWriteLock();
		ReadLock rLock = lock.readLock();
		rLock.lock();
		WriteLock wLock = lock.writeLock();
		wLock.lock();
```



- 先来看一下ReadLock的加锁过程：

> 跳入了AQS.acquireShared()方法--->Sync.tryAcquireShared(int unused)（见***代码1***）---->

代码1：

```
protected final int tryAcquireShared(int unused) {
            /*
             * Walkthrough:
             * 1. If write lock held by another thread, fail.
             * 2. Otherwise, this thread is eligible for
             *    lock wrt state, so ask if it should block
             *    because of queue policy. If not, try
             *    to grant by CASing state and updating count.
             *    Note that step does not check for reentrant
             *    acquires, which is postponed to full version
             *    to avoid having to check hold count in
             *    the more typical non-reentrant case.
             * 3. If step 2 fails either because thread
             *    apparently not eligible or CAS fails or count
             *    saturated, chain to version with full retry loop.
             */
            Thread current = Thread.currentThread();
            int c = getState();
            if (exclusiveCount(c) != 0 &&
                getExclusiveOwnerThread() != current)//这个是
                return -1;
            int r = sharedCount(c);
            if (!readerShouldBlock() &&
                r < MAX_COUNT &&
                compareAndSetState(c, c + SHARED_UNIT)) {
                if (r == 0) {
                    firstReader = current;
                    firstReaderHoldCount = 1;
                } else if (firstReader == current) {
                    firstReaderHoldCount++;
                } else {
                    HoldCounter rh = cachedHoldCounter;
                    if (rh == null || rh.tid != getThreadId(current))
                        cachedHoldCounter = rh = readHolds.get();
                    else if (rh.count == 0)
                        readHolds.set(rh);
                    rh.count++;
                }
                return 1;
            }
            return fullTryAcquireShared(current);
        }
```



> 1.读锁和写锁都维护同一个Sync，一个Sync里只有一个int 型的state，通过掩码的方式，高十六位是是读锁的状态，低十六位是写锁的状态。并且维护由一个ThreadLocal的子类，用来维护每个线程的读锁次数。
>
> 2.先申请了读锁，然后写锁申请，此时写锁被阻塞了，加入AQS的等待队列，等待唤醒获取锁。如果是已经申请到了读锁的线程再次去申请读锁，可以通过上面说的ThreadLocal获取到当前线程已经是占有读锁的，所以可以继续获取读锁，其实就是读锁里的holdCount + 1。
>
> 此时如果第三者线程取申请读锁，是无法成功的，也会被加入AQS的等待队列等待唤醒获取锁。
>
> 3.公平锁非公平锁的核心就是    writerShouldBlock()和readShouldBlock()里是判断是否有节点在等待的问题，和ReentranLock是一样的思想。