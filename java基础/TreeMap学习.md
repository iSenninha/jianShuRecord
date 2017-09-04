### TreeMap学习

> **TreeMap**以**红黑树**作为储存结构，由于红黑树的性质，可以做到按**key**的大小排序来作为**迭代**的时候的顺序

- 静态内部类

```
static final class Entry<K,V> implements Map.Entry<K,V> {
		/** 红黑树节点
        K key;
        V value;
        Entry<K,V> left;
        Entry<K,V> right;
        Entry<K,V> parent;
        boolean color = BLACK;

        /**
         * Make a new cell with given key, value, and parent, and with
         * {@code null} child links, and BLACK color.
         */
        Entry(K key, V value, Entry<K,V> parent) {
            this.key = key;
            this.value = value;
            this.parent = parent;
        }

        /**
         * Returns the key.
         *
         * @return the key
         */
        public K getKey() {
            return key;
        }

        /**
         * Returns the value associated with the key.
         *
         * @return the value associated with the key
         */
        public V getValue() {
            return value;
        }

        /**
         * Replaces the value currently associated with the key with the given
         * value.
         *
         * @return the value associated with the key before this method was
         *         called
         */
        public V setValue(V value) {
            V oldValue = this.value;
            this.value = value;
            return oldValue;
        }

        public boolean equals(Object o) {
            if (!(o instanceof Map.Entry))
                return false;
            Map.Entry<?,?> e = (Map.Entry<?,?>)o;

            return valEquals(key,e.getKey()) && valEquals(value,e.getValue());
        }
		//利用节点keyHash和value的哈希异或值来计算hashCode。
        public int hashCode() {
            int keyHash = (key==null ? 0 : key.hashCode());
            int valueHash = (value==null ? 0 : value.hashCode());
            return keyHash ^ valueHash;
        }

        public String toString() {
            return key + "=" + value;
        }
    }
```

- 重要方法

  - put()

  > put的时候，先找到应该插入的那个位置，如何判断位置呢？是根据**Comparable**接口里的**compareTo**接口的返回值来判断的。
  >  ```
  > public V put(K key, V value) {
  >         Entry<K,V> t = root;
  >         if (t == null) {
  >             compare(key, key); // type (and possibly null) check
  >
  >             root = new Entry<>(key, value, null);
  >             size = 1;
  >             modCount++;
  >             return null;
  >         }
  >         int cmp;
  >         Entry<K,V> parent;
  >         // split comparator and comparable paths
  >         Comparator<? super K> cpr = comparator;
  >         if (cpr != null) {/**---------1-------------**/
  >             do {
  >                 parent = t;
  >                 cmp = cpr.compare(key, t.key);
  >                 if (cmp < 0)
  >                     t = t.left;
  >                 else if (cmp > 0)
  >                     t = t.right;
  >                 else
  >                     return t.setValue(value);
  >             } while (t != null);
  >         }
  >         else {
  >             if (key == null)
  >                 throw new NullPointerException();
  >             @SuppressWarnings("unchecked")
  >                 Comparable<? super K> k = (Comparable<? super K>) key;
  >             do {/**------------------2---------------------**/
  >                 parent = t;
  >                 cmp = k.compareTo(t.key);
  >                 if (cmp < 0)
  >                     t = t.left;
  >                 else if (cmp > 0)
  >                     t = t.right;
  >                 else
  >                     return t.setValue(value);
  >             } while (t != null);
  >         }
  >         Entry<K,V> e = new Entry<>(key, value, parent);
  >         if (cmp < 0)
  >             parent.left = e;
  >         else
  >             parent.right = e;
  >         fixAfterInsertion(e);/**-----------3---------------**/
  >         size++;
  >         modCount++;
  >         return null;
  >     }
  >  ```
  >
  > 1.可以由外部传入一个**Comparator**接口实现类，来比较Key，(注意这里是Comparator接口，而不是Comparable接口)，如果未传入，则由Key自己实现的Comparable接口来实现比较。**备注1**处的是用Comparator实现，**备注2**是用Key自己的Comparable接口来实现比较
  >
  > 3.插入以后调整，维持红黑树性质。

  - get()方法

  > get方法是直接用红黑树的性质，可以在lg2n的时间内找到key对应的value
  >
  > ```
  >     final Entry<K,V> getEntry(Object key) {
  >         // Offload comparator-based version for sake of performance
  >         if (comparator != null)
  >             return getEntryUsingComparator(key);
  >         if (key == null)
  >             throw new NullPointerException();
  >         @SuppressWarnings("unchecked")
  >             Comparable<? super K> k = (Comparable<? super K>) key;
  >         Entry<K,V> p = root;
  >         while (p != null) {
  >             int cmp = k.compareTo(p.key);
  >             if (cmp < 0)
  >                 p = p.left;
  >             else if (cmp > 0)
  >                 p = p.right;
  >             else
  >                 return p;
  >         }
  >         return null;
  >     }
  > ```

- 关于红黑树

  - 性质

    1. 根节点是黑色
    2. 一个节点不是红色就是黑色
    3. 红节点的儿子必须是黑色的
    4. 从根节点到任意叶子节点所经过的黑色节点**数量**相同
    5. 叶子节点是黑色的

    ps:这里的叶子节点指的是**NIL**节点