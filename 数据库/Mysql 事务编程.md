### Mysql 事务编程

- 事务的分类
  1. 扁平事务
  2. 带有保存点的扁平事务
  3. 链事务
  4. 嵌套事务
  5. 分布式事务(跨行转账)



- 事务控制语句

```
1.首先在简表的时候，要建立一个使用Innob引擎的表
	create TABLE t (a int,
	primary key(a))
	engine=INNOB;
	
2.设置事务隔离级别
	set transaction 
		- read uncommitted
		- read committed
		- repeatable read
		- serializable

3.开始事务
	begin
	一系列操作
    ...
    ...
    commit 提交
    rollback 如果没有commit，而是输入rollback，则回滚，撤销本次所有未提交事务的操作
    
4.创建中间事务保存点
	开启事务后
	begin
	...
	savepoint t1;//设置保存点
	...
	release savepoint t1;//释放保存点
	...
	rollback to savepoint t1;//回滚到某个保存点
	
	commit;//最后还是要进行事务的提交。
```



- 事务的隔离级别

  1. Read uncommitted(读未提交)
  2. Read committed(读提交)
  3. Repeatable read(可重复读)
  4. Serializable(串行化)

     > MySql InnoDB默认的事务隔离等级是Repeatable Read
     >
     > 下列语句可以查看事务等级：
     >
     > mysql> select @@tx_isolation;
     > +-----------------+
     > | @@tx_isolation  |
     > +-----------------+
     > | REPEATABLE-READ |
     > +-----------------+
     > 1 row in set (0.00 sec)
     >
     > 如下可以设置事务等级：
     >
     > set [Global | Session] transaction isolation level read committed



- 脏读，不可重复读，幻读

| 现象   | 描述以及解决                                   |
| ---- | ---------------------------------------- |
| 脏读   | 事务A读取到了其他事务未提交的数据，通过设置事务隔离等级Read-Committed可解决 |
| 可重复读 | 事务A在一个事务的两次读取中对同一行数据读取到了两种不同的结果，因为可能其他事务也在修改这个数据  ***不可重复读***着重在数据的***更新***  设置为REPEATABLE-READ可解决 |
| 幻读   | 事务A在获取某个表的行数时候，同时其他事务也在插入这个表并且提交，事务A在当前事务无法察觉到这个变化，当退出当前事务后再开启新事务才察觉到这个变化，好些产生了幻觉。 ***幻读***着重在新插入或者删除数据 只有Serializable避免幻读，但是mysql InnoDB引擎里，默认就是REPEATALBE-READ，并且采用了Next-Key LOCK算法，已经达到了SQL的Serializable级别，所以在Mysql本地事务里，采用REPEATABLE-READ已经能满足需要。 |

​	

	##### 	模拟幻读现象

| 事务A                                      | 事务B             |
| ---------------------------------------- | --------------- |
| 开启事务，查询当前某表条目数count(*)=0                 |                 |
|                                          | 开启事务，插入一条数据并且提交 |
| 继续count(*)=0，提交事务                        |                 |
|                                          |                 |
| 重新开启事务，count(*)=1                        |                 |
| 在事务A中，无论如何查询到的count(*)都是0，一旦重新开启事务，就成了1，好些产生了幻觉 |                 |

	##### 	模拟不可重复读

| 事务A                                      | 事务B               |
| ---------------------------------------- | ----------------- |
| 设置当前的隔离等级为Read-Committed(set ession transaction isolation level READ COMMITTED) |                   |
| 开始事务，查询某行数据值为B                           |                   |
|                                          | 开始事务，更新某行数据为A，并提交 |
| 查询某行数据，发现为A，在一个事务中不可重复读                  |                   |
|                                          |                   |



	##### 	模拟脏读

| 事务A                                      | 事务B            |
| ---------------------------------------- | -------------- |
| 依然设置隔离等级未Read-Uncommitted                |                |
| 开启事务，查询某行数据，发现为B                         |                |
|                                          | 开启事务，并更新某行数据为A |
| 再次查询某行数据，发现为A，此时事务B并未提交，产生了脏读。其实如果事务B进行的是插入或者删除操作未提交，事务A一样是读取到了这个脏数据 |                |
|                                          |                |

