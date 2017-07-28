LinkedHashMap分析(基于jdk1.8)

> HashMap有一个问题就是迭代的顺序无法保证,也就是和put进去的顺序不同,有时候可能需要保证迭代的时候与put进去的顺序一致,这个时候就可以使用LinkedHashMap了

首先要搞清楚为什么HashMap无法保证迭代的顺序和put的顺序为什么无法相同,
首先放入map的桶,也就是数组的顺序是和put的顺序没有联系的,恰恰迭代的时候是根据数组里的顺序来的,代码如下:
```
final Node<K,V> nextNode() {
            Node<K,V>[] t;
            Node<K,V> e = next;
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
            if (e == null)
                throw new NoSuchElementException();
                //把hashmap的table引用给t数组
            if ((next = (current = e).next) == null && (t = table) != null) {
             	//do while循环,直到数组中的某个对象不为null时返回null
                do {} while (index < t.length && (next = t[index++]) == null);
            }
            return e;
        }
```

所以为了解决这个问题,LinkedHashMap的静态内部类Entry继承了HashMap的Node并且增加了before和after的成员变量
```
static class Entry<K,V> extends HashMap.Node<K,V> {
        Entry<K,V> before, after;
        Entry(int hash, K key, V value, Node<K,V> next) {
            super(hash, key, value, next);
        }
    }
```

然后问题来了,增加的这些节点是怎么在put的时候弄上去的呢,看看重写的方法吧
我本来以为是重写了putVal()方法呢,然而我还是naive,其实是重写了newNode()方法
```
    Node<K,V> newNode(int hash, K key, V value, Node<K,V> e) {
        LinkedHashMap.Entry<K,V> p =
            new LinkedHashMap.Entry<K,V>(hash, key, value, e);
        //这个方法将put的方法形成一个链表
        linkNodeLast(p);
        return p;
    }
    
    /**
    *私有方法
    *
    **/    
    private void linkNodeLast(LinkedHashMap.Entry<K,V> p) {
        LinkedHashMap.Entry<K,V> last = tail;
        tail = p;
        if (last == null)
            head = p;
        else {
            p.before = last;
            last.after = p;
        }

```

好,再来看看LinkedHashMap的迭代方法,直接看nextNode就行啦:
```

 final LinkedHashMap.Entry<K,V> nextNode() {
            LinkedHashMap.Entry<K,V> e = next;
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
            if (e == null)
                throw new NoSuchElementException();
                //终于不用通过桶去循环找下一个不为null的数组对象啦
            current = e;
            next = e.after;
            return e;
        }
```
