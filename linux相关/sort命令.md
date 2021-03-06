### sort命令
> sort命令是用来排序的一个命令，掌握这个命令主要是熟悉参数的设置

#####-u去重
```
sort -u /目标文件
```
这样输出的结果是不带重复的

#####-r降序排列
默认是用升序排列的，加入-r参数变成降序排列

#####-o输出结果
加入-o选项，把输出结果重新输出到文件
```
sort -u /tmp/text.txt -o /tmp/newtext.txt
```

#####-n以数字排序
如果不加-n，是以ascii来排序的，那么就可能出现11比2小的情况，这个时候加上-n选项就可以解决这个问题了。

#####指定列数据排序-t,-k
-t指定分隔符，-k指定用第几列排序
```
sort -t -k /tmp/text
```

#####其他常用的选项
```
-f 会把大小写字母都转换成大写字母来比较，即忽略大小写
-c 会检查文件是否已经排好序，如果否，则会输出第一个乱序行的信息
-C 同上，但是不输出乱序信息
-M 会以月份来排序，比如JAN小于FEB
-b 会忽略空白行，从第一个可见的字符开始比较
```

#####-t -k的高级用法
首先来一个待处理素材
> 37 2000 
meituan 5000
yy 2000


- 以公司名升序排列，人数降序排列
```
sort -t " " -k 1 -k 2r text
```

- 以公司名的第二个字母排序
```
sort -t " " -k 1.2
```
