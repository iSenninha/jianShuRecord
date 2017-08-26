### Mysql储存过程

> Mysql储存过程，其实是把sql语句在数据库里封装起来，对外只提供一个函数接口。因为已经预编译过了，所以执行速度比直接在程序里写sql语句快。



- 简单demo

```
首先是改变结束符号，防止编写过程中提早结束这个语句

DROP PROCEDURE IF EXISTS proc; 

delimiter //
create procedure proc()
begin
select *from x;
end //

恢复结束符号
delimiter ;

调用：
call proc;
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

```

