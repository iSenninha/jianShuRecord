### MySQL聚合函数

- GROUP_CONCAT函数

  先创建如下表:

  ```
  create talbe test (a int, b int);
  insert into test select 1, 100;
  insert into test select 2, 200;
  insert into test select 1, 200;
  insert into test select 2, 100;

  //然后
  mysql> select a,group_concat(b) from test group by a;
  +------+-----------------+
  | a    | group_concat(b) |
  +------+-----------------+
  |    1 | 100,200         |
  |    2 | 100,200         |
  +------+-----------------+
  2 rows in set (0.00 sec)

  //如果不进行分组，就全部加到了第一个上去了
  mysql> select a,group_concat(b) from test;
  +------+-----------------+
  | a    | group_concat(b) |
  +------+-----------------+
  |    1 | 100,100,200,200 |
  +------+-----------------+

  //还可以自定义替换连接时候的分隔符，去重，排序
  mysql> select a, group_concat(distinct b order by b desc separator':') from test group by a;
  +------+-------------------------------------------------------+
  | a    | group_concat(distinct b order by b desc separator':') |
  +------+-------------------------------------------------------+
  |    1 | 200:100                                               |
  |    2 | 200:100                                               |
  +------+-------------------------------------------------------+
  2 rows in set (0.00 sec)



  ```

  ​