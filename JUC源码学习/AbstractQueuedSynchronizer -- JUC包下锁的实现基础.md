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

  跳进tryAcquire()发现这是个在AQS里未实现的方法（抛出UnsupportException），继续debug，可以发现其实是跳到了FairSync的tyrAcquire()去执行，即是需要子类去实现：

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

​	其实就是加入等待队列addWaiter，并且一直自旋等待出队列。出队列方法如下：

```
  final boolean acquireQueued(final Node node, int arg) {
        boolean failed = true;
        try {
            boolean interrupted = false;
            for (;;) {
                final Node p = node.predecessor();
                if (p == head && tryAcquire(arg)) {//又是tryAcquire方法
                    setHead(node);
                    p.next = null; // help GC
                    failed = false;
                    return interrupted;
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

> 所以申请锁的过程就是---> 当state为0的时候，尝试获取独占锁，如果失败，加入等待队列，然后继续尝试自旋转获取。(这里面等待节点的休眠和唤醒没有写，这个还没理解到。。)。
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