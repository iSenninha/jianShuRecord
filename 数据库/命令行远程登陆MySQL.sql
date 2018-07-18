### 命令行远程操作MySQL
这玩意其实Man一下就可以找到的。。。记一下吧

[TOC]

#### 1.交互式远程登陆
```
	mysql -uUserName -pPassword -hHost -Pport [db_name]
```
如果选择了[db_name]的话，登陆后状态就是那个db了


#### 2.非交互式操作
用MySQL client进行非交互式操作也是非常强大的。
- 远程执行sql语句
```
	echo "create database if is not exists senninha_db charset=utf8" | mysql -u -p -h 	
```
是的，mysql是支持接收重定向参数的，也可以通过指定 -Bse参数，不通过重定向的方式执行：
```
	mysql -u -p -h db_name -Bse "sql"
```
需要注意的是，多个sql之间用;号隔开，并且如果有特殊字符需要转义

- 远程导入SQL文件
远程导入SQL备份或者需要执行SQL文件的时候，也可以用MySQL命令行客户端去执行
```
	mysql -u -p -h db_name < sql.sql
	// 或者
	cat sql.sql | mysql -u -p -h db_name
```
这两种方法都可以远程更新执行SQL语句

#### 3.利用非交互式输出输出到数据到文件
```
	echo "select * from name;" | mysql -u -p -h db_name > tmp.file
```
