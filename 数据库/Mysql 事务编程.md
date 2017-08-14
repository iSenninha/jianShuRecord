### Mysql 事务编程

- ACID

  所有实现了事务的数据库都要满足ACID

  原子性，一致性，隔离性，持久性

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

  1. Read uncommitted(读未提交）
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

  - 脏读，幻读，不可重复读

| 现象    | 描述                                       |
| ----- | ---------------------------------------- |
| 脏读    | 一个事务读取到了另外一个未提交的事务修改(Read-Committed)     |
| 不可重复读 | 同一个事务对同一个数据的读取，得到了两种不一样的数据，一般是另外一个事务进行修改操作(Repeatable-Read) |
| 幻读    | 幻读一般是指事务a去获取某个表的记录，然后这个时候事务b去插入或者删除了这张表，导致事务a好像产生了幻觉一样，产生了两条不同的数据。(Serializable)  测试：事务a开始，然后查询某张表count(*) ,事务b插入一条数据，并提交;  这个时候事务a并不能察觉到事务b对该表的提交，事务a提交事务后。再去开启新的事务读，然后发现数据量变成多1了，这就是幻读。 |