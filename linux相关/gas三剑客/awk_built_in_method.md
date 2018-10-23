### awk内置函数
> 记录一下常用的awk内置函数 [参数](https://www.cnblogs.com/chengmo/archive/2010/10/08/1845913.html)


#### 1.字符串函数
- index(key, str)
  在str中搜寻key，下标从1开始，返回0表示没有搜索到。

- length(str)
  字符串长度

- substr(str, begin, end)
  截取字符串，也是从1开始,并且是左右都是闭区间的

- tolower(str) toupper(str)
  字面意思

- split(str, tArray, regex)
  支持正则表达式的分割，tArray保存的是分割后的字符串。
  ```
     awk 'BEGIN{tmpStr = "i am a split word;hahah;ffff"; split(tmpStr, tArray, ";"); for(i in tArray){print tArray[i]}}'
  ```
  需要注意的是，这个循环获取的是下标(python类似)，并不是直接foreach

#### 2.时间函数
- mktime("YYYY MM DD HH MM SS")
  生成时间

- strftime(format, timestamp)
  格式化时间,timestamp是秒时间戳,format格式和c语言相似，记住%c显示本地时间和日期

- systime()
  得到时间戳，也是秒时间戳

#### 3.执行调用外部程序
- system(command)
  ```
    awk 'BEGIN{b = system("ls -lh")}; print b'
  ```
  这里b是调用结果，并不是调用内容
