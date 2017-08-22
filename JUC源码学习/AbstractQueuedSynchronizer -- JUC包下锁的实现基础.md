AbstractQueuedSynchronizer -- JUC包下锁的实现基础



- 继承实现关系

  > 继承了***AbstractOwnableSynchronizer***，但是这个类其实是个独占同步器的空壳标准作为同步器的基础，并不提供任何实现。

- 类变量

  ```java
      private static final Unsafe unsafe = Unsafe.getUnsafe();
      private static final long stateOffset;
      private static final long headOffset;
      private static final long tailOffset;
      private static final long waitStatusOffset;
      private static final long nextOffset;

   static {
          try {
              stateOffset = unsafe.objectFieldOffset
                  (AbstractQueuedSynchronizer.class.getDeclaredField("state"));
              headOffset = unsafe.objectFieldOffset
                  (AbstractQueuedSynchronizer.class.getDeclaredField("head"));
              tailOffset = unsafe.objectFieldOffset
                  (AbstractQueuedSynchronizer.class.getDeclaredField("tail"));
              waitStatusOffset = unsafe.objectFieldOffset
                  (Node.class.getDeclaredField("waitStatus"));
              nextOffset = unsafe.objectFieldOffset
                  (Node.class.getDeclaredField("next"));

          } catch (Exception ex) { throw new Error(ex); }
      }
  ```

  主要是一些与CAS相关静态参数，在类初始化块里进行初始化

  ******

  - 成员变量

  ```
      /**
       * Head of the wait queue, lazily initialized.  Except for
       * initialization, it is modified only via method setHead.  Note:
       * If head exists, its waitStatus is guaranteed not to be
       * CANCELLED.头节点
       */
      private transient volatile Node head;

      /**
       * Tail of the wait queue, lazily initialized.  Modified only via
       * method enq to add new wait node.尾节点
       */
      private transient volatile Node tail;

      /**
       * The synchronization state.重要的成员变量，同步状态
       */
      private volatile int state;
  ```

  ******

  - 重要的内部静态类Node

  ```
      static final class Node {
          /** Marker to indicate a node is waiting in shared mode */
          static final Node SHARED = new Node();
          /** Marker to indicate a node is waiting in exclusive mode */
          static final Node EXCLUSIVE = null;

          /** waitStatus value to indicate thread has cancelled */
          static final int CANCELLED =  1;
          /** waitStatus value to indicate successor's thread needs unparking */
          static final int SIGNAL    = -1;
          /** waitStatus value to indicate thread is waiting on condition */
          static final int CONDITION = -2;
          /**
           * waitStatus value to indicate the next acquireShared should
           * unconditionally propagate
           */
          static final int PROPAGATE = -3;

          /**
           * Status field, taking on only the values:
           *   SIGNAL:     The successor of this node is (or will soon be)
           *               blocked (via park), so the current node must
           *               unpark its successor when it releases or
           *               cancels. To avoid races, acquire methods must
           *               first indicate they need a signal,
           *               then retry the atomic acquire, and then,
           *               on failure, block.
           *   CANCELLED:  This node is cancelled due to timeout or interrupt.
           *               Nodes never leave this state. In particular,
           *               a thread with cancelled node never again blocks.
           *   CONDITION:  This node is currently on a condition queue.
           *               It will not be used as a sync queue node
           *               until transferred, at which time the status
           *               will be set to 0. (Use of this value here has
           *               nothing to do with the other uses of the
           *               field, but simplifies mechanics.)
           *   PROPAGATE:  A releaseShared should be propagated to other
           *               nodes. This is set (for head node only) in
           *               doReleaseShared to ensure propagation
           *               continues, even if other operations have
           *               since intervened.
           *   0:          None of the above
           *
           * The values are arranged numerically to simplify use.
           * Non-negative values mean that a node doesn't need to
           * signal. So, most code doesn't need to check for particular
           * values, just for sign.
           *
           * The field is initialized to 0 for normal sync nodes, and
           * CONDITION for condition nodes.  It is modified using CAS
           * (or when possible, unconditional volatile writes).
           */
          volatile int waitStatus;

          /**
           * Link to predecessor node that current node/thread relies on
           * for checking waitStatus. Assigned during enqueuing, and nulled
           * out (for sake of GC) only upon dequeuing.  Also, upon
           * cancellation of a predecessor, we short-circuit while
           * finding a non-cancelled one, which will always exist
           * because the head node is never cancelled: A node becomes
           * head only as a result of successful acquire. A
           * cancelled thread never succeeds in acquiring, and a thread only
           * cancels itself, not any other node.
           */
          volatile Node prev;

          /**
           * Link to the successor node that the current node/thread
           * unparks upon release. Assigned during enqueuing, adjusted
           * when bypassing cancelled predecessors, and nulled out (for
           * sake of GC) when dequeued.  The enq operation does not
           * assign next field of a predecessor until after attachment,
           * so seeing a null next field does not necessarily mean that
           * node is at end of queue. However, if a next field appears
           * to be null, we can scan prev's from the tail to
           * double-check.  The next field of cancelled nodes is set to
           * point to the node itself instead of null, to make life
           * easier for isOnSyncQueue.
           */
          volatile Node next;

          /**
           * The thread that enqueued this node.  Initialized on
           * construction and nulled out after use.
           */
          volatile Thread thread;

          /**
           * Link to next node waiting on condition, or the special
           * value SHARED.  Because condition queues are accessed only
           * when holding in exclusive mode, we just need a simple
           * linked queue to hold nodes while they are waiting on
           * conditions. They are then transferred to the queue to
           * re-acquire. And because conditions can only be exclusive,
           * we save a field by using special value to indicate shared
           * mode.
           */
          Node nextWaiter;

          /**
           * Returns true if node is waiting in shared mode.
           */
          final boolean isShared() {
              return nextWaiter == SHARED;
          }

          /**
           * Returns previous node, or throws NullPointerException if null.
           * Use when predecessor cannot be null.  The null check could
           * be elided, but is present to help the VM.
           *
           * @return the predecessor of this node
           */
          final Node predecessor() throws NullPointerException {
              Node p = prev;
              if (p == null)
                  throw new NullPointerException();
              else
                  return p;
          }

          Node() {    // Used to establish initial head or SHARED marker
          }

          Node(Thread thread, Node mode) {     // Used by addWaiter
              this.nextWaiter = mode;
              this.thread = thread;
          }

          Node(Thread thread, int waitStatus) { // Used by Condition
              this.waitStatus = waitStatus;
              this.thread = thread;
          }
      }
  ```

