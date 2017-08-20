### MySql查询处理

- 查询语句处理顺序

  > sql的查询语句不是按照编码顺序执行的，他的执行顺序是这样的。

  1. FROM

     处理from字句，对多个表执行笛卡儿积，产生虚拟表VT1，作为处理的输入传递给下一个表

  2. ON

     对虚拟表VT1执行限制条件，只有满足条件的表才会放入VT2中

  3. JOIN

     根据join的描述继续对VT2进行限制，放入VT3中(这一部分不太清楚)

     四种连接，分别是左外连接，右外连接，内连接和全连接。

     先来看内连接和左外连接的区别：

     两张表的所有内容如下：

     ```
     mysql> select *from orders;
     +----------+-------------+
     | order_id | customer_id |
     +----------+-------------+
     |        1 | 163         |
     |        2 | 163         |
     |        3 | 9you        |
     |        4 | 9you        |
     |        5 | baidu       |
     |        6 | NULL        |
     +----------+-------------+

     mysql> select *from customers;
     +-------------+-----------+
     | customer_id | city      |
     +-------------+-----------+
     | 163         | HangZhou  |
     | 9yo1        | GuangZhou |
     | 9you        | HangZhou  |
     | baidu       | GuangZhou |
     +-------------+-----------+
     ```

     分别用左外连接和内连接作查询：

     ```
     //左外连接：
     mysql> select *from orders as o left join customers as c on o.customer_id = c.customer_id and c.city = "HangZhou";
     +----------+-------------+-------------+----------+
     | order_id | customer_id | customer_id | city     |
     +----------+-------------+-------------+----------+
     |        1 | 163         | 163         | HangZhou |
     |        2 | 163         | 163         | HangZhou |
     |        3 | 9you        | 9you        | HangZhou |
     |        4 | 9you        | 9you        | HangZhou |
     |        5 | baidu       | NULL        | NULL     |
     |        6 | NULL        | NULL        | NULL     |
     +----------+-------------+-------------+----------+

     //内连接
     mysql> select *from orders as o join customers as c on o.customer_id = c.customer_id and c.city = "HangZhou";
     +----------+-------------+-------------+----------+
     | order_id | customer_id | customer_id | city     |
     +----------+-------------+-------------+----------+
     |        1 | 163         | 163         | HangZhou |
     |        2 | 163         | 163         | HangZhou |
     |        3 | 9you        | 9you        | HangZhou |
     |        4 | 9you        | 9you        | HangZhou |
     +----------+-------------+-------------+----------+
     4 rows in set (0.00 sec)
     ```

     > 首先连接查询会在on条件下作一次筛选，把满足条件的行插入虚拟表
     >
     > 如果是外连接查询，会保留表中(左连接的话就是左表)未被匹配的行加入虚拟表，然后传递给下一个过滤查询操作。
     >
     > 在这里，如果是内连接的话，查询结果是4,
     >
     > 如果是左外连接，左表orders里有六个条目，尽管只有四个条目才满足条件(这个是在on里过滤出来的虚拟表)，但是因为是left join，所以又添加了没有被匹配的外部行，所以总共生成了和orders里条目一样的六行，不满足条件的字段显示null。

     所以，inner join的话，处理的就是on里面的匹配条件，外连接的话，还需要添加未匹配的外部行，然后全连接其实就是笛卡尔积。

     ps：如果在on里之匹配相同的字段的话，比如这样：

     ```
     mysql> select *from orders as o join customers as c on o.customer_id = c.customer_id;
     +----------+-------------+-------------+-----------+
     | order_id | customer_id | customer_id | city      |
     +----------+-------------+-------------+-----------+
     |        1 | 163         | 163         | HangZhou  |
     |        2 | 163         | 163         | HangZhou  |
     |        3 | 9you        | 9you        | HangZhou  |
     |        4 | 9you        | 9you        | HangZhou  |
     |        5 | baidu       | baidu       | GuangZhou |
     +----------+-------------+-------------+-----------+
     5 rows in set (0.00 sec)

     mysql> select *from orders as o join customers as c using(customer_id);

     //可以用Using简化，两者是一样的。
     ```

     ​

     ​

  4. Where

     对VT3进行条件过滤，只有符合条件的才会放入VT4表中

     > where 条件里不可以进行类似min(xx)之类与分组有关的函数，因为此时还未进行分组。

  5. GROUP BY

     对VT4中的记录进行分组操作，产生VT5

  6. HAVING

     对虚拟表VT5进行过滤，满足条件的加入虚拟表VT6

  7. SELECT

     第二次执行select操作，选择指定的列，插入到虚拟表VT7中

  8. DISTINCT

     去除重复数据，产生虚拟表VT8，如果进行了Group by操作，distinct操作是多余的，因为group by已经做了去重操作

  9. ORDER BY

     按照顺序排列产生虚拟表VT9

     在书写sql语句的时候如果需要要求查询顺序，必须显式地调用order by 。

     另外，如果对一个没有添加索引的字段进行order by操作，可以通过 ***show status like '%sort%' ***来查看排序的操作，必要时可以通过添加索引来减少排序的开销

     ​

  10. LIMIT

    取出指定行，产生虚拟表VT10

    limit n,m 表示从n(包括n)开始获取n个数据，一般web应用经常使用limit进行分页操作，但是如果在数据量很大的情况下，比如从50w开始查询10个数据，可能会导致性能问题，比如这样：

    ```
    (1)select *from orders limit 100000,10;
    (2)select *from orders limit 1,10;
    //前者会慢出翔，然后：
    (3)select *from orders where _id < (select _id from orders order by id limit 100000,1) limit 10
    //这个查询是非常快的
    //优化的原因(个人猜测的)，语句1不会使用索引
    //语句（2）会使用覆盖索引，不用读取大量的数据进入内存？
    ```

    ​

> 有三种过滤器，分别是On(连接的时候的限制条件)，Where(一般的限制条件)，Having(group by的限制条件)。On是最先执行的过滤过程
>
> 可以在一个语句前加explain来分析整个sql处理的过程来判断是否需要优化。

​	11.查询表

```
show tables like "%xxx%";
```

