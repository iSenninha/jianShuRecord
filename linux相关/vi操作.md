Vi操作

- 复制，删除，粘贴操作

```
  yy
  复制光标所在行
  nyy
  复制该行到向下n行的数据
  y1G
  复制该行到第一行的数据
  yG
  复制该行到最后一列的数据
  y0
  复制光标到行首的字符
  y$
  复制光标到行尾的字符

  p
  粘贴到该光标下一列
  P
  粘贴到该光标的上一列
  J
  将当前列和下一列合并
  
  dd
  剪切当前行
  ndd
  向下剪切n列
  其他类似yy操作 
  
  x
  向后删除一个字符，相当于del
  X
  相当于向前删除字符，相当于backspace 
  nx
  向后删除n个字符
```

- 定位操作

```
  j,k,h,l
  上下左右 
  ctrl + f/b
  向下/上翻页
  $/0
  移动到一行的最后一个/第一个字符
  gd
  跳转到某个字符的定义处，类似idea里的ctrl-b操作
```

- 从一般指令模式到编辑模式的切换

```
  i/I
  从当前光标处前一格开始编辑插入/ 从行首开始编辑
  a/A
  从当前光标的下一个字符开始编辑/ 从当前所在行的最后一个字符开始插入
  o/O
  从下一行插入/ 从上一行插入
  r/R
  取代模式一次/取代模式一直
```

- :指令

```
  :set nu
  显示行号
  :setnonu
  取消行号
```

- 剪切板相关
vi有**0,1,2,3,4,5,6,7,8,9,",a,+**共**12**个剪切板，其中**"**是临时剪切板(默认用的就是这个)，而**+**就是系统剪切板了。
平时我们复制是这样:
v 可视化选中 然后 y
这里默认就是使用了**"**临时剪切板，完整的使用是**"y**，同理，调用系统剪切板:

```
+y
```

