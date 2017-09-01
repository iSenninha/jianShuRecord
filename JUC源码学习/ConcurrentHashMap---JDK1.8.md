### ConcurrentHashMap---JDK1.8

> JDK1.8里面的ConcurrentHashMap并不是用分段的思想去处理并发的，而是通过**CAS** + **Synchronized**的方式实现并发操作的。

- 线程不安全在哪里？

  首先思考一下HashMap为什么线程不安全？

  1. 放入桶的时候无法保证线程安全，可能出现A线程先放入AD进桶1，但是B线程又把BD放入了桶1，直接覆盖了前者的操作;
  2. 更糟糕的是并发扩容的时候，HashMap会造成循环链表，导致彻底gg不工作。



- 那么ConcurrentHashMap是如何处理这个问题的？

  1. 首先对于问题1,是采用**CAS**+ **自旋操作**来保证入桶的正确性;

  2. 对于扩容时候的安全性问题，采用更巧妙的并发扩容来加速扩容过程。

     这里的并发扩容，并发指的是从**旧的桶里复制到新桶**是并发的，新建桶的这个过程并不是**并发**的



- 先来分析入桶的正确性

```
final V putVal(K key, V value, boolean onlyIfAbsent) {
        if (key == null || value == null) throw new NullPointerException();
        int hash = spread(key.hashCode());//散列
        int binCount = 0;
        for (Node<K,V>[] tab = table;;) {//1.自旋操作
            Node<K,V> f; int n, i, fh;
            if (tab == null || (n = tab.length) == 0)
                tab = initTable();
            else if ((f = tabAt(tab, i = (n - 1) & hash)) == null) {//2.为空马上尝试插入
                if (casTabAt(tab, i, null,
                             new Node<K,V>(hash, key, value, null)))
                    break;                   // no lock when adding to empty bin
            }
            else if ((fh = f.hash) == MOVED)//3.发现是MOVED状态，有别的线程在扩容，帮助扩容
                tab = helpTransfer(tab, f);
            else {//4.发生碰撞的时候放入链表或树
                V oldVal = null;
                synchronized (f) {
                    if (tabAt(tab, i) == f) {
                        if (fh >= 0) {
                            binCount = 1;
                            for (Node<K,V> e = f;; ++binCount) {
                                K ek;
                                if (e.hash == hash &&
                                    ((ek = e.key) == key ||
                                     (ek != null && key.equals(ek)))) {
                                    oldVal = e.val;
                                    if (!onlyIfAbsent)
                                        e.val = value;
                                    break;
                                }
                                Node<K,V> pred = e;
                                if ((e = e.next) == null) {
                                    pred.next = new Node<K,V>(hash, key,
                                                              value, null);
                                    break;
                                }
                            }
                        }
                        else if (f instanceof TreeBin) {
                            Node<K,V> p;
                            binCount = 2;
                            if ((p = ((TreeBin<K,V>)f).putTreeVal(hash, key,
                                                           value)) != null) {
                                oldVal = p.val;
                                if (!onlyIfAbsent)
                                    p.val = value;
                            }
                        }
                    }
                }
                if (binCount != 0) {
                    if (binCount >= TREEIFY_THRESHOLD)
                        treeifyBin(tab, i);
                    if (oldVal != null)
                        return oldVal;
                    break;
                }
            }
        }
        addCount(1L, binCount);//5检查扩容
        return null;
    }
```

> 1.自旋操作
>
> ​	2.未空马上尝试插入，失败返回1自旋;
>
> ​	3.发现其他线程在扩容，帮助扩容，扩容完成继续回去1;
>
> ​	4.发现非空，找到插入的地方，cas插入，失败继续回1自旋;
>
> 5.入桶成功后检查扩容



