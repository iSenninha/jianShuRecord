###crontab定时任务
> crontab是linux下的任务，使用cron表达式来描述在哪个时间点执行任务。
 

####启动定时任务服务
cron是linux下的内置服务，如果没有自动启动，可以用如下方式启动：
```
service crond start //启动
service crond stop //停止
service crond restart //重启
service crond reload //重新载入配置
```

####cron表达式
```
* * * * *
分别表示 分 小时 日 月 星期
特殊的，一个位置写多个数字表示的是这几个数字都执行，如：
1,2 * * * *	//表示逢1,2分执行任务

一段时间内执行任务的：
* 23-7/1 * * * 	//表示的是23点到第2天7:59，每隔一个小时执行一次任务
```

####配置定时任务
- 通过crontab命令配置
通过**crontab**命令配置，其实是通过这个命令编辑生成在/var/spool/cron目录下与用户名同名的文件来配置定时任务
```
crontab -e //编辑
crontab -l //列出任务
crontab -r //删除
crontab -u //指定查看哪个用户
```

- 通过直接配置/etc/crontab文件的方式配置
直接vi操作，需要注意的是，可以配置运行某个文件夹下的所有脚本，如下：
```
1 * * * * root run-parts /etc/cron.hourly //每个小时执行该目录下的所有脚本
```
