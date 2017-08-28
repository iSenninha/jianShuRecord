### ReentrantReadWriteLock

> 在读多于写的环境下，可以考虑用读写锁RRW来提高性能

******

- 内部类
  1. Sync----继承自AQS，主要的实现都在Sync;
  2. FairSync，NoFairSync---继承自Sync
  3. ReadLock，WriteLock，内部持有来自于ReentrantReadWriteLock的Sync对象引用，只有一个Sync的情况下，使用**掩码**来实现一个int变量记录种锁的信息。
  4. 此外，Sync里持有firstReader，firstReaderHoldCount，ThreadLocal的子类，为多个线程持有读锁作**记录**



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
                getExclusiveOwnerThread() != current)//有写锁，并且写锁不是当前线程的话直接返回-1
                return -1;
            int r = sharedCount(c);
            if (!readerShouldBlock() &&//是否有等待获取锁的线程(不管是写还是读)
                r < MAX_COUNT &&
                compareAndSetState(c, c + SHARED_UNIT)) {
                if (r == 0) {
                    firstReader = current;
                    firstReaderHoldCount = 1;
                } else if (firstReader == current) {//这里的第一个读线程的信息是直接存在写锁里的成员变量
                    firstReaderHoldCount++;
                } else {//然鹅，更多的读线程的信息是存在ThreadLocal的子类里的
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



> 1.读锁和写锁都维护同一个Sync，一个Sync里只有一个int 型的state，通过掩码的方式，**高十六位**是是读锁的状态，**低十六位**是写锁的状态。并且维护由一个ThreadLocal的子类，用来维护每个线程的读锁次数。
>
> 2.先申请了读锁，然后写锁申请，此时写锁被阻塞了，加入AQS的等待队列，等待唤醒获取锁。如果是已经申请到了读锁的线程再次去申请读锁，通过两种途径(ReadLock的成员变量**firstReader**或**ThreadLocal*子类**)去获取当前的线程是否已经占有读锁，然后获取。
>
> 此时如果第三者线程取申请读锁，是**无法成功**的，也会被加入AQS的等待队列等待唤醒获取锁。
>
> 3.公平锁非公平锁的核心就是    writerShouldBlock()和readShouldBlock()里是判断是否有节点在等待的问题，和ReentranLock是一样的思想。
>
> 4.**只要**有读锁或者写锁在申请或者等待中，那么任何线程都无法获取到写锁，只能等待，于是，如果a线程申请了读锁，那么又去申请写锁，就会导致**死锁**
>
> 5.如果一个锁已经持有了**写锁**或者**读锁**，当由线程在排队获取锁的时候，是可以再次重入获取**读锁**的。
>
> 6.**4**和**5**的意思就是，锁只可能降级，不能升级。