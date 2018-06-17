### epoll实现
> 结合网上找到的例子和man，终于弄出了个epoll版的socket服务器。

#### 1.SYNOPSIS
三个文件描述符(FD):socket,epoll,客户端fd
五个函数：socket(),bind(),epoll_create(),epoll_ctl(),epoll_wait()


#### 2.建立socket的fd
```
	int sockFd = socket(PF_INET, SOCK_STREAM, 0);
```
对应的PF_INET,SOCK_STREAM表示的是ip协议和和TCP协议，具体可man socket

#### 3.绑定socket
以上只是获取了socket描述符，绑定监听需要指定host和对应的port。
首先，在bind之前，需要设置一下复用端口，防止在程序关闭一段时间后端口仍然不可复用。

```
    int opt = 1;
    setsockopt(sockFd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));	
```

接下来就是绑定了，首先是设置相关参数，用**sockaddr_in**结构体描述:
```
    // 初始化相关socket地址相关
    struct sockaddr_in serverAddr;
    serverAddr.sin_family = PF_INET;
    serverAddr.sin_addr.s_addr = inet_addr("127.0.0.1");
    serverAddr.sin_port = htons((u_short)10086);
```
通过bind()函数绑定：
```
    // 将套接字与监听端口绑定
    int result = bind(sockFd, (struct sockaddr *) &serverAddr, sizeof(serverAddr));
```
sockFd是socket的描述符，第二个参数为啥要强转成**sockaddr**的指针呢，我也不知道。。

#### 4.开始监听
```
    result = listen(sockFd, 1024);
```
1024是**backlog**参数,见SOMAXCONN解析

#### 5.使用epoll
在不使用EPOLL机制的情况下，这个时候如果要获取连接的话，是使用**accept()**函数直接接收连接，使用**epoll()**的话，是用epoll机制去监听连接：

- 建立epoll fd
```
    // epoll    返回df，参数是传递给内核将要添加的监听数量，内核会动态增长这个数据结构，但是不能小于0
    int epFd = epoll_create(10);
```

- 注册进epoll
```
    struct epoll_event epollEvent;
    // 注册socket的fd进epoll_event
    epollEvent.data.fd = sockFd;
    epollEvent.events = EPOLLIN | EPOLLOUT | EPOLLET;

    epoll_ctl(epFd, EPOLL_CTL_ADD, sockFd, &epollEvent);
```

- 调用epoll_wait
```
        int i = epoll_wait(epFd, epollEvents, 1, -1);
```
epollEvents就是epoll_event的结构体指针，获取的是本次就绪的fd，后面两个参数分别是本次就绪个数与等待时间（-1表示永久）

##### 1.接收socket连接
一旦获取到了就绪的epoll_events，通过比较对应的文件描述符。
如果对应的文件描述符，等于socket的文件描述符号，说明当前就绪的是accept()，调用accept连接获取描述符号，并再次注册进epoll中去：
```
            if(sockFd == epollEvents->data.fd){
                printf("收到了epoll连接请求\n");

                size_t len = sizeof(serverAddr);
                int acceptFd = accept(sockFd, &serverAddr, &len);
                if(acceptFd == -1){
                    printf("error", errno);
                    return -1;
                }

                // 修改fd和活跃事件，然后重新注册进epoll里去
                epollEvents->data.fd = acceptFd;
                epollEvents->events = EPOLLIN | EPOLLET | EPOLLRDHUP;	//最后一个是断口连接就绪事件
                result = epoll_ctl(epFd, EPOLL_CTL_ADD, acceptFd, epollEvents);
                if(result < 0){
                    printf("epoll注册事件失败");
                    return -1;
                }
	}
```

##### 2.读取和断开事件
```
            }else{
                if(epollEvents->events & EPOLLRDHUP){
                    printf("挂断了连接\n");
                    close(epollEvents->data.fd);
                }else if(epollEvents->events & EPOLLIN) {
                    char buf[1024];
                    sprintf(buf, "HTTP/1.1 200 OK\r\n");
                    send(epollEvents->data.fd, buf, strlen(buf), 0);
                    sprintf(buf, "Content-type: text/html\r\n");
                    send(epollEvents->data.fd, buf, strlen(buf), 0);
                    sprintf(buf, "\r\n");
                    send(epollEvents->data.fd, buf, strlen(buf), 0);
                    sprintf(buf, "<P>are you ok?</P>.\r\n");
                    send(epollEvents->data.fd, buf, strlen(buf), 0);
                    read(epollEvents->data.fd, buf, sizeof(buf));
                    printf(buf);
                }
            }
```

