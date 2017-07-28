###Nio 缓冲类的基础---Buffer的flip，rewind，clear等操作

> nio的读写是要和Buffer的子类打交道的，关键的flip,rewind,mark,compact操作如下

首先来看一下Buffer里一些相关的成员变量：
```
    private int mark = -1;
    //指向下一个可读或者可写的数组下标
    private int position = 0;
    //需要注意的是，这里的limit所指的位置其实是数组里不存在的位置，即初始化时候它是和capacity相等的，这样才能和上面的position的含义--指向下一个可读或者可写的数组下标自洽
    private int limit;
    private int capacity;
    
    //证明limit，获取堆ByteBuffer的静态方法，limit=capactity
     public static ByteBuffer allocate(int capacity) {
        if (capacity < 0)
            throw new IllegalArgumentException();
        return new HeapByteBuffer(capacity, capacity);
    }
```


#####1.flip操作
```
 public final Buffer flip() {
        limit = position;
        position = 0;
        mark = -1;
        return this;
    }
```
从源码里可以看出，执行flip操作的时候，把limit置为position，读写的position置为0,mark置为-1
为什么是这样呢？因为当初始化Buffer的子类时候，position为0（从上面贴的那个代码可以看出），即指向下一个可以写的位置，然后写写写，然后这个时候我想读了，读是怎么读的呢，读的指针还是用position作为标记，于是调用flip的作用就显而易见了，把limit置为position，当前的position置为0。

其实读和写最后都是调用的这个final方法去判断是否满足条件：
```
//java.nio.Buffer.nextGetIndex()
final int nextGetIndex() {                          // package-private
        if (position >= limit)
            throw new BufferUnderflowException();
        return position++;
    }
```

#####2.rewind操作
```
  /**
     * Rewinds this buffer.  The position is set to zero and the mark is
     * discarded.
     *
     * <p> Invoke this method before a sequence of channel-write or <i>get</i>
     * operations, assuming that the limit has already been set
     * appropriately.  For example:
     *
     * <blockquote><pre>
     * out.write(buf);    // Write remaining data
     * buf.rewind();      // Rewind buffer
     * buf.get(array);    // Copy data into array</pre></blockquote>
     *
     * @return  This buffer
     */
 public final Buffer rewind() {
        position = 0;
        mark = -1;
        return this;
    }
```
rewind和flip操作基本相同，只是不把limit置为position
用法嘛，就是读读读，我读了几个了，但是这个时候我想重新再从头开始读，用rewind就行了。rewind的意思就是倒带。。贴切

#####3.clear操作
顾名思义，清除嘛
来贴代码
```
//基本上就是把这几个成员变量恢复为初始化时候的值
 public final Buffer clear() {
        position = 0;
        limit = capacity;
        mark = -1;
        return this;
    }
```

#####4.mark操作
```
//记录下当前的position位置，然鹅，一旦调用flip或者rewind操作就失效了
 public final Buffer mark() {
        mark = position;
        return this;
    }
```

#####5.reset操作
```
//嗯，把4.里面的mark值reset给position
  public final Buffer reset() {
        int m = mark;
        if (m < 0)
            throw new InvalidMarkException();
        position = m;
        return this;
    }
```

#####6.remaining操作
```
//写入模式的情况下，就是还可以写多少个，读模式下就是还可以读多少个
  public final int remaining() {
        return limit - position;
    }
```

#####7.compact操作
compact即压缩的意思，其实compact并不是Buffer定义的方法，他是ByteBuffer的一个抽象方法
使用场景是当读取了一部分数据的时候，并且这个时候想继续写数据了，这个时候就要用到compact方法了，这里抽取的是HeapByteBuffer源码里的compact方法
```
 public ByteBuffer compact() {
	//把数组里未读取的字节搬到字节从数组下表0开始的位置来
        System.arraycopy(hb, ix(position()), hb, ix(0), remaining());
        //重新设置position，即把position指向下一个可以写的数组下标位置
        position(remaining());
        //重新设置limit，设置为capacity()
        limit(capacity());
        discardMark();
        return this;


    }
```

####所以Buffer类的用法：
1.申请到了Bufffer后，直接可以执行写;
2.读操作的时候，flip;
3.如果想要重新读，rewind;
4.如果读了一部分，想要继续写，compact;
