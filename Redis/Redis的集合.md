### Redis的集合

> Redis的List是通过链表来实现的，意味着插入和删除可以在**常数时间**内完成，但是随机访问的效率没有数组高。下面来看一下Redis里List的用法。

##### 1.左右push数据，获取数据

首先是push数据

```
rpush list a;
lpush list b;
//需要注意的是，如果list原来是通过 set list a;建立的
//再去lpush，将会报类型错误，但是set可以覆盖list
```

可以一次push多个

```
rpush list a b c d
```

获取数据

```
lrange list 0 1;
//获取下标0,1,注意这个是闭区间，意味着将有两个数据被取出
lrange list 0 -1;
//表示取到最后一个数据，-2表示取到倒数第二个数据
```

可以通过pop的方式弹出数据

```
rpop senninha
```

使用场景，可以获取最新的几条数据～

上限列表

> 裁剪一个列表的长度。需要注意的是，这个只是裁剪，而不是限制列表的长度。

```
ltrim list 0,10
//那么这个列表将会裁剪长度，就只有11个长度了。
```

列表的阻塞操作

> 可设置阻塞超时的pop操作。可以用在生产消费者模式下。	

```
brpop list 3
//block right pop 并且设置超时3s，返回值是一个键值对，因为这条命令可以同时获取多个队列。
```



##### 2.哈希散列

新建并插入一个数据

```
hmset senninha name senninha age 21
//hash multi set senninha(key) name(key) senninha(value)
//需要注意的是，这个操作和list的push一样，如果senninha(key)已经存在并且类型不是hashmap，会报类型不匹配错误。(error) WRONGTYPE Operation against a key holding the wrong kind of value

hset senninha address 37
//单个放入
```

获取数据

```
hmget senninha senninha
//获取senninha键里senninha key的值
hget senninha senninha
//单个获取，上面那个是多个获取
```

还可以针对hash里的value进行增加操作

```
hincrby senninha age 10;
//hash increase by 增加10
```



##### 3.set操作

> Set是不允许出现重复数据的集合

添加数据

```
sadd mclaren alonso
sadd mclaren hamilton
//set add 添加
```

测试数据是否存在

```
sismember mclaren alonso
//set is member?
```

列出所有的数据

```
smembers mclaren
//set members所有的成员
```

计算两个集合的交集

```
sadd ferrari alonso
sadd ferrari vetel
//添加ferrari几个数据
sinter mclaren ferrari
//set intersection(交集)，结果是alonso
```

随机弹出数据

```
spop mclaren
```

求多个并集并储存在一个键里面

```
sunionstore targetkey key1 key2
//set union store,把key1,key2的并集结果储存在targetkey里，这个key1可以是多个key或者一个key，如果是一个key的话，其实就是自我复制了。
```

计算集合里的key数量

```
scard ferrari
//set cardinality
```

随即返回set里的一个值，但是不删除元素

```
srandmember ferrari
//set random member ferrari
```



##### 4.有序集合

> 有序集合类似哈希，用一个浮点值**scores**(理解成key)来作为排序的依据，排序依据是根据key+value来排序的。

加入集合，读取集合

```
zadd sset 12 hxx
zass sset 12 hxxx
zrange sset 0 -1
//结果如下：
1) "hxx"
2) "hxxx"
//逆序：
zrevrange sset 0 -1
```

输出scores：

```
zrange sset 0 -1 withscores,
```

输出在score范围内的value：

```
zrangebyscore sset -inf 1000
//输出负无穷到1000的值
```

也可以删除某个范围内的：

```
zremrangebyscore sset -inf 1000
//删除scores范围内的数据，并且返回删除的数目
```

也可以根据value进行字典排序

```
zrangebylex sset [a [b
//先根据score进行排序，然后根据value截取开头是a，b之间的值
```

计算有序列表里有多少个值：

```
zcard sset
//cardinality计算剩余多少值
```



##### 5.位图

> 位图，是用位来记录状态，比如记录某个用户是否需要发送提醒短信，使用位图用少量的空间就可以记录大量用户的信息

新增一个bitmap

```
setbit key 0 1
//设置key的0位为1
getbit key 0
//获取位置0的位置
```

计算所有的位为1的数量

```
bitcount mykey
```

计算第一个为0或者1的位的位数

```
bitpos mykey 0/1
//如果不存在返回-1
```

还有提供位的与操作的：

```
bitop and distkey srckey1 srckey2
//逐位and操作，然后把结果给distkey
还有or xor not操作
```



##### 6.超重对数

> 超重对数是用来计算加入某个键的不重复的key的个数的，比如可以用来计算每天的独立搜索词有多少个

```
pfadd pf a b c a
pfcount pf
```

