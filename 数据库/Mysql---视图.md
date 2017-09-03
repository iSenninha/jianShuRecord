### Mysql---视图

> 视图用就是将复杂的关联多表的数据用一个视图来描述，然后我们再在这个表上做简单查询

- 优点
  1. 简化复杂查询
  2. 安全性，比如只开放某些数据给某些用户。
- 缺点
  1. mysql对子查询的优化不好，性能不高。



- 操作

  - 建立视图

    > create view view_name as (select *from xxx)
    >
    > //前面是建立视图，后面是从现存的基表里获取要保存到视图里的内容。
    >
    > //然后就可以根据视图来做查询了,和对一般的表做查询没什么区别。
    >
    > select *from view_name;

  - 视图查询的算法

    > 可以在建立视图的时候就指定算法
    >
    > ```
    > create algorithm = [merge|temtable] view view_name as (select *from xxx)
    > ```
    >
    > 1. merge算法
    >
    >    就是完全使用子查询来作为视图查询的实现，由于mysql对子查询的优化不好，所以不推荐使用
    >
    > 2. temtable
    >
    >    生成临时表的方法来作实现视图查询。但是**无法**更新表
    >
    > 3. 无定义的话，mysql会倾向于使用merge算法来实现。因为可以更新。使用

  - 删除视图

    ```
    delete view view_name;
    ```

  - 查看视图

    > 1. 直接show tables 也可以看到新建的视图
    >
    > 2. 使用以下语句查看所有视图
    >
    >    ```sql
    >    mysql> select *from information_schema.views where table_schema = "test";
    >    //后面那个是数据库的名字.
    >    ```
    >
    > 3. 查询视图结构
    >
    >    desc view_name;

  > 视图一般用来查询数据。