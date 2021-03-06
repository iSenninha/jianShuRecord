### Reactor线程模型

- Reactor单线程模型

  > **单个线程**处理所有的**Accept**以及**IO**操作，比如一个简单的**NIO**Demo，所有的感兴趣事件注册到同一个**多路选择器Selector**上。
  >
  > 这种模型，一旦这个IO线程跑飞就完蛋了。

- Reactor多线程模型

  > **多线程**模型，是指这里的**IO**操作**dispatch**到了**线程池**里，处理连接的还是**单线程**
  >
  > 这种架构在一般的负载下可以使用，但是在高并发的环境下，比如出现突然涌入了几万个连接，这个时候只有**一个acceptor线程**可能会无法处理这么多的连接请求，特别是连接请求可能还要涉及安全校验。

- 主从Reactor多线程模型

  > 有一个**Acceptor线程池**负责处理客户端连接，和安全校验，校验完全后，**dispatch**给**IO线程池**。
  >
  > 这种方式可以解决**处理连接**和**IO读写**的问题。