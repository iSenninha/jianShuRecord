### MySql数据类型

- 整数类型

  |   数据类型    |         含义         |
  | :-------: | :----------------: |
  |  tinyint  |   一个字节(-128-127)   |
  | smallint  | 两个字节(-32768-32767) |
  | mediumint |        三个字节        |
  |    int    |        四个字节        |
  |  bigint   |        八个字节        |

- 浮点数

  float,double

- 定点数

  deciam(m,n) m是总个数(<=64)，n是指小数位数

- 日期和时间

  date,time,datetime,timestamp,year

  |   数据类型    |                    含义                    |
  | :-------: | :--------------------------------------: |
  |   date    |           日期(yyyy-MM-dd)（三个字节）           |
  |   time    |            时间(hh:mm:ss)(三个字节)            |
  | datetime  |        yyyy-MM-dd hh:mm:ss(八个字节)         |
  | timestamp | 自动储存记录修改时间(建表的时候设置 time_stamp TIMESTAMP ON UPDATE CURRENT_TIMESTAMP)(四个字节) |
  |   year    | 一个字节(可选位宽，m=2,显示1970-2069,m=4,1901-2155  |

  > 与时间有关的函数
  >
  > now():
  >
  > current_timestam()
  >
  > sysdate()

- 字符串

  char(m)可以指定长度，按指定的长度分配字符

  varchar(n)可变字符串，实际长度按实际长度+1

  > show CHARSET //可以看到所有的字符集
  >
  > status 查看到当前使用的字符集等命令

- 文本

  tinytext(2^8),text(16)mediumtext(24),longtext(32)在其上指定索引的时候，必须指定索引前缀的长度

- 二进制

  tinyblob(8),blob(16),mediumblob(24),longblog(32)

  ​

  ​