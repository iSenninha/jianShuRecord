###ByteBuf释放
netty在处理ByteBuf的时候，为了提高内存使用效率，有池管理的**ByteBuf**。减少重新分配对象产生的性能消耗。

- 申请池ByteBuf
```
ChannelHandlerContex.alloc().buffer()
```
通过以上代码就可以申请到池管理中的ByteBuf，申请到的对象，默认在引用这里就是**refcnt=1**，这个就是引用计数的地方。
如果要主动往引用+1，则是调用：
```
buf.retain();
```
一般情况下，不需要我们手动调用这个方法。

LengthFieldBaseFrameDecoder在Decode裁剪的时候调用**slice**方法会产生一个衍生的ByteBuf，这个buf里的parent就会调用**retain**方法，只有衍生的buf释放了，parent才会释放掉。

- 释放
buf使用完毕后，可以通过**release**的方式释放，提供了工具方法:
```
        ReferenceCountUtil.release(msg);
```
netty的默认处理链是会自带**HeadContext**和**TailContext**的,TailContext会自动做**release()**，只有在不经过尾处理链的buf才需要我们手动去**release()**。
这种场景一般出现在处理链中，我们手动去处理替换了**buf**

另外，如果**release**到0的话，buf就会还回给**ByteBufAllocator**池。