******

> 到这里先停一下，不妨先写一个最简单的ReentrantLock demo来跟踪一下AQS在其中起到的作用，再带着目的去看相关的代码，测试demo如下：
>
> ReentrantLock lock = new ReentrantLock(true);
>
> lock.lock();
>
> lock.unlock();

- lock()

  这里用的是公平同步锁，所以是聚合的子类FairSync来实现的，调用lock方法的时候，跳到了AQS的这里：

  ```
   public final void acquire(int arg) {
          if (!tryAcquire(arg) &&
              acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
              selfInterrupt();
      }
  ```

  跳进tryAcquire()发现这是个在AQS里未实现的方法（抛出UnsupportException），继续debug，可以发现其实是跳到了FairSync的tyrAcquire()去执行，即是需要子类去实现，另外，公平锁和非公平锁的区别就是这里，ReentrantLock的非公平锁在这里是调用***nonfairTryAcquire()（见本页最后）***去实现的：

  ```
   protected final boolean tryAcquire(int acquires) {
              final Thread current = Thread.currentThread();
              int c = getState();//注意这里1
              if (c == 0) {
                  if (!hasQueuedPredecessors() &&
                      compareAndSetState(0, acquires)) {
                      setExclusiveOwnerThread(current);
                      return true;//注意这里2
                  }
              }
              else if (current == getExclusiveOwnerThread()) {//注意这里3
                  int nextc = c + acquires;
                  if (nextc < 0)
                      throw new Error("Maximum lock count exceeded");
                  setState(nextc);
                  return true;
              }
              return false;
          }
      }
  ```

  上面代码里有一段是获取getState()的代码：

  ```
      protected final int getState() {
          return state;
      }
  ```

  注意1：其实这是AQS的方法，直接获取成员变量state;

  注意2：如果state为0，直接尝试cas操作，把state置为申请的那个数字，如果成功，置当前线程为独占线程，并且返	  回true。那么，可以先理解state为一个判断当前锁是否被一个线程持有的标志位。

  注意3：其实这个就是重入锁了的重入所在了。。

  上诉方法返回true的话，一次锁申请已经结束了。



​	如果此时上诉方法返回false，就要加入等待队列了：

```
acquireQueued(addWaiter(Node.EXCLUSIVE), arg)
```

​	其实就是加入等待队列addWaiter:

