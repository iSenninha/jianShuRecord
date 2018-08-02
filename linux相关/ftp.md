### ftp上传下载
使用命令行进行ftp上传下载操作。有两种方式，一种是交互式，另外一种是非交互式。同时有两种比较成熟的工具可以提供这个操作，分别是**ftp**(有些发行版没有)和**curl**(惊喜不惊喜)

[TOC]

#### 1.ftp命令
- 交互式
  交互式的实现其实看man就可以了，非常简单，主要包括以下几个点：
```
ftp
open host port
username
password
```
so easy,然后进行ls，cd，remove操作什么的，稳的一笔

- 非交互式
  非交互式比较麻烦：
```
	ftp -n <<EOF
	open ftp.example.com
	user user secret
	put my-local-file.txt
	EOF
```
使用eof的方式，有点奇怪。。。另外，用这种方式，我还没有在脚本里调用。。囧


#### 2.curl命令
man一下curl，你会发现，这货什么鬼玩意都支持。。。

- 非交互式下载文件
```
	curl fpt://xxx.com:port/fileName --user username:password
```

- 非交互式浏览目录
```
	curl ftp://xxx.com:port/directory --user username:password;
```

- 非交互式上传文件
```
	curl -T fileName ftp://xxx.com:port --user username:password;
```
