###1.自定义字符作为包分隔符
```
   /**
    *在实现ChannelInitializer接口的initChannel（SocketChannel sc）里添加过滤器
    */
    public void initChannel(SocketChannel sc) throws Exception{
         ByteBuf buf = Unpolled.copiedBuf("mc".getBytes());
        //这里设置的是mc为包与包之间的分隔符，所以每出现一次mc就切割为一个包，注意的是设置为分隔符的mc将不会出现在最后的信息里。
        //并且这里设置了最大长度为1024个字节，如果超过了1024个字节还没有出现分隔符，会抛出异常
         DelimiterBasedFrameDecoder decoder = new DelimiterBasedFrameDecoder(1024,buf);
         sc.pipechannel.addLast(decoder);

  } 
```

###2.基于换行符 "\n" "\n\r"的包分隔符
```
 /**
    *在实现ChannelInitializer接口的initChannel（SocketChannel sc）里添加过滤器
    */
    public void initChannel(SocketChannel sc) throws Exception{
         //每出现换行符自动拆包，设置最大长度为1024个字节。
         LineBasedFrameDecoder decoder = new LineBasedFrameDecoder(1024);
         sc.pipechannel.addLast(decoder);
    }
```

###3.固定长度包
  如果我们的包是固定长度的，可以设置固定长度的解码器来处理
```
 /**
    *在实现ChannelInitializer接口的initChannel（SocketChannel sc）里添加过滤器
    */
    public void initChannel(SocketChannel sc) throws Exception{
         //以1024为固定长度拆包。
         FixedLengthFrameDecoder decoder = new FixedLengthFrameDecoder(1024);
         sc.pipechannel.addLast(decoder);
    }
```
