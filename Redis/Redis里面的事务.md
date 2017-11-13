### Redis里面的事务

> Redis事务可以一次执行多个指令，确保事务内的多条指令串行执行，而不会被其他事务打断。并且事务是一个**原子操作**，要么全部执行，要么全部不执行。

- 下面给出Redis事务相关的所有指令

|   命令    | 含义                       |
| :-----: | ------------------------ |
|  multi  | 事务开始的标志                  |
|  exec   | 事务结束的标志                  |
|  watch  | 监控某个键，如果这个键发生变化，整个事务将被打断 |
| unwatch | 取消监控某个键                  |
| discard | 放弃此次事务内的所有操作             |



- 开始事务

  事务以**Multi**开始

  ​

- 结束事务

  事务以**exex**结束

  ​

- 下面给出一个示例

  事务的操作：

  ```
  multi

  set senninha senninha

  set senninha1 senninha1

  exec127.0.0.1:6379> multi
  OK
  127.0.0.1:6379> set senninha senninha
  QUEUED
  127.0.0.1:6379> set senninha1 senninha1
  QUEUED
  127.0.0.1:6379> exec
  1) OK
  2) OK
  127.0.0.1:6379> 
  ```

  注意一开始所说的**原子性**，在同一个事务中的命令是在**Queue**中等待运行，如果任意一条执行无法执行，那么整个事务的其他操作也无法提交，如下：

  ```
  127.0.0.1:6379> multi
  OK
  127.0.0.1:6379> set senninha senninha
  QUEUED
  127.0.0.1:6379> senninha1 senninha1
  (error) ERR unknown command 'senninha1'
  127.0.0.1:6379> exec
  (error) EXECABORT Transaction discarded because of previous errors.
  ```

  这里是因为语法错误导致的操作无法进行，整个操作就没有继续下去。



- 下面是watch的用法

  **watch**监控某个键需要在进入事务**multi**之前运行（**unwatch**也是），如下：

  ```
  127.0.0.1:6379> watch senninha
  OK
  127.0.0.1:6379> multi
  OK
  127.0.0.1:6379> set senninha senninha
  QUEUED
  127.0.0.1:6379> exec
  (nil)
  //其他事务在本次事务提交前执行了修改senninha的操作，导致本次事务被中断
  ```

  ​

  ​

  ​



