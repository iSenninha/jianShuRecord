#### 多文件带文件名合并
有时候需要cat多个文件合并，需要标记一下该字段属于哪个文件，只是用cat的话，并不能实现，可以尝试用下面的方法:
```
tail -n +1 file1 file2 > total.log
```
-n 表示显示尾部x行，而+1表示的是从第一行开始，即是显示所有的行了(man tail)
结果就会指明具体的行数了
```
==> /tmp/10/fatal/PolarFatalError.log <==

==> /tmp/7057/fatal/PolarFatalError.log <==

```

