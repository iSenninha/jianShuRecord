### AbstractQueuedSynchronizer -- JUC包下锁的实现基础



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
       * The synchronization state.同步状态
       */
      private volatile int state;
  ```

  ​