###lsof命令
> linux里的一切皆文件，而lsof即是**list open files**的意思。

- lsof打开的文件可以是：
  - 普通文件
  - 目录文件
  - 网络文件系统的文件
  - 字符或设备文件
  - (函数)共享库
  - 管道，命名管道
  - 符号链接
  - 网络文件(socket)
  - 其他类型的文件

- 查看打开某个文件的进程相关的进程
  ```
  lsof /bin/sh
  COMMAND   PID     USER  FD   TYPE DEVICE SIZE/OFF    NODE NAME
bash     1866 senninha txt    REG    8,7  1099016 2097158 /bin/bash
bash     6046 senninha txt    REG    8,7  1099016 2097158 /bin/bash
bash    13178 senninha txt    REG    8,7  1099016 2097158 /bin/bash
  ```

- 列出某个用户打开的信息
  ```
  lsof -u username
  ```

- 列出某个命令打开的所有文件信息
  ```
  lsof -c java
  //这里不是填入进程id，而是某个command，就是命令
  ``` 

- 列出某个进程打开的所有文件
  ```
  lsof -p xxxx
  ```

- 列出某个用户某个命令打开的文件信息

  ```
  lsof -u username -c java
  ```

- 列出所有的网络链接
  ```
  lsof -i
  lsof -i tcp
  lsof -i :3306//看谁在用这个端口
  lsof -a -u username -i //列出某个用户的所有活跃端口
  ```

- 根据文件描述列出对应的文件信息
  这个命令的用途应该就是如果某个文件被占用了，那么就可以用这个命令去查找
  ```
  lsof -d lsof
  //貌似只能查询文件夹--
- ```
