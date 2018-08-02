### 如何看explain

> explain是优化查询的一个非常强大的工具，来学习一下如何看explain。


[TOC]

#### 1.explain的组成
```
MariaDB [employees]> explain select count(*) from employees;
+------+-------------+-----------+-------+---------------+---------+---------+------+--------+-------------+
| id   | select_type | table     | type  | possible_keys | key     | key_len | ref  | rows   | Extra       |
+------+-------------+-----------+-------+---------------+---------+---------+------+--------+-------------+
|    1 | SIMPLE      | employees | index | NULL          | PRIMARY | 4       | NULL | 299556 | Using index |
+------+-------------+-----------+-------+---------------+---------+---------+------+--------+-------------+
1 row in set (0.00 sec)
```
以上是一个最简单的explain分析一个查询语句。下面来解析每个字段的含义。

- id
  表示查询的id

- select_type
  查询的类型

- table
  关联的表

- type
  这个查询是如何找到数据的，这里包括一大堆类型
  - system 行为0或者只有一行
  - eq_ref 索引是主键,或者是非空唯一索引,是一般来说最佳查询
  - ref 所有的查询条件都用到了索引
  - fulltext 使用了全文索引
  - ref_or_null 和ref相同，但是有可能是为null的索引
  - index_merge 使用了几个索引来完成这个查询
  - unique_subquery 使用in的查询的时候用到了主键索引
  - index_subquery 和上面那个一样，只是返回超过一个结果列
  - range 索引被用在类似between之类的范围查找
  - all 全表扫描，最糟糕的方式

- possible_keys
  可能使用的索引

- key
  指明当前查询用到的索引key

- key_len
  使用的索引的长度

- ref
  与主键比较的值是常数或者是其他？(The columns compared to the index)

- rows
  生成结果过程中检查的行数

- extra
  查询过程中其他的操作，比如using filesort之类


[EXPLAIN Output Format](https://dev.mysql.com/doc/refman/8.0/en/explain-output.html)
