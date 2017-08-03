###ConcurrentLinkedQueue源码学习

> ConcurrentLinkedQueue是一个基于链表实现的高并发队列

&nbsp;

- 静态内部类Node
> 出现了重要的Unsafe类，Unsafe类提供了硬件级别的原子操作，CAS(Compare And Set)。
Node类有要储存的元素item，表示下一个节点的next，UNSAFE，以及表示item和next偏移地址的itemOffset和nextOffset，为cas操作提供支持
```
private static class Node<E> {
        volatile E item;
        volatile Node<E> next;

        /**
         * Constructs a new node.  Uses relaxed write because item can
         * only be seen after publication via casNext.
         */
        Node(E item) {
            UNSAFE.putObject(this, itemOffset, item);
        }

        boolean casItem(E cmp, E val) {
            return UNSAFE.compareAndSwapObject(this, itemOffset, cmp, val);
        }

	
        void lazySetNext(Node<E> val) {
            UNSAFE.putOrderedObject(this, nextOffset, val);
        }

        boolean casNext(Node<E> cmp, Node<E> val) {
            return UNSAFE.compareAndSwapObject(this, nextOffset, cmp, val);
        }

        // Unsafe mechanics

        private static final sun.misc.Unsafe UNSAFE;
        private static final long itemOffset;
        private static final long nextOffset;

	//类装载的时候完成
        static {
            try {
                UNSAFE = sun.misc.Unsafe.getUnsafe();
                Class<?> k = Node.class;
                itemOffset = UNSAFE.objectFieldOffset
                    (k.getDeclaredField("item"));
                nextOffset = UNSAFE.objectFieldOffset
                    (k.getDeclaredField("next"));
            } catch (Exception e) {
                throw new Error(e);
            }
        }
    }
```
&nbsp;

- 成员变量
```
Node<E> head;//头节点
Node<E> tail;//尾节点
//头和尾节点都不是空的，从初始化中可以
Unsafe UNSAFE; //这里也有一个unsafe类，有Unsafe自然有偏移地址
long headOffset;
long tailOffset; 
```

&nbsp;

- 构造方法以及初始化
```
//构造函数中初始化head和tail节点
 public ConcurrentLinkedQueue() {
        head = tail = new Node<E>(null);
    }

//初始化Unsafe相关，提供机器级别的原子操作
    static {
        try {
            UNSAFE = sun.misc.Unsafe.getUnsafe();
            Class<?> k = ConcurrentLinkedQueue.class;
            headOffset = UNSAFE.objectFieldOffset
                (k.getDeclaredField("head"));
            tailOffset = UNSAFE.objectFieldOffset
                (k.getDeclaredField("tail"));
        } catch (Exception e) {
            throw new Error(e);
        }
    }

```
&nbsp;

- 入队方法
```
//不像实现了Blocking接口的阻塞队列，这里的offer方法，会一直自旋尝试入队，直到入队成功
public boolean offer(E e) {
        checkNotNull(e);//入队元素不能为空
        final Node<E> newNode = new Node<E>(e);

	//进入自旋cas操作
        for (Node<E> t = tail, p = t;;) {
            Node<E> q = p.next;
            if (q == null) {//q==null，说明到了可以入队的位置
                // p is last node
                if (p.casNext(null, newNode)) {//cas尝试入队，若失败，继续找适合入队的下一个位置
                    // Successful CAS is the linearization point
                    // for e to become an element of this queue,
                    // and for newNode to become "live".
                    if (p != t) // 入队成功后，如果没经过自旋入队的话，必然有p==t
                        casTail(t, newNode);  // 尝试设置尾节点， 即使失败，也不会去尝试自旋设置，因为可能是其他线程成功设置了尾节点
                    return true;
                }
                // Lost CAS race to another thread; re-read next
            }
            else if (p == q)/没搞清楚为什么会出现p==q的情况。出现了循环链表？？？应该是updateHead(见poll方法)的时候可能出现指向自己的节点
                // We have fallen off list.  If tail is unchanged, it
                // will also be off-list, in which case we need to
                // jump to head, from which all live nodes are always
                // reachable.  Else the new tail is a better bet.
                p = (t != (t = tail)) ? t : head;//如果t节点不等于尾节点，p设置为尾节点，否则设置为头节点
            else
                // Check for tail updates after two hops.
                p = (p != t && t != (t = tail)) ? t : q;//到这里说明当前自旋的tail节点已经落后于队列实际的尾节点了，重新赋值p节点
        }
    }
```
> 从源码里可以看出来，一次入队，先把tail变量的方法体保存在方法内，然后不断尝试找到可以入队的位置去尝试入队。如果是一次入队，是不会去尝试修改tail节点的，只有经过了自旋入队的才会去尝试修改tail节点，并且修改tail节点失败的话，很有可能是别的线程成功修改了tail节点，尝试一次就退出的。
从入队代码也可以看出，入队的时候是不会把元素存在头节点的，但是不意味着头节点一直不保存元素

