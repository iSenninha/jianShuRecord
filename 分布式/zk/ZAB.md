### ZAB(Zookeeper Atomic Broadcast)
Zookeeper 采用的是ZAB协议作为数据一致性的核心算法。这个协议主要包括两种基本的方式:**崩溃恢复**和**消息广播**。

#### 1 协议基础
##### 1.1 一次事务提交的过程
ZAB类似于二阶段提交，leader服务器接受客户端的事务请求，生成一个事务Proposal，将其发送给其余所有的follower，待收到过半follower的ack后，commit这次提交。
这里抛弃了二阶段提交的中断逻辑,是无法处理leader崩溃带来的数据不一致问题的，因此在ZAB协议中，通过**崩溃恢复**模式来解决这个问题。

##### 1.2 事务id的构成
事务id是一个64位的长整形，高32位表示一个leader周期的**Epoch**计数器，低32位是一个递增的计数器，leader服务器每接受一次客户端的请求即自增1。
重点看**Epoch**计数器,每选举产生一个leader的时候，这个**Epoch**编号就会在原来的值的基础上执行+1操作，然后低32位置0,产生新的ZXID。
基于此设计，可以非常轻松地分辨出不同**Epoch**周期的事务编号。在**前任*leader**恢复的过程中，可以快速处理崩溃前后的事务，丢弃只在**前任Leader**处理过的上一周期的事务。

#### 2 算法描述
##### 2.1 发现(looking)
阶段一主要是leader选举过程,选出**ZXID**最大的那个进程作为leader，即**Epoch**最大。
F1.1 所有的follower会发送自己最后接受的事务的**Epoch**值给准leader。
L1.1 准leader会在最大的**Epoch**的基础上+1,生成下一周期的**Epoch**。
F1.2 发送当前的所有事务集合给准leader
leader就会从所有follower的事务集合中选取一个作为初始化事务集合进行同步。

##### 2.2 同步(synchronization)
L2.1 准leader会把所有上一个**Epoch**周期处理过的所有事务同步给所有follower。
F2.1 follower接受到这条数据后，会检查当前自己的**epoch**是否等于leader同步过来的事务周期，如果不满足，直接跳过，等待更小周期的事务同步。
L2.2 当过半的follower反馈同步消息后，leader就会向所有的follower发送commit消息，至此leader完成了阶段二。
F2.2 follower接受到commit后，依次提交所有未处理的事务，完成阶段二。

##### 2.3 广播(broadcast)
至此，进入正常的广播阶段，leader可以接受客户端新的事务请求了。
L3.1 leader接受客户端的事务请求，广播给所有follower询问是否可以执行
F3.1 follower接受事务proposal，并将其添加到已处理(接受)事务hf中去
L3.2 接受到过半follower的ack后，广播给所有follower进行提交。
F3.2 follower提交此次事务。

每一个进程都可能处在looking，follower，leader这三种角色中，并互相转换。
