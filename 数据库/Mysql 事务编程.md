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
	create TABLE t (a int primary key)
	engine=INNOB;

2.开始事务
	begin
	一系列操作
    ...
    ...
    commit 提交
    rollback 如果没有commit，而是输入rollback，则回滚，撤销本次所有未提交事务的操作

```

