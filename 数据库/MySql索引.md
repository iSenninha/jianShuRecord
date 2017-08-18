### MySql索引

- 可将数据库的应用类型分为OLTP(OnLine Transaction Processing ，联机事务处理)和OLAP(OnLine Analysis Processing，联机分析处理)两种



- 根据Cardinality来判断索引是否有效

  ```
  show index from xx_table;
  即可察看cardinality的值，这个值表示表中主键互不相同的数目由多少
  定义一个值total表示当前表的总数目
  total/cardinality 这个值越接近1表示这个索引的有效性最高
  ```

  ​

