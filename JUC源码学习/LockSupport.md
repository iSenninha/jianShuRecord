### LockSupport

**LockSupport**的用法非常简单，需要注意的是带参数的**blocker**并不是一个独占锁，**即是多个线程可以同时用一个blocker去执行park**而只是用来追踪记录线程挂起的一个线索,这点在JDK的文档中有说明:
> The three forms of park each also support a blocker object parameter. This object is recorded while the thread is blocked to permit monitoring and diagnostic tools to identify the reasons that threads are blocked. (Such tools may access blockers using method getBlocker(java.lang.Thread).) The use of these forms rather than the original forms without this parameter is strongly encouraged. The normal argument to supply as a blocker within a lock implementation is this.

如上，并且官方推荐用**this**作为**blocker**。这个blocker其实就是**Thread**中的成员变量，可以通过**LockSupport#getBlocker(Thread)**获取。
