### LinkedTransferQueue

> LinkedTransferQueue也是基于链表实现的队列，名字里多了transfer，因为它**多了**直接**传送transfer**入队元素给生产者的相关方法

- 继承关系

  - AbstractQueue
    - LinkedTransferQueue
  - TransferQueue
    - LinkedTransferQueue

  > 继承了AbstractQueue，并且实现了LinkedTransferQueue接口，后者这个接口里有tryTransfer相关方法



- transfer方法

> transfer方法的用法就是等待一个线程来**消费**它，如果没有，就一直等待。

- tryTransfer方法

> 在指定时间内等待，如果消费失败，返回false。。

- 对应的take，poll方法

> 取到一个节点后，如果对应的Thread不为空，那么要去unpark唤醒入队等待线程。