```
 private Node addWaiter(Node mode) {
        Node node = new Node(Thread.currentThread(), mode);
        // Try the fast path of enq; backup to full enq on failure
        Node pred = tail;
        if (pred != null) {
            node.prev = pred;
            if (compareAndSetTail(pred, node)) {//注意这里1
                pred.next = node;
                return node;
            }
        }
        enq(node);//注意这里2
        return node;
    }
```

1.如果无竞争直接cas入队成功

2.如果由竞争，进入enq()进行自旋入队

```
 private Node enq(final Node node) {
        for (;;) {
            Node t = tail;
            if (t == null) { // Must initialize
                if (compareAndSetHead(new Node()))
                    tail = head;
            } else {
                node.prev = t;
                if (compareAndSetTail(t, node)) {
                    t.next = node;
                    return t;
                }
            }
        }
    }
```

就是一个cas操作，直到成功。



入队成功后就是尝试出队获取到独占锁了，出队列方法如下：

```
  final boolean acquireQueued(final Node node, int arg) {
        boolean failed = true;
        try {
            boolean interrupted = false;
            for (;;) {
                final Node p = node.predecessor();
                if (p == head && tryAcquire(arg)) {//又是tryAcquire方法,上面已经解析过这个方法了
                    setHead(node);
                    p.next = null; // help GC
                    failed = false;
                    return interrupted;
                }
                if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())//注意1
                    interrupted = true;
            }
        } finally {
            if (failed)
                cancelAcquire(node);//注意这里2
        }
    }
```

1.如果一次尝试出队失败，那么进入检查是否应该被挂起，检查当前的状态，比如可能会出现等不急出队了，就是获取状态被取消了。

如果当前节点的前驱节点(predcessor)不是头节点，且满足挂起条件。当前出队线程被挂起，那么问题来了，当前线程被挂起后是谁来通知它到时间去唤醒尝试出队呢？

2.来看finally方法，cancelAcquire(Node node)方法里面有个重要的方法，来唤醒继承节点（就是后驱节点）。并且如果当前节点已经是头节点了，如果它获取锁失败(非公平锁的情况下可能出现)那么它是不可以被休眠的，因为它一旦休眠，就再也没人能唤醒整个队列了，gg解决上面的那个疑问了。

```
   /**
     * Wakes up node's successor, if one exists.
     *
     * @param node the node
     */
    private void unparkSuccessor(Node node) {
        /*
         * If status is negative (i.e., possibly needing signal) try
         * to clear in anticipation of signalling.  It is OK if this
         * fails or if status is changed by waiting thread.
         */
        int ws = node.waitStatus;
        if (ws < 0)
            compareAndSetWaitStatus(node, ws, 0);

        /*
         * Thread to unpark is held in successor, which is normally
         * just the next node.  But if cancelled or apparently null,
         * traverse backwards from tail to find the actual
         * non-cancelled successor.
         */
        Node s = node.next;
        if (s == null || s.waitStatus > 0) {
            s = null;
            for (Node t = tail; t != null && t != node; t = t.prev)
                if (t.waitStatus <= 0)
                    s = t;
        }
        if (s != null)
            LockSupport.unpark(s.thread);
    }
```



> 所以申请锁的过程就是---> 当state为0的时候，尝试获取独占锁，如果失败，加入等待队列，然后继续尝试自旋转获取。
>
> 这里tryAcquire是由AQS的子类去实现的。

- unlock()

```
  protected final boolean tryRelease(int releases) {
            int c = getState() - releases;
            if (Thread.currentThread() != getExclusiveOwnerThread())
                throw new IllegalMonitorStateException();
            boolean free = false;
            if (c == 0) {
                free = true;
                setExclusiveOwnerThread(null);
            }
            setState(c);
            return free;
        }
```

> 释放锁的过程平淡无奇。。。



```
 protected final boolean tryAcquire(int acquires) {
            final Thread current = Thread.currentThread();
            int c = getState();
            if (c == 0) {
                if (!hasQueuedPredecessors() &&
                    compareAndSetState(0, acquires)) {
                    setExclusiveOwnerThread(current);
                    return true;
                }
            }
            else if (current == getExclusiveOwnerThread()) {
                int nextc = c + acquires;
                if (nextc < 0)
                    throw new Error("Maximum lock count exceeded");
                setState(nextc);
                return true;
            }
            return false;
        }
    }
```



- 非公平锁的tryAcquire()的实现：

