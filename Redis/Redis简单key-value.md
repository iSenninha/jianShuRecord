### Redis简单key-value

##### 1.keys

> Redis的key是二进制安全的，所以，所有的二进制序列都可以作为Redis的key，包括空字符串。

 一般遵循以下几个原则：

 - 长度适中;
 - 格式一致易读;
 - 键的最大长度是512MB;


##### 2.简单key-value储存

> 字符串是可以关联给key的最简单的值

来看一下最简单的储存吧：

```
set senninha 1
//保存senninha-1这个key-value对
```

然后来获取：

```
get senninha
//打印出1
```

然后来尝试使用增加减少这个数字的操作，这个操作是原子的：

```
incr senninha
//那么senninha变成了2，如果senninha不是数字，那么将会提示错误

incrby senninha 2
//给定步长增加

decr decrby
对应的减少
```



##### 2.多个值储存和获取

> 由于每一次发送一个命令都是通过socket进行的，会导致延迟，可以一次设置多个值来减少延迟：

```
mset senninha0 0 senninha1 1 senninha2 2
//m是multi的意思？
mget senninha0 senninha1 senninha2
//返回一个数组
```



##### 3.修改和删除

判断键是否存在

```
exists senninha
//存在返回1
```

删除键值对

```
del senninha
//如果键存在，返回1,并且成功删除，如果不存在或者没有删除返回0
```

键的类型

```
type senninha
//如果键不存在，返回none，否则貌似都是返回string
```



##### 4.有限生存时间的键

设置键的存活时间

```
expire senninha 5
//设置senninha的存活时间是5s，如果这个键不存在，返回0,否则返回1，
```

察看键的存活时间

```
ttl senninha
//time to live,如果键不存在，返回-2,永久存活返回-1,其他返回正常的存活时间
```

当然也可以在储存key-value的时候设置存活时间

```
set senninha 1 ex 10
//ex expire
```



基本的key-value用法就到这里啦。