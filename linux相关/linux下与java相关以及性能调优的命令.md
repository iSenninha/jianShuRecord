linux下与java和性能调优相关的命令

####查看java进程
jps 列出所有java的进程,和ps类似,但是它只列出java的进程
-q 只输出进程id,不输出类的短名称
-m 输出传递给main函数的参数
-l 输出主函数的完整路径
-v显示传递给虚拟机的参数,比如堆大小之类的

####查看虚拟机运行时的信息
jstat -gc查看与gc相关的信息

####查看虚拟机参数
jinfo 
还可以动态修改某些参数

####导出堆快照
jmap -dump:format=b,file=/tmp/heap.hprof 线程名

####自带的分析java应用程序的快照,用http服务器运行
jhat jamp导出的堆文件
然后浏览器访问127.0.0.1:7000

####打印线程相关的信息
jstack -l pid 可以使用输出重定向保存到文件