```
final boolean nonfairTryAcquire(int acquires) {
            final Thread current = Thread.currentThread();
            int c = getState();
            if (c == 0) {
                if (compareAndSetState(0, acquires)) {//注意这里1
                    setExclusiveOwnerThread(current);
                    return true;
                }
            }
            else if (current == getExclusiveOwnerThread()) {
                int nextc = c + acquires;
                if (nextc < 0) // overflow
                    throw new Error("Maximum lock count exceeded");
                setState(nextc);
                return true;
            }
            return false;
        }
```

1.对比公平锁的tryAcquire，可以清楚地看到，非公平锁在尝试获取锁的时候，不会去判断***hasQueuedPredecessors()***，直接就取尝试独占state，失败了才去入队乖乖按照fifo来获取锁。

所以一个非公平锁，不管等待队列由多少，一旦申请锁，那个申请锁的线程和队列等待的头节点有一样的机会可以获取到锁。



> 所以AbstractQueueSynchronizer的精髓就是维护一个state(int)，独占线程exclusiveOwnerThread(AbstractOwnableSynchronizer的成员变量)，Head节点(Node)一个等待队列(Node)。
>
> 公平锁：获取锁-->检查是否有等待队列，无----尝试获取独占锁(state,exclusiveOwnerThread)--->失败，入队等待获取锁---->满足挂起条件，挂起，出队获取到锁的那个节点，唤醒后驱节点取获取锁。
>
> 非公平锁：差别就是获取锁的那里不去检查是否由等待队列。(tryAcquire()的实现的不同)



### Condition 还有一个重要的功能就是Condition

condition的功能就是用来替代Object的wait监视器功能的，典型用法如下：

```
ReentrantLock lock = new ReentrantLock(false);
lock.lock();
Condition condition = lock.newCondition();
condition.await();//必须先获取监视器lock再await();注意这里1

然后另外一个持有同样的condition(必须是同一个condition才可以唤醒)
condtion.singnal();//注意这里2
```

1. 首先，一个已经获取锁的线程是独占了AQS的status和AOS的exclusiveThread，调用await方法的时候，会检查是否是独占线程--->加入同一个Condition对象(持有first，last节点Node)的等待队列，然后释放调用ASQ的release方法释放掉独占锁，然后LockSupport休眠;（见await代码）
2. 由1可知，同一个Condition对象上一个Node节点代表的就是一个等待线程，调用signal同样要先获取到lock监视器，然后找到下一个需要唤醒的节点，让这个节点入队，没错，就是入队，入到AQS的等待队列，然后直接唤醒(见下面***注意3***)，这也就解释了为什么一个await()后唤醒的线程需要重新获取到监视器。
3. 另外，重入锁还支持**TimeWait**，是通过**LockSupport.parkNanos()**实现等待超时的，并且如果在等待超时未到时，前驱节点变成了头节点，那么就会被提前**唤醒**去竞争锁;
4. 可中断是指在**api层面自旋竞争时**和**LockSupport**等待里可中断;
5. 另外，使用ReentrantLock类工具一定要记得在finally里释放锁，释放锁，不然就要死锁了。。

```
//await代码
public final void await() throws InterruptedException {
            if (Thread.interrupted())
                throw new InterruptedException();
            Node node = addConditionWaiter();
            int savedState = fullyRelease(node);//往下调用的是tryRelease()方法，在这里就已经解除独占status和exclusiveThread了
            int interruptMode = 0;
            while (!isOnSyncQueue(node)) {
                LockSupport.park(this);//挂起线程
                if ((interruptMode = checkInterruptWhileWaiting(node)) != 0)
                    break;
            }
            if (acquireQueued(node, savedState) && interruptMode != THROW_IE)//尝试重新获取锁
                interruptMode = REINTERRUPT;
            if (node.nextWaiter != null) // clean up if cancelled
                unlinkCancelledWaiters();
            if (interruptMode != 0)
                reportInterruptAfterWait(interruptMode);
        }
```



```
//唤醒的代码
final boolean transferForSignal(Node node) {
        /*
         * If cannot change waitStatus, the node has been cancelled.
         */
        if (!compareAndSetWaitStatus(node, Node.CONDITION, 0))
            return false;

        /*
         * Splice onto queue and try to set waitStatus of predecessor to
         * indicate that thread is (probably) waiting. If cancelled or
         * attempt to set waitStatus fails, wake up to resync (in which
         * case the waitStatus can be transiently and harmlessly wrong).
         */
        Node p = enq(node);//唤醒锁的地方，入队
        int ws = p.waitStatus;
        if (ws > 0 || !compareAndSetWaitStatus(p, ws, Node.SIGNAL))
            LockSupport.unpark(node.thread);//唤醒获取锁 注意3
        return true;
    }
```

