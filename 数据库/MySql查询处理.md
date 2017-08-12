### MySql查询处理

- 查询语句处理顺序

  > sql的查询语句不是按照编码顺序执行的，他的执行顺序是这样的。

  1. FROM

     处理from字句，对多个表执行笛卡儿积，产生虚拟表VT1，作为处理的输入传递给下一个表

  2. ON

     对虚拟表VT1执行限制条件，只有满足条件的表才会放入VT2中

  3. JOIN

     根据join的描述继续对VT2进行限制，放入VT3中(这一部分不太清楚)

  4. Where

     对VT3进行条件过滤，只有符合条件的才会放入VT4表中

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
     select *from orders limit 100000,10;
     select *from orders limit 1,10;
     //前者会慢出翔，然后：
     select *from orders where _id < (select _id from orders order by id limit 100000,10) limit 10
     //这个查询是非常快，order by后会生成类似索引的东西，所以在这个时候使用limit的话会提速。
     ```

     ​

> 有三种过滤器，分别是On(连接的时候的限制条件)，Where(一般的限制条件)，Having(group by的限制条件)。On是最先执行的过滤过程

