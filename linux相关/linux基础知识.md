####1.察看当前目录文件
	ls
	ls -a 察看当前所有的文件，包括所有以.开头的隐藏文件
	ls -p 人性化察看文件
	ls -l 列出详细信息以及操作权限（别名ll)
	ls -t 以时间排序
	ls -s 在列出的每一个文件前列出大小
	ls -S 以文件大小排序
	ls -R 递归列出所有的文件  ctrl+c终止命令执行

####2.创建文件夹
	mkdir 
	mkdir /senninha/mclaren 如果没有sennina目录是无法创建这个mclaren的，这个时候就要用到
	mkdir -p /senninha/mclaren 递归创建

####3.cd打开文件
	cd
	cd ..打开上一层目录
	cd -打开上一次打开的目录
	
	
####4.删除目录或者文件
	rm 
	rm -r 删除目录
	rm -rf 强制删除目录文件 谨慎使用，会导致linux自杀
	
####4.复制
	cp xxx  /senninha/bbb  将xxx复制到/senninha并且改名为bbb，如果不加bbb，则原名复制
	cp -r 复制目录
	cp -p 连带文件属性一起复制
	cp -d 复制链接属性
	cp -a 相当于-pdr 就是复制目录所有的属性

####5.剪切(改名字的命令)
	mv xxx /senninha 剪切xxx到senninha目录下
	如果剪切的源位置和目标位置在同一个目录下就是重命名。

####6.链接命令
	LiNk
	ln -h 硬链接
		ln -h /原文件 /硬链接名
		硬链接的和原文件一模一样，共同指向同一个磁盘位置，有相同的inode
		
	ln -s 软连接
		通过原文件的文件名来记录文件的位置，通过找到那个原文件的inode再连接到磁盘里
		和硬链接不同的点是通过文件名找到原文件没有inode的
		而硬链接是有和原文件相同的inode的

####7.搜索命令
	locate xxx 通过数据库查找文件，这个不是实时更新的
	updatedb 强制更新数据
	
8.搜索命令的命令
```
where ls 搜索命令在那里
whatis ls 可以看到ls的使用方法
whatami 可以查看当前的root	
echo$PATH 放命令的地方
```
####9.文件搜索命令find
	find /root -name "ab?[cd]*" 在/root下搜索名字为ab+任意一个字符+[cd]+任意一个或者多个字符
	find /root -iname "xx" 不区分大小写
	fina /root -nouser "xx" 查找没有用户的文件
	这个命令是完全匹配文件名字的，如果需要模糊匹配，需要加通配符。
	
	按时间来搜索
	find /root -mtime +10 查找前修改的文件 -10 十天前内修改的文件 10十天修改的文件
	find /root -atime +10 文件访问的时间
	find /root -ctime +10 改变文件属性

	按文件大小来搜索，
				-size 25k 等于25k的文件
				-size +25k 大于25k的文件
				-size +2M 小于2M的文件
				
				-a and逻辑与
				-o or逻辑或
	搜索文件大小在20k到35k的文件并且列出来
				find /root -size +20k -a -size +30k -exec ls -h{} \;
				
	通过i节点来搜索文件
				-inum 323 查找323i节点的文件
				
	搜索得到结果后直接对结果操作
	find /root -name "senninha" -exec rm -rf {} \;表示删除掉搜索得到的senninha文件

####10.grep命令，搜索文件中的字符串
	grep "s" install.log 搜索 “”内容在install.log 文件里
	
####11.察看已安装软件以及卸载软件
	rpm -q -a 察看所有已安装的软件
	rpm -e 上条语句获取的详细包名
	rpm -ql 包名 可以获取具体安装到哪个文件夹
	
####12.下载文件
	wget常用参数：
	-b 后台下载
	-O 下载到指定目录
	-c 断点续传，如果下载中断，那么下次下载从断点处下载
	-r 递归下载，就是说后面跟个网站的话，可以将网站所有的子目录全下下来。

####13.关闭触摸板
	modprobe -r psmouse

####14.将函数定义在.profile文件中可以被全局调用

####15.需要后台运行某个操作 + &
	比如： chrome &
