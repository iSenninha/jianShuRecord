###awk的一些奇迹淫巧
</br>
####统计文件夹的大小
```
ls -l | awk 'BEGIN {print "文件夹大小:"; size=0} {size=size+$5} END {print "print size/1024 "m"}'
```
ls -l后第五列的值就是大小，自增这个列的值就行了

</br>

####一键提交svn
- 提交新增文件
```
svn add $(ls -l | awk '{if($1="?"){print$2}}')
```
- 删除文件
```
svn rm $(ls -l | awk '{if($1="!"){print$2}}')
```

> 其他奇迹淫巧待发现～
