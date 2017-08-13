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
  > set tx_isolation = "read-committed";