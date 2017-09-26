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



- 索引的几种情况

> 使用的示例库是mysql里自带的employees库，使用**titles**表来作为demo，该表的索引情况如下：
>
> (em_no,title,from_date)联合主键(联合索引)。

	#### 	1.全列匹配

​		全列匹配即是所有索引的字段都作为判断条件了，如下：

		> ```
		> EXPLAIN SELECT * FROM employees.titles WHERE emp_no='10001' AND title='Senior Engineer' AND from_date='1986-06-26';
		> ```

​		如果并且，如果SQL中的判断顺序不和联合索引从顺序相同，但是包含了全部索引字段的话，Mysql会自己做优			  化，把所有的索引都会使用上。

	#### 	2.最左前缀匹配

​		查询语句里，只精确匹配从索引左边开始的连续几个索引，如下：

> ```
> EXPLAIN SELECT * FROM employees.titles WHERE emp_no='10001';
> ```

#### 	3.索引中的中间条件未匹配

​		比如下面这个语句，判断里有联合索引的左边和最右的匹配条件，但是中间的title没有，那么这种情况只能使用到最左的精确匹配。

> ```
> EXPLAIN SELECT * FROM employees.titles WHERE emp_no='10001' AND from_date='1986-06-26';
> ```

​		这个时候，如果**title**字段不多的话，可以手动去填上title这个坑，如下：

> ```
> EXPLAIN SELECT * FROM employees.titles
> WHERE emp_no='10001'
> AND title IN ('Senior Engineer', 'Staff', 'Engineer', 'Senior Staff', 'Assistant Engineer', 'Technique Leader', 'Manager')
> AND from_date='1986-06-26';
> ```

​		这样的话就会用上所有的索引了。

	#### 	4.查询条件没有用到指定索引的第一列

​		没有用到第一列索引的，自然就不可能用到索引了，只能全表扫描

	#### 	5.匹配某列前缀字符

​		如下查询语句，第二个条件字段使用了使用**通配符%**

> ```
> EXPLAIN SELECT * FROM employees.titles WHERE emp_no='10001' AND title LIKE 'Senior%';
> ```

​		那么这个语句仍然能用到第二个字段的部分前缀字符索引，但是，如果通配符出现了'%enior'的话，就无法使用索引了。。

	#### 	6.范围查询

​		一个语句中多个范围查找，后面的范围查找无法使用索引：

> ```
> EXPLAIN SELECT * FROM employees.titles
> WHERE emp_no < '10010'
> AND title='Senior Engineer'
> AND from_date BETWEEN '1986-01-01' AND '1986-12-31';
> ```

​		显然，根据B+树联合索引的原理，范围查找只能使用到第一个索引，后面的范围查找索引无法使用。

	#### 	7.条件中由函数表达式会导致无法使用索引

​		比如下面这句，截取title里的左六位，并不会使用到title上的索引

> ```
> EXPLAIN SELECT * FROM employees.titles WHERE emp_no='10001' AND left(title, 6)='Senior';
> ```

#### 	8.前缀索引

​		前缀索引是指，使用字段的一部分(left函数)来作为关键字加入索引，比如这个应用场景，姓氏和名字是两个独立的字段，经常要查询这两个。索引可以使用姓氏的全部和名字的一部份来建立索引，这样的话，索引的长度不会太长，减少**索引维护**和**空间**的消耗。

​		如下，使用名字+姓氏的前四个字符作为索引

> ```
> ALTER TABLE employees.employees
> ADD INDEX `first_name_last_name4` (first_name, last_name(4));
> ```

#### 9.尽量采用自增字段来作为索引

> innoDB使用聚集索引，数据记录本身被存于主索引（一颗B+Tree）的叶子节点上。这就要求同一个叶子节点内（大小为一个内存页或磁盘页）的各条数据记录按主键顺序存放，因此每当有一条新的记录插入时，MySQL会根据其主键将其插入适当的节点和位置，如果页面达到装载因子（InnoDB默认为15/16），则开辟一个新的页（节点）。
>
> 如果使用非自增索引，那么每次插入一个都近乎是随机的索引值，那么mysql要查找到对应应该存在的位置，然后作移动才能插入，造成了很多额外的开销，并且索引结构不够紧凑，后续可能要用optimize tablename来维护。