CopyOnWrite容器类

> CopyOnWrite(COW)容器类适用于读多写少的场合,器如其名,多线程可以并发读取(迭代读取,不包括get()),但是写入的时候是直接就重新复制一个新的数据结构来替换容器里原来的那个数据结构

比如CopyOnWriteArrayList,本身是通过数组来实现的,读的时候是不加锁的(迭代),和ArrayList没什么区别,但是写的时候是加锁复制的,下面是add()的时候的代码:
```
 public void add(int index, E element) {
 	//获取成员变量里的ReentratLock
        final ReentrantLock lock = this.lock;
        //加锁
        lock.lock();
        try {
            Object[] elements = getArray();
            int len = elements.length;
            if (index > len || index < 0)
                throw new IndexOutOfBoundsException("Index: "+index+
                                                    ", Size: "+len);
            Object[] newElements;
            //长度减去当前增加的元素的index
            int numMoved = len - index;
            if (numMoved == 0)
                //如果等于0,说明数组长度不够了,需要复制并且把数组长度增加1
                newElements = Arrays.copyOf(elements, len + 1);
            else {
                //这里的情况就是在原来的数组中间插入一个元素..扎心了,分两步复制,腾出index的位置给要传入的元素
                newElements = new Object[len + 1];
                System.arraycopy(elements, 0, newElements, 0, index);
                System.arraycopy(elements, index, newElements, index + 1,
                                 numMoved);
                                 
               //在ArrayList的实现是
               System.arraycopy(elementData, index, elementData, index + 1,
                         size - index);
               //因为ArrayList在数组长度充足的情况下是在组内从index的位置向后复制,腾出位置给index上要插入的元素
               //以上是ArrayList的实现
            }
            //将index元素的位置插入进去
            newElements[index] = element;
            //更新新的数组
            setArray(newElements);
        } finally {
            //释放锁
            lock.unlock();
        }
    }

```
加锁的意义是在任意一个时刻,都只有一个线程可以去修改(包括add,remove)容器,一旦去修改容器,会重新复制一个底层储存数据的结构(这里就是复制数组),然后把这个复制的数组的引用传递给容器的成员变量(volatile修饰,可以保证内存可见性).

再来看看迭代的时候是如何操作的,COWAL里的迭代器叫COWIterator
```
static final class COWIterator<E> implements ListIterator<E> {
        /** Snapshot of the array */
        private final Object[] snapshot;
        /** Index of element to be returned by subsequent call to next.  */
        private int cursor;

	//直接把容器里储存数据的数组引用给Iterator里的成员变量
        private COWIterator(Object[] elements, int initialCursor) {
            cursor = initialCursor;
            snapshot = elements;
        }

        public boolean hasNext() {
            return cursor < snapshot.length;
        }

        public boolean hasPrevious() {
            return cursor > 0;
        }

	//和ArrayList最大的区别是没有mod的检查
        @SuppressWarnings("unchecked")
        public E next() {
            if (! hasNext())
                throw new NoSuchElementException();
            return (E) snapshot[cursor++];
        }

        @SuppressWarnings("unchecked")
        public E previous() {
            if (! hasPrevious())
                throw new NoSuchElementException();
            return (E) snapshot[--cursor];
        }

        public int nextIndex() {
            return cursor;
        }

        public int previousIndex() {
            return cursor-1;
        }

        /**
         * Not supported. Always throws UnsupportedOperationException.
         * @throws UnsupportedOperationException always; {@code remove}
         *         is not supported by this iterator.
         */
        public void remove() {
            throw new UnsupportedOperationException();
        }

        /**
         * Not supported. Always throws UnsupportedOperationException.
         * @throws UnsupportedOperationException always; {@code set}
         *         is not supported by this iterator.
         *set和add还有remove方法都是不支持的
         */
        public void set(E e) {
            throw new UnsupportedOperationException();
        }

        /**
         * Not supported. Always throws UnsupportedOperationException.
         * @throws UnsupportedOperationException always; {@code add}
         *         is not supported by this iterator.
         */
        public void add(E e) {
            throw new UnsupportedOperationException();
        }

        @Override
        public void forEachRemaining(Consumer<? super E> action) {
            Objects.requireNonNull(action);
            Object[] elements = snapshot;
            final int size = elements.length;
            for (int i = cursor; i < size; i++) {
                @SuppressWarnings("unchecked") E e = (E) elements[i];
                action.accept(e);
            }
            cursor = size;
        }
    }
```
从上面迭代的代码可以看出来,CopyOnWriteArrayList的迭代器是不支持对数组进行修改的.修改只能通过容器本身去修改.
设想,如果a,b,c线程同时在迭代,并且d线程在修改容器,a,b,c线程迭代的时候读取的是旧的数组对象,所以是不会像arrayList那样抛出ConcurrentModificationException异常的,就是没有了fail-fast机制,因为cow容器的思想就是通过延迟更新的,类似快照的思想来处理这种读多改少的场合的.

此外,CopyOnWriteArrayList还有一个不同于ArrayList的方法
```
  /**
  *有点类似set方法的contains()方法,其实想想就明白,如果重复添加相同的元素
  *,会触发复制数组,如果不重复添加数组里已经有的方法的话,就使用这个方法
  **/
  public boolean addIfAbsent(E e) {
        Object[] snapshot = getArray();
        //先通过indexOf方法判断是否包含,如果不包含,进入addIfAbsent()尝试添加
        return indexOf(e, snapshot, 0, snapshot.length) >= 0 ? false :
            addIfAbsent(e, snapshot);
    }
    
    /**addIfAbsent(e,sanpshot)方法
    *
    **/
     private boolean addIfAbsent(E e, Object[] snapshot) {
        final ReentrantLock lock = this.lock;
        //锁定
        lock.lock();
        try {
            Object[] current = getArray();
            int len = current.length;
            //判断在锁定前是否被更改过,如果快照和当前不同,说明被改变了
            if (snapshot != current) {
                // Optimize for lost race to another addXXX operation
                int common = Math.min(snapshot.length, len);
                
                
                for (int i = 0; i < common; i++)
                    //先判断当前与快照里的是否相同
                    //因为在进入这个方法前已经判断了不包含待插入元素
                    //只有快照里的元素和当前不同才说明被改变了,才有继续比较下一步的意义
                    if (current[i] != snapshot[i] && eq(e, current[i]))
                        return false;
                
                //再次从common位置开始判断是否包含待添加的元素
                if (indexOf(e, current, common, len) >= 0)
                        return false;
                        
                //其实上面两次比较方法完全可以压缩成第二个方法去比较的,可能是第一种不用频繁调用equals方法,提高性能吧
            }
            
            //如果快照和当前相同,直接复制,在最后添加元素,完事
            Object[] newElements = Arrays.copyOf(current, len + 1);
            newElements[len] = e;
            setArray(newElements);
            return true;
        } finally {
            lock.unlock();
        }
    }
```

上述方法直接引出了另外一个COW类型的类,他就是CopyOnWriteSet
这货说是Set,其实是聚合了一个CopyOnWriteArrayList成员变量来实现保存元素的
它的和Set接口有关的方法全部是调用CopyOnWriteArrayList的方法来实现的
所以他就是个套着***Set马甲的CopyOnWriteArrayLis***t,这个应该叫适配器模式吗???



> 总而言之,COW类就是用在读多写少的场合,不保证数据的实时一致性,只保证数据在最终一致性(指系统长时间没进行修改时的一致性)
