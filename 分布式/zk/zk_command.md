### zookeeper的基本命令

#### 1.创建

```
create [-s] [-e] path data acl
```

[-s],[-e]分别表示顺序节点/临时节点，默认情况下，不添加参数的话，创建的都是持久节点
最后一个参数**acl**表示的是权限控制


#### 2.读取

```
ls path	[watch]
```

列出path下的所有节点

```
get path [watch]
```

获取节点的数据,watch表示关注此节点的改变事件，输入任意一个字符即可（暂时发现是这样）


#### 3.更新

```
set path newData [version]
```

version为-1表示直接执行更新，不在意当前版本的数据，如果version为一个指定的value，则与**CAS**的操作一样。版本错误会提示:
> version No is not valid : /senninha0001

#### 4.删除

```
delete path
```

只可以删除没有子节点的节点

```
rmr path
```

递归删除节点
