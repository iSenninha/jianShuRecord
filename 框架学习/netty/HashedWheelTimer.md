### HashedWheelTimer
HashedWheelTimer是更适合用于I/O等待的定时器。
高效之处在于通过一个叫**wheel**的数据结构。在这里简化为一个哈希表，通过哈希dead line，把”相同“deadline时间的任务分配到同一个bucket上。每一次tick的时候，只检查当前处于超时区间的bucket，更高效地执行超时任务。

#### 1.几个重要的成员变量
```
    // 每一次tick的间隔时间
    private final long tickDuration;
    // wheel结构
    private final HashedWheelBucket[] wheel;
    // 掩码,用来哈希到对应桶的 (哈希桶的长度 - 1)
    private final int mask;
    // 此HashedWheelTimer的开始时间，之后所有的deadline都是以这个时间为参照物的相对时间
    private volatile long startTime;
    // 用来缓存添加进来的定时任务
    private final Queue<HashedWheelTimeout> cancelledTimeouts = PlatformDependent.newMpscQueue();
    // tick线程,真正处理定时任务的工作者
    private final Worker worker = new Worker();
```

#### 2.定时任务添加
```
@Override
    public Timeout newTimeout(TimerTask task, long delay, TimeUnit unit) {
        if (task == null) {
            throw new NullPointerException("task");
        }
        if (unit == null) {
            throw new NullPointerException("unit");
        }
        if (shouldLimitTimeouts()) {
            long pendingTimeoutsCount = pendingTimeouts.incrementAndGet();
            if (pendingTimeoutsCount > maxPendingTimeouts) {
                pendingTimeouts.decrementAndGet();
                throw new RejectedExecutionException("Number of pending timeouts ("
                    + pendingTimeoutsCount + ") is greater than or equal to maximum allowed pending "
                    + "timeouts (" + maxPendingTimeouts + ")");
            }
        }

        start();

        // Add the timeout to the timeout queue which will be processed on the next tick.
        // During processing all the queued HashedWheelTimeouts will be added to the correct HashedWheelBucket.
	// 计算相对startTime的超时时间
        long deadline = System.nanoTime() + unit.toNanos(delay) - startTime;
        HashedWheelTimeout timeout = new HashedWheelTimeout(this, task, deadline);
	// 加入临时的队列中，等待tick线程处理
        timeouts.add(timeout);
        return timeout;
    }	
```
简单加入临时队列，就直接返回了，为什么说是临时队列呢?因为工作线程并不会直接通过取这个队列的任务进行定时任务执行。

#### 3.工作队列
核心代码是在内部类**Worker**里
##### 3.1 重要成员变量
```
	// 这个tick随着每一次tick++增加,并且根据这个tick计算出时间，决定任务应该哈希到哪个bucket中
        private long tick;
```

##### 3.2 处理定时任务
```
@Override
        public void run() {
            // Initialize the startTime.
            startTime = System.nanoTime();
            if (startTime == 0) {
                // We use 0 as an indicator for the uninitialized value here, so make sure it's not 0 when initialized.
                startTime = 1;
            }

            // Notify the other threads waiting for the initialization at start().
            startTimeInitialized.countDown();

            do {
                final long deadline = waitForNextTick();	// 1
                if (deadline > 0) {
                    int idx = (int) (tick & mask);		// 2
                    processCancelledTasks();
                    HashedWheelBucket bucket =
                            wheel[idx];
                    transferTimeoutsToBuckets();		// 3
                    bucket.expireTimeouts(deadline);		// 4
                    tick++;
                }
            } while (WORKER_STATE_UPDATER.get(HashedWheelTimer.this) == WORKER_STATE_STARTED);

            // Fill the unprocessedTimeouts so we can return them from stop() method.
            for (HashedWheelBucket bucket: wheel) {
                bucket.clearTimeouts(unprocessedTimeouts);
            }
            for (;;) {
                HashedWheelTimeout timeout = timeouts.poll();
                if (timeout == null) {
                    break;
                }
                if (!timeout.isCancelled()) {
                    unprocessedTimeouts.add(timeout);
                }
            }
            processCancelledTasks();
        }
```
- 1.计算出是否需要休眠等待下一次tick

- 2.根据当前的tick哈希出当前需要处理那个bucket
    这个tick，工作队列每执行一次tick线程，就会+1。long型，可预见的未来都不会溢出。

- 3.将临时任务队列中的任务转移到哈希到合适的队列中
```
        private void transferTimeoutsToBuckets() {
            // transfer only max. 100000 timeouts per tick to prevent a thread to stale the workerThread when it just
            // adds new timeouts in a loop.
            for (int i = 0; i < 100000; i++) {
                HashedWheelTimeout timeout = timeouts.poll();	// 临时任务队列poll出
                if (timeout == null) {
                    // all processed
                    break;
                }
                if (timeout.state() == HashedWheelTimeout.ST_CANCELLED) {	// 忽略取消的任务
                    // Was cancelled in the meantime.
                    continue;
                }

                long calculated = timeout.deadline / tickDuration;		// 根据任务的deadline / 每一次tick的时间，得出本任务应该在哪个ticke的时候执行
                timeout.remainingRounds = (calculated - tick) / wheel.length;	// 大于哈希轮长度的情况，计算一下本个tick到这个bucket的时候,几轮才能轮到执行

                final long ticks = Math.max(calculated, tick); // Ensure we don't schedule for past.
                int stopIndex = (int) (ticks & mask);	// 把这个任务哈希放到合适的bucket中

                HashedWheelBucket bucket = wheel[stopIndex];
                bucket.addTimeout(timeout);
            }
        }
```

- 4.tick执行该次tick应该执行的bucket任务
```
        public void expireTimeouts(long deadline) {
            HashedWheelTimeout timeout = head;

            // process all timeouts
            while (timeout != null) {
                HashedWheelTimeout next = timeout.next;
                if (timeout.remainingRounds <= 0) {	// 小于等于0才执行，大于0说明需要下一次到这个桶才需要执行
                    next = remove(timeout);
                    if (timeout.deadline <= deadline) {	// 肯定是小于deadline的,因为根据deadline哈希任务bucket的时候，是/操作，必然是保守值。
                        timeout.expire();
                    } else {
                        // The timeout was placed into a wrong slot. This should never happen.
                        throw new IllegalStateException(String.format(
                                "timeout.deadline (%d) > deadline (%d)", timeout.deadline, deadline));
                    }
                } else if (timeout.isCancelled()) {
                    next = remove(timeout);
                } else {
                    timeout.remainingRounds --;
                }
                timeout = next;
            }
        }
```


#### 总结
> 通过把任务根据时间哈希到不同的bucket内，每一次执行的时候，只需要遍历对应的bucket检查是否应该执行，避免了遍历的耗时。遍历效率从O(N)提升到O(1)。
