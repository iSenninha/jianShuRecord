### tmp

#### 反射替换SelectorImpl里的Set
**NioEventLoop#openSelector()**里替换了**SelectorImpl**的两个Set为**SelectedSelectionKeySet**
[why replace](https://stackoverflow.com/questions/23550412/why-netty-uses-reflection-to-replace-members-in-sun-nio-ch-selectorimpl-class-wi)


#### SingleThreadEventExecutor可调IO占用Ratio
**NioEventLoop**里有一个**ioRatio**成员变量，用来控制io任务所占的比例
