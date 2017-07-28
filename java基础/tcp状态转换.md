####tcp状态转换

######三次握手：

|端|状态|发送|状态|收到(一次握手)|发送|状态|收到(2)|发送|状态|收到(3)|发送|状态
|:---:|:-----:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:----:|:----:|:----:|:----:|
|服务端|LISTENSED|||LISTENED|ACK+SYN|SYN-RCVD||||ESTABLISHED||ESTABLISHED
|客户端|CLOSED|SYN|SYN-SENT||||SYN-RCVD|ACK|ESTABLISHED


> 1.服务端处于listen状态
2.客户端处于closed状态，发送syn报文，然后状态变为SYN-SENT
3.服务端收到后，发送确认报文ACK和SYN报文，进入SYN-RECEIVED状态(第一次握手)
4.客户端收到SYN和ACK后，发送ACK，进入ESTABLISHED状态，然后发送ACK报文（第二次握手）
5.服务端收到ACK，也进入ESTABLISHED状态（第三次握手）

以上是最普遍的状态转化，其他情况如下：
>
SYN-RECEVIED状态可以通过LISTENSE状态转化而来，也可以通过在状态处于SYN-SENT状态时收到SYN(可能是因为丢失了ACK)请求时转化（SYN + ACK是转化为ESTABLISHED）


#####四次挥手：

|端|状态|发送|状态|收到(一次挥手)|发送|状态|收到(2)|等待被动关闭方发送完数据后发送fin信号|状态|发送|状态|收到(3)|发送|状态|收到(4)
|:---:|:-----:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
|主动关闭端|ESTABLISHED|FIN|FIN-WAIT1||||FIN-WAIT2||||FIN-WAIT2|FIN-WAIT2|ACK|TIME-WAIT(等待2MSL（Maximum segment lifetime）如果没有FIN传来，进入CLOSED状态)|
|被动关闭端|ESTABLISHED||ESTABLISHED|ESTABLISHED|ACK|CLOSE-WAIT|||CLOSE-WAIT|FIN|LAST-ACK|||LAST-ACK|CLOSED

以上是正常关闭的状态
还有其他的状态：
> 1.双方在未收到FIN的前提下都发送了FIN，则同时进入由FIN-WAIT1进入CLOSING状态，然后收到应答就进入了TIME-WAIT

Socket概念：
socket这个概念没有对应到一个具体的实体，它描述计算机之间完成互相通信的一种抽象功能。大部分情况下我们使用的都是基于TCP/IP的流套接字。
