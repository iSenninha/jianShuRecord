### MySql索引

- 可将数据库的应用类型分为OLTP(OnLine Transaction Processing ，联机事务处理)和OLAP(OnLine Analysis Processing，联机分析处理)两种



- 根据Cardinality来判断索引是否有效

  ```
  show index from xx_table;
  即可察看cardinality的值，这个值表示表中主键互不相同的数目由多少
  定义一个值total表示当前表的总数目
  total/cardinality 这个值越接近1表示这个索引的有效性最高

  另外，这个数是通过随机采样八个叶节点得到的。
  这个值会在update，insert到一个阀值的时候自动更新。
  ```

- 联合索引


  ```
  1.创建一个联合索引
    create table t(
    	a int,
    	b int,
    	primary key(a),
    	key idx_a_b(a,b)
    )
   
  2.为一个已经存在的表建立索引
     alter table xx add key(columnName);
  ```

- InnoDB B+树索引

  > 首先是文件系统或者数据库中，B+树的非叶子节点并不储存数据，可以全部载入内存中，然后直接定位后再执行磁盘io操作，去磁盘里读取，并且一次读取磁盘里的一页(16kb)。
  >
  > 而每个节点的大小都是一页的大小，是为了利用磁盘每次读取一页这种特性，然后每次读取一页减少io操作。

  ```
  1.若在创建的时候没有显式地指定主键，则InnoDB这自动创建一个6个字节的列作为主键;

  2.聚集索引是根据主键创建的一棵B+树，聚集索引的叶子节点存放了表中的所有记录

  3.辅助索引是根据显示指定的索引键创建的一颗B+树，与聚集索引不同，其叶子节点仅存放索引键值和主键	，所以通过辅助索引查找到后很可能要再通过聚集索引去获取数据。
  所以，辅助索引一页里可以储存更多的key值，所以高度要小于聚集索引。
  ```

  ​

- 联合索引的情况

```
有表a：
+-------+---------+------+-----+---------+-------+
| Field | Type    | Null | Key | Default | Extra |
+-------+---------+------+-----+---------+-------+
| low   | int(11) | YES  |     | NULL    |       |
| upp   | int(11) | YES  |     | NULL    |       |
| rank  | char(1) | YES  |     | NULL    |       |
+-------+---------+------+-----+---------+-------+
添加联合索引
alter table a add key(low,upp);

然后插入如下组数据:
(1,2,a),(1,3,aa),(3,2,4),(1,5,44)
在B+树中，是如下排列的：
先按low进行排列，然后在相同的low的情况下再进行upp的排列。
所以，如果我们要对low进行查询，这个索引是有效的，但是如果对upp进行查询，这个索引是无效的。
另外，如果我们在确定某个low的条件下，按upp进行升序或者降序排列，这个联合索引其实已经为我们排序好了upp。
```



- 覆盖索引

```
如果一个索引包含或者说覆盖所有需要查询的字段的值，那么就没有必要再回表查询，这就称为覆盖索引。
比如：
select count(*) from xxx_table where buy_date between 2017-1-1 and 2017-2-3;
有联合索引(user_id, buy_date)
这个时候会选择使用这个联合索引来进行优化操作，选择各个userid，然后各个user_id下的buy_date是已经排序好了的

在一个查询语句没有索引或者要使用聚集索引的情况下，使用索引覆盖选择辅助索引来减少io操作，达到优化的效果。
比如:
select count(*) from xxx_table;
```


- 索引提示(index hint)

```
select *from table_a using index(a);//告诉数据库可以使用这个索引，但是不一定会使用
select *from table_a force index(a);//强制数据库使用这个索引执行某个语句
```



> [mysql索引好文](https://juejin.im/entry/590427815c497d005832dab9)