&nbsp;

- 出队方法
```
public E poll() {
        restartFromHead:
        for (;;) {
            for (Node<E> h = head, p = h, q;;) {
                E item = p.item;
		//item != null，找到出队点，尝试cas出队
                if (item != null && p.casItem(item, null)) {
                    // Successful CAS is the linearization point
                    // for item to be removed from this queue.
                    if (p != h) //如果头节点滞后了，尝试更新头节点，并且把原来的头节点的next指向自己
                        updateHead(h, ((q = p.next) != null) ? q : p);
                    return item;
                }
                else if ((q = p.next) == null) {//next节点为空，说明队列为空了，更新一下头节点
                    updateHead(h, p);
                    return null;//返回null
                }
                else if (p == q)//p=q情况，updateHead()的情况会出现把出队的节点的next指向自己
                    continue restartFromHead;
                else
                    p = q;//到这里是正常自旋尝试出队的
            }
        }
    }
```
> 出队的方法也是，从head节点开始定位，如果head节点滞后了或者不满足条件，自旋寻找下一个满足条件的节点，并且在出队函数返回前可能需要更新head节点。
把出队后的节点的next指向自己。帮助gc

&nbsp;

- peek方法
```
 public E peek() {
        restartFromHead:
        for (;;) {
            for (Node<E> h = head, p = h, q;;) {
                E item = p.item;
                if (item != null || (q = p.next) == null) {
                    updateHead(h, p);
                    return item;
                }
                else if (p == q)
                    continue restartFromHead;
                else
                    p = q;
            }
        }
    }
```
> 从头节点开始自旋寻找item不为null的节点

&nbsp;

- remove方法
```
 public boolean remove(Object o) {
        if (o != null) {
            Node<E> next, pred = null;
            for (Node<E> p = first(); p != null; pred = p, p = next) {
                boolean removed = false;
                E item = p.item;
                if (item != null) {
                    if (!o.equals(item)) {
                    	//不等的话，寻找下一个节点，succ()方法见下：
                        next = succ(p);
                        continue;//再继续从新的节点开始往下寻找
                    }
                    removed = p.casItem(item, null);//cas移除
                }

                next = succ(p);//寻找下一个
                if (pred != null && next != null) // unlink
                    pred.casNext(p, next);//把pred节点的next设置为next，因为移除了一个节点
                    //这里比较疑惑的是，本来这个unlink的行为应该是remove成功的那个线程去执行的
                if (removed)
                //把它转移到这里不是更合适？
                    return true;
            }
        }
        return false;
    }
    
    //寻找继承者，如果p的next指向自己了，就只能找头节点当它的继承者了。
     final Node<E> succ(Node<E> p) {
        Node<E> next = p.next;
        return (p == next) ? head : next;
    }

```


> 好吧，到这里已经开始看不太懂了，无锁的cas算法确实比较蛋疼。。。。
