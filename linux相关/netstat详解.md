### netstat 详解

> Netstat 命令用于显示各种网络相关信息，如网络连接，路由表，接口状态 (Interface Statistics)，masquerade 连接，多播成员 (Multicast Memberships) 等等。

|  参数  | 含义                                       |
| :--: | :--------------------------------------- |
|  -a  | 显示所有的参数                                  |
|  -p  | program的意思，显示程序名和进程id                    |
|  -n  | 默认会通过反向域名查询到对应ip的主机名，加入-n可以取消这个过程，加快查询速度 |
|  -t  | 只查询tcp                                   |
|  -u  | 只查询udp                                   |
|  -l  | 只列出处于监听状态的端口                             |
|  -s  | 打印统计数据                                   |
|  -r  | 显示内核陆游数据                                 |
|  -i  | 打印网络接口信息(类似)                             |
|  -e  | 显示附加信息，比如在 -ie 将会显示更加详细的信息               |
|  -c  | 持续输出信息 continue                          |

> 以上的参数组合起来可以有多种的方式使用。

- 列出所有的端口(-a)

```
net -a
```

- 列出所有的tcp端口

```
net -at
//同理，udp
net -au
```

- 列出所有处在listen状态的端口

```
net -l
//同理，监听的tcp端口
net -lt
//同理，监听的udp端口
```

- 显示每个协议的统计信息

```
netstat -s
//同理，tcp
netstat -st
netstat -su
//这个主要显示的是收发的包数目	
```

- 统计使用端口的程序

```
netstat -ap | grep
//将会显示出对应的端口的程序名和进程id，有权限的才会显示
```

- 显示网络接口列表

```
netstat -i
//显示比如有几块网卡之类的
netstat -ie
//显示详细信息，类似ifconfig
```

- 显示核心路由信息

```
netstat -r
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
default         gateway         0.0.0.0         UG        0 0          0 enp0s25
10.2.4.0        0.0.0.0         255.255.255.0   U         0 0          0 enp0s25
link-local      0.0.0.0         255.255.0.0     U         0 0          0 enp0s25
```

