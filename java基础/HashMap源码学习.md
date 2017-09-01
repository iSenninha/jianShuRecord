####HashMap源码学习

hashmap基本原理以及结构
1.通过hash算法把存入的key-value放到一个数组里,这个数组是HashMap的内部静态类Node
2.Node类里有这个类的key,value,hash值和下一个Node(用于拉链法解决冲突)
3.hash避免碰撞以及碰撞处理

#####1.初始化
构造初始化空间
```
 static final int tableSizeFor(int cap) {
        int n = cap - 1;
        n |= n >>> 1;
        n |= n >>> 2;
        n |= n >>> 4;
        n |= n >>> 8;
        n |= n >>> 16;
        return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
    }
```
这个算法可以求出近似cap大小的但是满足是2的指数次方的那个值
如果cap是9(1001)那么经过这个移位运算后是1111加1即是10000是2的4次方

那么问题来了,为什么要追求cap是2的次方呢?因为在散列到数组的时候需要定位位置,如果用求余的话运算消耗太大,如果是2的整数次方,求余数可以转化为
> cap & hash
> 这样就可以通过与运算来求余,核心是将数组长度转化为二进制数时只能有一个位是1.然后它减去1就是全一的了,就可以用来求余了

构造hash值
>         return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);

一些关键的初始化值
>int threshold;             // 所能容纳的key-value对极限 
>final float loadFactor;    // 负载因子 0.75,一般不要去修改
>int modCount;  //修改次数,fast-fail失败机制
>int size; //实际储存的key-value对

threshold = loadFactor * 数组长度


####2.放入值

```
 public V put(K key, V value) {
        return putVal(hash(key), key, value, false, true);
    }
```
这里的hash(K key) 函数叫扰动函数,代码如下:
```
//其实就是高低十六位做异或来避免在桶数组很小的情况下出现严重的碰撞
 static final int hash(Object key) {
        int h;
        return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
    }
```
jdk1.8在拉链长度大于8时会转换为红黑树
```
 final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        else {
            Node<K,V> e; K k;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
             //判断这个节点是不是红黑树
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            /该链为链表
            else {
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);
                        //如果链表长度大于8,转让为红黑树
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }
```

####3.取值
计算hash的散列值,然后求余获取位置,如果那个位置上的key对不上号,说明冲突了,这个时候的Node里的下一个node就起作用了,jdk1.8后使用了红黑树来解决冲突

####4.fast-fail机制(ConcurrentModificationException)
只有在同一个线程中遍历的时候修改才会导致fast-fail.因为modCount声明并不是volatile.比如a线程在遍历,b线程增加,由于modCount内存不可见,所以就算修改了对于a来说modCount仍然没变化.特地去搜索了一下,jdk1.6还是volatile的,1.7开始就不是了.
所以在多线程里的fast-fail基本就废了

####5.遍历
```
//iterator的过程,在构造函数中查找到数组里第一个不为null的node
 HashIterator() {
            expectedModCount = modCount;
            Node<K,V>[] t = table;
            current = next = null;
            index = 0;
            if (t != null && size > 0) { // advance to first entry
                do {} while (index < t.length && (next = t[index++]) == null);
            }
```

//next()的时候继续查找下一个节点在哪里
```
  final Node<K,V> nextNode() {
            Node<K,V>[] t;
            Node<K,V> e = next;
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
            if (e == null)
                throw new NoSuchElementException();
            //如果是链表的话,(红黑树),不进入dowhile循环获取下一个节点
            if ((next = (current = e).next) == null && (t = table) != null) {
                do {} while (index < t.length && (next = t[index++]) == null);
            }
            return e;
        }
```


####6.多线程造成死循环
resize扩容的时候会出现循环链表




总结
> (1) 扩容是一个特别耗性能的操作，所以当程序员在使用HashMap的时候，估算map的大小，初始化的时候给一个大致的数值，避免map进行频繁的扩容。
> (2) 负载因子是可以修改的，也可以大于1，但是建议不要轻易修改，除非情况非常特殊。
> (3) HashMap是线程不安全的，不要在并发的环境中同时操作HashMap，建议使用ConcurrentHashMap。
> (4) JDK1.8引入红黑树大程度优化了HashMap的性能。

参考[improtNew](http://www.importnew.com/20386.html)



#### 7.与HashTable的不同之处

1. HashMap自己重新计算哈希值：

   ```
   return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
   ```

2. 迭代的方式不同

   Hashtalbe使用的是Emunration方式

3. 确定槽的方式不同

   Hashtable还是使用**求余**的方式，并且扩容是:(oldCapacity << 1) + 1;

   而HashMap的槽位必须是2的幂次方，用**&**的方式求槽位

4. Hashtable方法加了**Synchronized**

   ​