#### 6.总结
基本上，一个简单的epoll机制实现的c服务器就完成了。现在来分清一下epoll与阻塞io的区别到底在哪里。
从上面的例子可以看出，epoll实现的服务器，读取数据的时候，使用的仍然是**read()**函数，与阻塞io是一致的。
阻塞io实际上会阻塞在两个地方，一是内核等待数据到来，二是内核数据复制到用户空间;
而epoll会可以一个线程监听多个描述符，内核数据就绪后，通知用户读取，这个时候，仍然会阻塞去从内核读取数据到用户空间。
[Linux IO模式及 select、poll、epoll详解](https://segmentfault.com/a/1190000003063859)

不多说了，把测试代码贴上来,直接编译运行，然后在浏览器[点我](localhost:10086)即可食用，断开连接的时候会打印段断开
```
//
// Created by senninha on 18-6-16.
//

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/epoll.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void){
    // 初始化相关socket地址相关
    struct sockaddr_in serverAddr;
    serverAddr.sin_family = PF_INET;
    serverAddr.sin_addr.s_addr = inet_addr("127.0.0.1");
    serverAddr.sin_port = htons((u_short)10086);

    struct epoll_event epollEvent;
    struct epoll_event *epollEvents;
    // 先分配个内存空间
    epollEvents = calloc(1, sizeof(epollEvents));

    // 创建监听socket man 3 socket 表示ip协议，tcp协议，0不清楚
    int sockFd = socket(PF_INET, SOCK_STREAM, 0);
    if(sockFd <= 0){
        printf("获取socket错误");
        return -1;
    }

    // 复用端口，防止关掉程序后一段时间才能重新使用这个端口
    int opt = 1;
    setsockopt(sockFd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    // 将套接字与监听端口绑定
    int result = bind(sockFd, (struct sockaddr *) &serverAddr, sizeof(serverAddr));
    if(result < 0){
        printf("绑定错误");
        return -1;
    }

    // listen   套接字fd，backlog大小
    result = listen(sockFd, 1024);
    if(result < 0){
        printf("监听错误");
        return -1;
    }

    // epoll    返回df，参数是传递给内核将要添加的监听数量，内核会动态增长这个数据结构，但是不能小于0
    int epFd = epoll_create(10);
    if(epFd < 0){
        printf("创建ep fd错误");
        return -1;
    }

    epollEvent.data.fd = sockFd;
    epollEvent.events = EPOLLIN | EPOLLOUT | EPOLLET;

    epoll_ctl(epFd, EPOLL_CTL_ADD, sockFd, &epollEvent);

    while(1) {
        int i = epoll_wait(epFd, epollEvents, 1, -1);
        if(i == -1){
            printf("epoll等待错误");
            return -1;
        }

        for(int j = 0 ; j < i; j++){
            if(sockFd == epollEvents->data.fd){
                printf("收到了epoll连接请求\n");

                size_t len = sizeof(serverAddr);
                int acceptFd = accept(sockFd, &serverAddr, &len);
                if(acceptFd == -1){
                    printf("error", errno);
                    return -1;
                }

                // 修改fd和活跃事件，然后注册进epoll里去
                epollEvents->data.fd = acceptFd;
                epollEvents->events = EPOLLIN | EPOLLET | EPOLLRDHUP;
                result = epoll_ctl(epFd, EPOLL_CTL_ADD , acceptFd, epollEvents);
                if(result < 0){
                    printf("epoll注册事件失败");
                    return -1;
                }
            }else{
                if(epollEvents->events & EPOLLRDHUP){
                    printf("挂断了events\n");
                    close(epollEvents->data.fd);
                }else if(epollEvents->events & EPOLLIN) {
                    char buf[1024];
                    sprintf(buf, "HTTP/1.1 200 OK\r\n");
                    send(epollEvents->data.fd, buf, strlen(buf), 0);
                    sprintf(buf, "Content-type: text/html\r\n");
                    send(epollEvents->data.fd, buf, strlen(buf), 0);
                    sprintf(buf, "\r\n");
                    send(epollEvents->data.fd, buf, strlen(buf), 0);
                    sprintf(buf, "<P>are you ok?</P>.\r\n");
                    send(epollEvents->data.fd, buf, strlen(buf), 0);
                    read(epollEvents->data.fd, buf, sizeof(buf));

                    printf(buf);
                }
            }
        }
    }
}


```
