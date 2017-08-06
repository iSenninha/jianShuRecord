###Java内存模型(JMM)

- 并发编程的关键
  1.线程之间如何通信:共享内存
  2.线程之间如何同步

&nbsp;

- 共享内存通信中的重要问题--如何保证内存可见性
> 假设主内存里有变量x=0;
> 然后A线程读取这个变量，此时它会在线程里保存一个变量的副本x=0，随后它把这个值修改成x=1，但是并没由刷新回取主内存。
> 这个时候B线程去读取变量x的时候(从主内存)，还是读取到x=0，这就导致了内存不可见。

&nbsp;

- 内存屏障保证可见性

| 屏障类型                | 指令示例                     | 说明                                     |
| ------------------- | ------------------------ | -------------------------------------- |
| LoadLoad Barriers   | Load1;LoadLoad;Load2     | 确保Load1数据的装载先于Load2及所有后续装载指令的装载        |
| StoreStore Barriers | Store1;StoreStore;Store2 | 确保Store1数据刷新到主内存优先于其他Store2以及一起后续的刷新指令 |
| LoadStore Barriers  | Load1;LoadStore;Store2   | 确保Load1的数据装载优先于Store2以及后续的的数据刷新指令      |
| StoreLoad           | Store1;StoreLoad;Load2   | 确保Store1的数据刷新先于Load2以及后续的装载指令          |

