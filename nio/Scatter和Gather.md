### Scatter和Gather

> Scatter和Gather分别是**分散**和**聚集**的意思。指的是在**Channel**里可以通过分散读取和聚集写入，直接来看粒子吧

```
			channel = file.getChannel();
			ByteBuffer buf0 = ByteBuffer.allocate(32);
			ByteBuffer buf1 = ByteBuffer.allocate(1024);
			ByteBuffer[] dsts = new ByteBuffer[] {buf0, buf1};
			channel.read(dsts);//读出一个ByteBuffer数组
			
			channel.write(dsts);//写入一个ByteBuffer数组
```

1. 这个分散读适合用于报文的**head**和**body**，但是**head**必须是定长的，因为是前一个ByteBuffer写入到头了才会继续去写入数组里下一个ByteBuffer对象。
2. 聚合写适合用于很长的报文**变长body**，这样就不用申请过大的ByteBuffer，而是申请多个ByteBuffer来实现。