- 下面来看扩容

  ```
      private final void transfer(Node<K,V>[] tab, Node<K,V>[] nextTab) {
          int n = tab.length, stride;
          if ((stride = (NCPU > 1) ? (n >>> 3) / NCPU : n) < MIN_TRANSFER_STRIDE)
              stride = MIN_TRANSFER_STRIDE; // subdivide range
          if (nextTab == null) {            // initiating
              try {
                  @SuppressWarnings("unchecked")
                  Node<K,V>[] nt = (Node<K,V>[])new Node<?,?>[n << 1];
                  nextTab = nt;
              } catch (Throwable ex) {      // try to cope with OOME
                  sizeCtl = Integer.MAX_VALUE;
                  return;
              }
              nextTable = nextTab;
              transferIndex = n;
          }
          int nextn = nextTab.length;
          ForwardingNode<K,V> fwd = new ForwardingNode<K,V>(nextTab);
          boolean advance = true;
          boolean finishing = false; // to ensure sweep before committing nextTab
          for (int i = 0, bound = 0;;) {
              Node<K,V> f; int fh;
              while (advance) {
                  int nextIndex, nextBound;
                  if (--i >= bound || finishing)
                      advance = false;
                  else if ((nextIndex = transferIndex) <= 0) {
                      i = -1;
                      advance = false;
                  }
                  else if (U.compareAndSwapInt
                           (this, TRANSFERINDEX, nextIndex,
                            nextBound = (nextIndex > stride ?
                                         nextIndex - stride : 0))) {
                      bound = nextBound;
                      i = nextIndex - 1;
                      advance = false;
                  }
              }
              if (i < 0 || i >= n || i + n >= nextn) {
                  int sc;
                  if (finishing) {//**完成了数据转移，返回
                      nextTable = null;
                      table = nextTab;
                      sizeCtl = (n << 1) - (n >>> 1);
                      return;
                  }
                  if (U.compareAndSwapInt(this, SIZECTL, sc = sizeCtl, sc - 1)) {
                      if ((sc - 2) != resizeStamp(n) << RESIZE_STAMP_SHIFT)
                          return;
                      finishing = advance = true;
                      i = n; // recheck before commit
                  }
              }
              else if ((f = tabAt(tab, i)) == null)//1.如果当前桶为空，置为ForwardNode，好让put线程知道
                  advance = casTabAt(tab, i, null, fwd);
              else if ((fh = f.hash) == MOVED)//2.发现是ForwardNode状态，继续
                  advance = true; // already processed
              else {
                  synchronized (f) {//3.开始迁移
                      if (tabAt(tab, i) == f) {//4.链表的情况
                          Node<K,V> ln, hn;
                          if (fh >= 0) {
                              int runBit = fh & n;
                              Node<K,V> lastRun = f;
                              for (Node<K,V> p = f.next; p != null; p = p.next) {
                                  int b = p.hash & n;
                                  if (b != runBit) {
                                      runBit = b;
                                      lastRun = p;
                                  }
                              }
                              if (runBit == 0) {
                                  ln = lastRun;
                                  hn = null;
                              }
                              else {
                                  hn = lastRun;
                                  ln = null;
                              }
                              for (Node<K,V> p = f; p != lastRun; p = p.next) {
                                  int ph = p.hash; K pk = p.key; V pv = p.val;
                                  if ((ph & n) == 0)
                                      ln = new Node<K,V>(ph, pk, pv, ln);/
                                  else
                                      hn = new Node<K,V>(ph, pk, pv, hn);
                              }
                              setTabAt(nextTab, i, ln);
                              setTabAt(nextTab, i + n, hn);
                              setTabAt(tab, i, fwd);
                              advance = true;
                          }
                          else if (f instanceof TreeBin) {5.treebin的情况
                              TreeBin<K,V> t = (TreeBin<K,V>)f;
                              TreeNode<K,V> lo = null, loTail = null;
                              TreeNode<K,V> hi = null, hiTail = null;
                              int lc = 0, hc = 0;
                              for (Node<K,V> e = t.first; e != null; e = e.next) {
                                  int h = e.hash;
                                  TreeNode<K,V> p = new TreeNode<K,V>
                                      (h, e.key, e.val, null, null);
                                  if ((h & n) == 0) {
                                      if ((p.prev = loTail) == null)
                                          lo = p;
                                      else
                                          loTail.next = p;
                                      loTail = p;
                                      ++lc;
                                  }
                                  else {
                                      if ((p.prev = hiTail) == null)
                                          hi = p;
                                      else
                                          hiTail.next = p;
                                      hiTail = p;
                                      ++hc;
                                  }
                              }
                              ln = (lc <= UNTREEIFY_THRESHOLD) ? untreeify(lo) :
                                  (hc != 0) ? new TreeBin<K,V>(lo) : t;
                              hn = (hc <= UNTREEIFY_THRESHOLD) ? untreeify(hi) :
                                  (lc != 0) ? new TreeBin<K,V>(hi) : t;
                              setTabAt(nextTab, i, ln);
                              setTabAt(nextTab, i + n, hn);
                              setTabAt(tab, i, fwd);
                              advance = true;
                          }
                      }
                  }
              }
          }
      }
  ```

  > 首先，这个方法传入了原来的Node[]节点(**table**)和新的两倍于原来的Node[]节点(**nextTable**)。
  >
  > 1.如果原来节点为空，置为ForwoardingNode，带有指向当前nextTable的引用
  >
  > 2.如果为forwardingNode，跳过这个节点，继续向前;（并发迁移数据的妙用）
  >
  > 3.如果不为空
  >
  > ​	4.如果为链表，根据 **&** 原来的**talbe.length**，分出两类，一类是不用挪动位置的，一类是要挪动（+n）  	位置的节点(&结果为1的话)，hashMap也是根据这种方式来迁移数据的
  >
  > ​	5.如果是树的话，也是以上的迁移策略
  >
  > **最后迁移完毕后把table引用为nexttable，然后nexttable置为空

  - 再来看put的时候的helpTransfer

    > put的时候，如果发现桶是ForwardingNode，就去帮助迁移数据

  - get方法

  ```
      public V get(Object key) {
          Node<K,V>[] tab; Node<K,V> e, p; int n, eh; K ek;
          int h = spread(key.hashCode());
          if ((tab = table) != null && (n = tab.length) > 0 &&
              (e = tabAt(tab, (n - 1) & h)) != null) {
              if ((eh = e.hash) == h) {
                  if ((ek = e.key) == key || (ek != null && key.equals(ek)))
                      return e.val;
              }
              else if (eh < 0)//1.如果<0
                  return (p = e.find(h, key)) != null ? p.val : null;
              while ((e = e.next) != null) {
                  if (e.hash == h &&
                      ((ek = e.key) == key || (ek != null && key.equals(ek))))
                      return e.val;
              }
          }
          return null;
      }
  ```

  > 1.小于0的情况，可能是因为是棵树，也有可能此时正在扩容，这里放着的是ForwardingNode，看看ForwardingNode的find方法，这样就可以实现扩容下的寻找了：
  >
  > ```
  >    Node<K,V> find(int h, Object k) {
  >             // loop to avoid arbitrarily deep recursion on forwarding nodes
  >             outer: for (Node<K,V>[] tab = nextTable;;) {1.这里的nextTable是扩容后的
  >                 Node<K,V> e; int n;
  >                 if (k == null || tab == null || (n = tab.length) == 0 ||
  >                     (e = tabAt(tab, (n - 1) & h)) == null)
  >                     return null;
  >                 for (;;) {
  >                     int eh; K ek;
  >                     if ((eh = e.hash) == h &&
  >                         ((ek = e.key) == k || (ek != null && k.equals(ek))))
  >                         return e;
  >                     if (eh < 0) {
  >                         if (e instanceof ForwardingNode) {
  >                             tab = ((ForwardingNode<K,V>)e).nextTable;
  >                             continue outer;
  >                         }
  >                         else
  >                             return e.find(h, k);
  >                     }
  >                     if ((e = e.next) == null)
  >                         return null;
  >                 }
  >             }
  >         }
  > ```
  >
  > ​

  ​