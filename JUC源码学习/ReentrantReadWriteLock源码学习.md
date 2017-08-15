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



- 首先看一下继承自ASQ的Sync的结构：

```

```



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

