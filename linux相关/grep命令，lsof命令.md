## grep命令，lsof命令

### grep命令

1. 查找某个关键字以及**以上**或者**以下**的内容或者**上下n行**

   ```
   grep -B x行 关键字 目标文件 //查找目标文件所有关键字的文件并且显示以上一行
   grep -A y行 关键字 目标文件 //查找目标文件所有关键字的文件并且显示以下一行
   grep -C z行 关键字 目标文件 //查找目标文件所有关键字的文件并且显示上下一行
   ```

2. -a，-b，-c，-e，-v，-w

   ```
   grep -c 关键字 目标文件 //匹配目标关键字的总次数
   grep -b 关键字 目标文件 //匹配目标关键字偏移当前行的行数
   grep -a 关键字 目标文件 //表示当成二进制文件搜索
   grep -e 正则表达式 目标文件 //匹配对应的正则表达式
   grep -f 关键词文件 目标文件 //将关键词文件的每一行作为关键字匹配目标文件
   grep -m 匹配次数 关键词 目标文件 //匹配关键字几次后就停止
   grep -n 关键词 目标文件 //在输出前打印出行号
   grep -o 关键词 目标文件 //只输出匹配的关键词
   grep -v 关键字 目标文件 //查找不匹配该关键字的行
   grep -w 一个词 目标文件 //表示匹配一个词，一个词前后都必须是空格或者换行
   grep -R 关键词 * 搜索当前目录的以及子目录下匹配的关键词
   ```

3. 正则匹配

   ```
   ^表示字符串的开头
   $表示字符串的结束
   ```

   ​

### lsof命令

> ```
> COMMAND:进程的名称 
> PID:进程标识符
> USER:进程所有者
> FD:文件描述符，应用程序通过文件描述符识别该文件。每个进程都有自己的文件描述符表，因此FD可能会重名
> TYPE:文件类型
> DEVICE:指定磁盘的名称
> SIZE:文件的大小
> NODE:索引节点（文件在磁盘上的标识）
> NAME:打开文件的确切名称
> ```

1. -p  输出对应的进程id的情况

   ```
   senninha@senninha-37:~/jianShuRecord$ lsof -p 1776
   COMMAND  PID     USER   FD      TYPE DEVICE SIZE/OFF NODE NAME
   chrome  1776 senninha  cwd   unknown                      /proc/1776/cwd (readlink: Permission denied)
   chrome  1776 senninha  rtd   unknown                      /proc/1776/root (readlink: Permission denied)
   chrome  1776 senninha  txt   unknown                      /proc/1776/exe (readlink: Permission denied)
   chrome  1776 senninha NOFD                                /proc/1776/fd (opendir: Permission denied)

   ```

2. -i 输出网络

   ```
   lsof -i4 //输出ipv4的连接情况
   lsof -i6 //输出ipv6的连接情况
   lsof -i //输出所有的网络连接
   lsof -i :prot //查看某个端口的使用情况
   lsof -iTCP:8080 -sTCP:LISTEN //输出所有处于LISTEN状态的并且端口号等于8080的端口(可以省略指定的版本号)
   lsof -i :port -r 秒 //每隔多少秒显示一次

   ```

3. 查找是谁在使用某个文件

   ```
   lsof /home/senninha/jianShuRecord/xx.txt
   ```

   ​

   ### tr命令

   ```
   //去除所有的换行符，并且把结果重新定向到新文件hello_nor.txt
   //如果把后面的重定向去掉的话，那么会直接输出到屏幕上
   tr -d "\n" < hello.txt > hello_nor.txt

   //删除连续字符的第一个
   //s是squeeze的意思，挤压。。即压缩
   tr -s "[a-z]" < hello.txt

   //大小写转换
   tr "[a-z]" "[A-Z]" < hello.txt 
   ```



	### sed命令

