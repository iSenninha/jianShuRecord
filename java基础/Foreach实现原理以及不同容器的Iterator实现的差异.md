### Foreach实现原理以及不同容器的Iterator实现的差异

> **foreach**的用法很简单，好像习以为常了，但是，只有两种情况可以用forach，
>
> 一种是实现了Iterable接口的类，另外一种是数组（直接用数组下标访问）

 

- 证明使用了Iterator的代码(Iterable返回Iterator接口，看成是策略模式)

  > ​	其实完全可以用class文件证明的，但是看不懂字节码啊，我也很绝望，还是用代码吧

  ```
  		List<String> list = new ArrayList<String>();
  		list.add(1 + "");
  		list.add(2 + "");
  		list.add(3 + "");
  		
  		Iterator i = list.iterator();
  //		while(i.hasNext()) {
  //			String ii = (String)i.next();
  //			list.remove(ii);
  //		}
  		
  		for(String iii : list) {
  			System.out.println(iii);
  			list.remove(iii);
  		}
  ```

  > 运行会抛出**ConcurrentModifyException**，然后去掉注释，转而注释foreach，依然是相同的异常。
  >
  > 还有一种方法是单步调试，可以看到是跳到了对应的Iterator方法里的。



- 不同的容器不同的Iterator实现

> 在以上证明的代码中，一开始只往List添加了两个元素，然后发现无法出现CME异常，跟进debug的时候发现了ArrayList里的Iterator的**hasNext()**机制是这样的：
>
>         public boolean hasNext() {
>             return cursor != size;//直接cursor != size 就满足，一个的情况下，刚刚好cursor = size了
>         }
>         //往Arraylist里加三个元素的话加成功触发了CMD异常

​	由此启发看看其他集合的hasNext()实现：

​	1.HashMap

```
        public final boolean hasNext() {
            return next != null;//这个next是直接在上一次next()的时候就在寻找的
        }
```



​	2.LinkedList

```
        public boolean hasNext() {
            return nextIndex < size; //这个nextIndex是每次next的时候递增的
        }
```

> 没看出这里的规律，可能是作者的习惯？？？
