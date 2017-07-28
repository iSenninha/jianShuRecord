#####PriorityQueue源码学习
> 使用堆来实现一个优先级队列，comapreTo()比较最小的那个放在堆顶，每次offer(),poll()的时候分别向上，下调整堆，时间复杂度都是logN。
这个类有bug，没有泛型在编译时检查一定要元素实现Comparable接口，导致如果构造时候没有加入Comparator变量，并且元素也没有实现Copmarable接口的话，会抛出强转异常，因为在sift的时候都是强转为Comparable来比较的

#####1.主要成员变量
```
//默认初始化容量11
 private static final int DEFAULT_INITIAL_CAPACITY = 11;


//底层数组的形式来保存队列，并且是以平衡二叉堆的形式来实现优先级
transient Object[] queue;

//优先级以Comparator来比较，如果没有指定，则以元素自己实现的Copmarabe接口的实现来比较优先级
private final Comparator<? super E> comparator;

```

#####2.构造方法
```
 public PriorityQueue(int initialCapacity,
                         Comparator<? super E> comparator) {
        // Note: This restriction of at least one is not actually needed,
        // but continues for 1.5 compatibility
        if (initialCapacity < 1)
            throw new IllegalArgumentException();
        this.queue = new Object[initialCapacity];
        this.comparator = comparator;
    }
```
> 多个不同的构造方法其实到最后都是到了这里，初始化数组长度，把可能不为null的comparator引用给成员变量。

#####3.offer(E e)
add(E e)方法其实也是调用的offer(E e)方法
```
 public boolean offer(E e) {
        if (e == null)
            throw new NullPointerException();
        modCount++;
        int i = size;
        //自动扩容，扩容算法是小于64的时候double增长，反之50%增长。
        if (i >= queue.length)
            grow(i + 1);
        size = i + 1;
        if (i == 0)//如果i是0的话，不用调整堆
            queue[0] = e;
        else//调整堆，见下面
            siftUp(i, e);
        return true;
    }
    
     private void siftUp(int k, E x) {
     //如果构造时候没有传入comparator的话，就用siftUpCOmpareable(k, x)去比较优先级来调整堆，下面只看这个方法的实现
        if (comparator != null)
            siftUpUsingComparator(k, x);
        else
            siftUpComparable(k, x);
    }
    
    //k是指待插入的数组下标，数值上等于未插入前队列的长度
    private void siftUpComparable(int k, E x) {
        Comparable<? super E> key = (Comparable<? super E>) x;
        while (k > 0) {
            int parent = (k - 1) >>> 1;
            Object e = queue[parent];
            //如果待插入大于e的话，直接停止
            if (key.compareTo((E) e) >= 0)
                break;
            //否则的话把待插入的位置赋给parent，然后待插入的那个元素位置暂时置为parent的，继续循环
            queue[k] = e;
            k = parent;
        }
        //跳出循环的时候，那个k的位置就是这个待插入的元素应该待的位置，堆就调整完毕了
        queue[k] = key;
    }
    //ps：也就是权值小的那个元素会一直在堆顶，也就是小顶堆，这个小顶堆在插入的时候的时间复杂度是logn
    //如果插入的是Integer的话，那么每次pool出来的都是最小的那个值，如果要反过来话弹出最大的数的话，
    //我们可以自己写个包装类，然后实现comparator方法来实现相反的逻辑。
    
    
```

#####4.poll方法，时间复杂度也是logn
```
  @SuppressWarnings("unchecked")
    public E poll() {
        if (size == 0)
            return null;
        int s = --size;
        modCount++;
        //直接数组的第一个即是要poll出来的元素，然后重新调整堆
        E result = (E) queue[0];
        E x = (E) queue[s];
        queue[s] = null;
        if (s != 0)//联想一下堆排序，弹出堆顶后的元素后是把最后一个元素取出来，放到堆顶，然后让他沉下去
            siftDown(0, x);
        return result;
    }
    
    //让元素沉下去的方法
     private void siftDownComparable(int k, E x) {
        Comparable<? super E> key = (Comparable<? super E>)x;
        //这个half的数值是层次遍历第一个没有子节点的节点，即叶子节点
        //因为小顶堆的特点是某个节点的值要小于其的所有子节点，如果一个节点是叶子节点
        //那个位置的节点以下的位置是不可能存在违反小顶堆规则的节点了，就无需再往下沉了
        int half = size >>> 1;        // loop while a non-leaf
        while (k < half) {
            //找子节点
            int child = (k << 1) + 1; // assume left child is least
            Object c = queue[child];
            int right = child + 1;
            //比较左右节点那个小，小的才去比较
            if (right < size &&
                ((Comparable<? super E>) c).compareTo((E) queue[right]) > 0)
                c = queue[child = right];
            //满足条件说明较小的子节点都比当前节点大了，满足条件，停止
            if (key.compareTo((E) c) <= 0)
                break;
            queue[k] = c;
            k = child;
        }
        //找到了正确的位置
        queue[k] = key;
    }


```

#####5.其他方法
- peek() 
返回堆顶的元素，但是不移除，就是把数组下标节点0的元素的引用返回，不涉及堆调整
---
- remove(E e)
移除某个元素，这里的移除比较麻烦，遍历找到，移除后还需要去调整堆，调整堆的代码如下：
```
@SuppressWarnings("unchecked")
    private E removeAt(int i) {
        // assert i >= 0 && i < size;
        modCount++;
        int s = --size;
        if (s == i) // removed last element如果移除的是最后一个元素，爽了，不用去调整堆
            queue[i] = null;
        else {
            E moved = (E) queue[s];
            queue[s] = null;
            //首先尝试向下调整堆
            siftDown(i, moved);
            //如果发现向下调整堆没有改变，可能是需要向上调整堆
            if (queue[i] == moved) {
                siftUp(i, moved);
                if (queue[i] != moved)
                    return moved;
            }
        }
        return null;
    }
```


> ps:这个类是java.util下的，暂时把它归为juc源码学习，因为juc下的DelayQueue是聚合了一个PriorityQueue来实现的。
