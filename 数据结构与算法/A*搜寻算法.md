### A*搜寻算法

A*算法

- 启发式函数：**F(x) = G(x) + H(x)**

  **F(x)**：评估这条路径是否是最短的，是贪心评估，找最小的

  **G(x)**：当前格子与**出发点**的距离，这个距离不是直接通过计算得来的，而是通过父格子的**G**值+1得来的

  **H(x)**：评估当前格子到**终点**的距离，这里我是通过曼哈顿距离求得

  ​

- 搜索过程

  先定义**openList**为待选择格子，**closeList**为已选择格子

  - while(**closeList** 不包含 **目标格子**)

    - 计算当前格子的周围可走的格子的F(x)值

      - ？格子存在于**closeList**
        - Y，丢弃
        - N，？存在于**OpenList**
          - N，直接加入**OpenList**
          - Y，？当前计算的**G值**是否比存在于**OpenList**的**G值**小
            - Y，更新**OpenList**中存在的格子的**G值**，并把它的**父格子**设置为当前的格子，这个步骤说明当前走的路径更佳。
            - N，不作处理

    - 从**openList**中找到**F值**最小的，加入**closeList**，把这个格子设置为当前格子，继续搜寻

      ​

- 几个注意的点

  - **G(x)**值是通过父格子的**G**值+1得来的

  - 搜寻得到的是一个从终点到起点的链表，可以通过反向搜寻的方式，就可以直接得到我们要的起点到终点的链表

  - **openList**，取出最小值的过程涉及排序，并且可能会出现更新**格子G值**的情况，这里我是通过二叉堆**PriorityQueue**的方式优化排序，需要重写**comparable**接口：

    ```java
    @Override
    	public int compareTo(ASNode o) {
    		if (o.getgValue() + o.gethValue() < this.getgValue() + this.gethValue()){
    			return 1;
    		} else {
    			return -1;
    		}
    	}
    ```

  - **closeList**和**openList**都要求比较**格子**是否存在，这里用了一个HashMap来区别是否是同一个格子：

    ```java
    	Map<ASNode, ASNode> closeMap = new HashMap<>();
    	Map<ASNode, ASNode> openMap = new HashMap<>();

    	@Override
    	public int hashCode() {
    		return value.hashCode();	//value是Grid(格子)
    	}
    ```

    ​

- 参考[A星](http://blog.csdn.net/hitwhylz/article/details/23089415)

