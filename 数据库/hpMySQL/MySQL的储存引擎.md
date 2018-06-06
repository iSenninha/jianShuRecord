### 事务基础

#### ACID
ACID指的是事务的Atomicity,Consistency,Isolation,Duarbility

#### 隔离级别
隔离级别包括：Read Uncommited,Read Committed,Repeatable Read,Serializable
分别解决对应的:脏读,不可重复读，幻读

#### 事务日志
事务日志的工作原理是，每一次的修改是直接修改内存，然后记录对应的事务日志追加进磁盘，只是在小片范围内做磁盘IO，速度比直接持久化快。然后由后台进程根据事务日志持久化进磁盘，同时，如果这个时候突然断电，重启后会继续读取事务日志继续持久化进磁盘。

#### MySQL中的事务提交
MySQL默认是使用自动提交事务的，也就是每一句SQL都会自动开启事务并提交。查看当前的配置如下：
```
MariaDB [(none)]> show variables like "%autocommit%";
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| autocommit             | ON    |
| wsrep_retry_autocommit | 1     |
+------------------------+-------+
2 rows in set (0.00 sec)

```
在当前Session中设置关闭自动提交：

```
set autocommmit = 0
```
另外，某些SQL会强制执行commit，比如DDL语句(Data Definition Languages)


#### 设置事务隔离级别
查询当前的事务隔离级别
```
show variables like '%isolation%';

```
在当前会话设置事务隔离级别

```
set session transaction isolation level read committed
```
整个数据库的话，去掉session即可

#### MVCC(MultiVersion Concurrent Control)多版本并发控制
多版本并发控制可以不加锁的情况下解决部分问题。
它在每一行隐藏两列数据：行的创建时间和行的失效时间，这个时间不是真正的时间戳，而是递增的事务操作序号。
- select
获取创建时间小于当前事务的行
获取失效时间戳为未定义或者大于当前的版本号(后者表明是在其他版本更新的事务作了删除，为了防止幻读或不可重复读，在本次事务当成未删除来处理)

- insert
插入当前事务版本到行的创建时间

- update
更新操作会新插入一行数据，然后创建时间为当前版本，原来的那行数据的失效行也更新为当前版本，也就是说，一次更新操作，其实在某种意义上来说是插入

#### 查看表的使用的储存引擎
其实也是用show语句
```
show tables status like "表名"

```

#### 修改表的储存引擎
```
alter table talbe_name engine = InnoDB
```
需要注意的是，修改引擎其实是把原来引擎的表按新的引擎的数据结构重建，会锁住原来的表并且会丢失类似索引，外键。
使用以下的方式可以避免锁表,分步进行避免锁表:
```
create table new_table like old_table;
alter table new_table engine = InnoDB;
insert into new_table select *from old_table where xx between 1 and 2;
```

