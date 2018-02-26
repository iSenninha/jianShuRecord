### ArrayDeque源码学习

> 从名称上来看，可以看出这是一个数组实现的双端队列，按照正常的思维，队列作为双端队列将会造成大量的数组移动和复制，事实上却并不用

#### 成员变量
- elements[]
- head
- tail

elements是存储元素的数组结构，而head和tail是一个int型的数组下标，通过这两个下标和数组的搭配使用，使得双端队列在工作的过程中不用频繁复制移动


#### push和方法
push方法最后是走到这个简单的方法里：
```
    public void addFirst(E e) {
        if (e == null)
            throw new NullPointerException();
        elements[head = (head - 1) & (elements.length - 1)] = e; //标注1
        if (head == tail)
            doubleCapacity();
    }
```
重点在**标注1**里面，初始化的时候head是0,通过与运算将计算为**head = (length - 1)**(因为length保证是2的整数次幂)。

再来看看addLast()
```
    public void addLast(E e) {
        if (e == null)
            throw new NullPointerException();
        elements[tail] = e;
        if ( (tail = (tail + 1) & (elements.length - 1)) == head) //标注2
            doubleCapacity();					  //标注3
    }
```
**标注2**和**标注1**结合起来看,通过**head**和**tail**下标的配合使用，双端队列工作的时候，就不用频繁地进行复制和移动了

**标注3**，如果**head == tail**了，说明需要扩容了，来看看扩容函数，这里肯定是需要进行复制的

```
 private void doubleCapacity() {
        assert head == tail;
        int p = head;
        int n = elements.length;
        int r = n - p; // number of elements to the right of p
        int newCapacity = n << 1;					//标注4
        if (newCapacity < 0)
            throw new IllegalStateException("Sorry, deque too big");
        Object[] a = new Object[newCapacity];
        System.arraycopy(elements, p, a, 0, r);				//标注5
        System.arraycopy(elements, 0, a, r, p);				//标注6
        elements = a;
        head = 0;
        tail = n;
    }
```
**标注4**可以看出扩容都是双倍扩容，这也是为了满足容量必须是2的次幂

**标注5,6**可以看出新的数组是这样扩容的:
> 5.复制原数组中的head下标到尾部的所有元素到新数组头部
  6.复制原数组的其他部分到新数组的紧挨着上一个操作的下标的后续部分
  然后设置head为0,tail为原来数组的长度
  这个时候，如果再次**addFirst**操作，那么将会把元素放在队尾，并且head重新设置为**新数组长度-1**，整个扩容复制过程就是这样


#### pop操作
```
    public E pollFirst() {
        int h = head;
        @SuppressWarnings("unchecked")
        E result = (E) elements[h];
        // Element is null if deque empty
        if (result == null)
            return null;
        elements[h] = null;     // Must null out slot
        head = (h + 1) & (elements.length - 1);
        return result;
    }
```
思路很清晰:1.根据head下标的位置直接取出
2.然后置空就行
3.然后重新设置head的值，按照上面扩容的思路，可能会出现**h+1**越过数组最大长度，通过**&**运算重置成

pollLast()也是类似的思路

####其他方法
- size()
```
    public int size() {
        return (tail - head) & (elements.length - 1);
    }
```
通过因为可能出现tail > head 和 tail < head的情况，通过**&**运算，得出正确的结果

- toString()方法
toString方法是**AbstractCollection**方法实现的，具体是委托给**iterator()**去实现：
```
 public E next() {
            if (cursor == fence)
                throw new NoSuchElementException();
            @SuppressWarnings("unchecked")
            E result = (E) elements[cursor];
            // This check doesn't catch all possible comodifications,
            // but does catch the ones that corrupt traversal
            if (tail != fence || result == null)
                throw new ConcurrentModificationException();
            lastRet = cursor;
            cursor = (cursor + 1) & (elements.length - 1);   /标注7
            return result;
        }
```
这里**cursor**初始值是head，**fence**是tail
标注7帮助cursor越界后归0

主要的实现就是这样，另外这个类的说明说到
> This class is likely to be faster than
 {@link Stack} when used as a stack, and faster than {@link LinkedList}
 when used as a queue.

但是是线程不安全的。。
