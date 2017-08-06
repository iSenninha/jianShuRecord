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
为什么要三次握手呢？现在考虑这种情况，客户端发送的SYN(叫SB吧)因为某种原因没有到底，然后重传了，并且建立连接完毕后关掉了连接。这个时候SB竟然又到了服务端，并且服务端也回送了SYN-ACK，但是这个时候客户端知道自己并没有建立连接，所有不回送ACK，连接就不会建立，不会让服务端白白浪费连接。


#####四次挥手：

|端|状态|发送|状态|收到(一次挥手)|发送|状态|收到(2)|等待被动关闭方发送完数据后发送fin信号|状态|发送|状态|收到(3)|发送|状态|收到(4)
|:---:|:-----:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
|主动关闭端|ESTABLISHED|FIN|FIN-WAIT1||||FIN-WAIT2||||FIN-WAIT2|FIN-WAIT2|ACK|TIME-WAIT(等待2MSL（Maximum segment lifetime）如果没有FIN传来，进入CLOSED状态)|
|被动关闭端|ESTABLISHED||ESTABLISHED|ESTABLISHED|ACK|CLOSE-WAIT|||CLOSE-WAIT|FIN|LAST-ACK|||LAST-ACK|CLOSED

以上是正常关闭的状态
还有其他的状态：
> 1.双方在未收到FIN的前提下都发送了FIN，则同时进入由FIN-WAIT1进入CLOSING状态，然后收到应答就进入了TIME-WAIT
2.等待两个msl时间是为了保证对方收到了ACK确认

Socket概念：
socket这个概念没有对应到一个具体的实体，它描述计算机之间完成互相通信的一种抽象功能。大部分情况下我们使用的都是基于TCP/IP的流套接字。
