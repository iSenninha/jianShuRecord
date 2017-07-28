###Log4j学习

> 之前一直有在用Log4f,但是没有系统学习过,现在把这个系统地学习一下..

#####1.核心对象和支持对象
######核心对象包括:Logger,Layout,Appender
Logger对象负责获取日志信息,我理解的就是去获取日志信息,就是用户代码里直接体现的
Layout提供了各种风格格式化
Appender将信息发布到不同的地方去,比如控制台或者其他地方

######支持对象:Level,Filter,ObjectRenderer,LogManager
Level:定义了日志信息的粒度和优先级:OFF、DEBUG、INFO、ERROR、WARN、FATAL、ALL
Filter:辅助Appender对象去过滤决定是否需要将日志信息发布到目的地
ObjectRenderer:ObjectRenderer 对象负责为传入日志框架的不同对象提供字符串形式的表示,Layout 对象使用该对象来准备最终的日志信息。
LogManager:对象管理日志框架,它负责从系统级的配置文件或类中读取初始配置参数。

#####2.Log4j用法示例
> Log4j.properties文件是Log4j的配置文件,默认情况下放到src目录下即会自动查找到

语法示例:
```
#定义输出级别为DEBUG，后面的那个为定义的输出信息（包含输出位置这些信息）
log4j.rootLogger=DEBUG,first

#定义输出的目的地,控制台
log4j.appender.first=org.apache.Log4j.ConsoleAppender

#定义输出的格式,常用参数列表如下，下面的第一行感觉是为first的PatterLayout变量赋值，然后在下一行继续去详细定义
log4j.appender.first.layout=org.apace.Log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern = %-d{yyyy-MM-dd HH:mm:ss} [%c]-[%p] %m%n
```

配置参数详解：

|参数|描述|实例|
|:---:|:---:|:----:|:---:|
|c|输出Logger所在的类别(即Logger的名字)|%c将输出完整的com.log4j.Log4jTest   %c\{1}将输出Log4jTest 从右往左数的第n个
|C|输出Logger所在类的名称|%C(大写的C),与上面的小写的c的区别是,如果代码是如下	private static Logger logger = Logger.getLogger(Object.class); 小写的c会输出Ojbect,大写的C会输出logger实际在哪个类进行了日志输出
|
|d|输出日期格式化|%d{yyyy-MM-dd HH:mm:ss}
|F|输出所在的类文件名称|%F将输出所在类的那个地方|
|l|输出语句所在的行数,包括类名,方法名,文件名,行数等|%l 将输出详细的log位置|
|L|输出所在的行数|%L将输出所在的行数
|p|输出日志级别|DEBUG,INFO,ERROR
|M|输出方法名|%M将输出main,如果是在构造方法里输出日志,将是init
|m|表示输出的日志,即message|%m
|n|换行|换行
|t|输出当前线程的名称|%t
|%|%%用来输出百分号|输出百分号
|r|程序启动到日志输出的时间间隔|%r

#####3.日志级别
ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF
需要是大于某个级别的日志才会输出

#####4.输出目的地
ConsoleAppender
FileAppender
JDBCAppender
RollingFileAppender

#####5.日志格式
DateLayout
HTMLLAyout
PatternLayout 上面的示例用的是PatternLayout
SimpleLayout
XMLLAyout

#####6.FileAppender的一些参数
```
# Define the root logger with appender file
log4j.rootLogger = DEBUG, FILE
# 设置日志目的地
Log4j.appender.FILE=org.apache.Log4j.FileAppender
# 设置日志文件名
log4j.appender.FILE.File=${log}/log.out
#  设置日志输出流是否每次都刷新到文件中去
log4j.appender.FILE.ImmediateFlush=true
# 设置appender对象的阀值，覆盖初始化的那个阀值
log4j.appender.FILE.Threshold=debug
# 默认是追加到文件的末尾，这里false是指覆盖
log4j.appender.FILE.Append=false
# 是否打开缓冲区读写
log4j.appender.FILE.BufferedIO=false
# 如果打开缓冲区读写，默认的缓冲为8kb
log4j.appender.FILE.BufferSize=8KB
# 设置输出格式
log4j.appender.FILE.layout=org.apache.Log4j.PatternLayout
log4j.appender.FILE.layout.conversionPattern=%m%n
```

> ps:关于大小写，如果value那边是一个类的话，左边的key就是首字母小写的驼峰命名，如果右边是一个参数的话，可以就是首字母大些的驼峰命名


#####7.RollingFileAppender
RollingFileAppender继承于FilaAppender，有FileAppender的所有属性，可以在日志文件大到一定阀值的情况下写入另外一个文件
```
#设置单个文件的最大大小
log4j.appender.FILE.MaxFileSize=5KB
# 即设置保留的日志个数
log4j.appender.FILE.MaxBackupIndex=2
```

#####8.DailyRollingFileAppender
根据日期为分割输出多个日志文件
```
#每天中午和午夜回滚文件，即一天回滚两次
log4j.appender.FILE.DatePattern='.' yyyy-MM-dd-a

#每天午夜回滚文件
log4j.appender.FILE.DatePattern='.'yyyy-MM-dd
#以此类推，yyyy-MM最后一个即为回滚的最小单位
#根据地域每周的第一天回滚
log4j.appender.FILE.DatePattern='.'yyyy-ww
```

#####9.使用数据库记录日志
使用数据库记录日志之前需要新建对应的数据库和表
```
log4j.appender.db = org.apache.log4j.jdbc.JDBCAppender
#设置缓冲区大小，就是够多少条日志了执行一次插入，这里的DATABASE是自定义的
log4j.appender.DATABASE.BufferSize=1
#设置驱动
log4j.appender.DATABASE.Driver=com.mysql.jdbc.Driver
#设置url
log4j.appender.DATABASE.URL=jdbc:mysql://localhost/DBNAME
#设置用户名
log4j.appender.DATABASE.User=user_name
#设置密码
log4j.appender.DATABASE.Password=password
#设置每次记录日志触发的sql，这里的x好像是os的用户id
log4j.appender.DATABASE.sql=INSERT INTO LOGS VALUES('%x','%d','%C','%p','%m')

```

####总结
使用log4j的配置文件如下：
######1.定义rootLogger
log4j.rootLogger = ERROR,console
第一个是日志输出等级，第二个即是我们自定义的输出的位置

######2.然后继续去补充输出位置的配置console的详细信息
log4j.appender.console = org.apache.log4j.ConsoleAppender

######3.配置该输出位置的其他属性
比如如果输出目的地是数据库的话，需要配置驱动等

######4.配置输出配置的格式
log4j.appender.console.layout = org.apache.log4j.PatternLayout

######5.然后配置输出格式的属性
log4j.appender.console.layout = org.apache.log4j.PatternLayout

> 最后，关于配置信息中的大小写问题如下，我的总结如下：
关于大小写，如果value那边是一个类的话，左边的key就是首字母小写的驼峰命名，如果右边是一个参数的话，可以就是首字母大些的驼峰命名




