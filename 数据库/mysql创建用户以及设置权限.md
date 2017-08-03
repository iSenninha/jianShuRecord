###mysql新建用户并设置权限

&nbsp;

#####1.创建无密码的用户
```
create user senninha@localhost identified by '';
grant all(增删改查所有数据) on 数据库名 to 用户名@登录地址;
```

#####2.创建有密码的用户
```
grant all on * to senninha@localhost indentified by 'password';
```