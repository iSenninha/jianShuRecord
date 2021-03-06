### Eclipse 快捷键

> Ctrl + Shift + L 可以调出所有的快捷键一览

- 查找类

  |        快捷键组合        |                 含义                  |
  | :-----------------: | :---------------------------------: |
  |      ctrl + f       |             查找当前编辑器的内容              |
  |      ctrl + h       |       选中某个类或者变量，查找整个工作空间对其的引用       |
  |  ctrl + shift + r   |              查找整个工作空间的              |
  |  ctrl + shift + t   | debug模式下查找某个对象的数据(i = inspect)查找某个类 |
  |      ctrl + o       |             快速查找当前类的方法              |
  |      ctrl + e       |        快速转换当前目录打开的多个编辑器(可搜索)        |
  |  ctrl + shift + g   |          选中某个文件，快速在工作空间搜索           |
  |   ctrl + alt + h    |      快速生成某个方法的调用树，和ctrl + h类似       |
  |      ctrl + T       |            查找某个接口方法的实现类             |
  |  ctrl + shift + i   |   debug模式下查找某个对象的数据(i = inspect)    |
  | ctrl + . / ctrl + 1 |      前者快速定位下一个错误的点，后者是快速给出修正建议      |



- 操作类

  |        快捷键组合         |             含义              |
  | :------------------: | :-------------------------: |
  |         home         |         line start          |
  |         end          |          line end           |
  |     alt + arrow      | 导航到上一次的操作的地方(浏览器的快捷方式也是这样的) |
  | ctrl + shift + arrow |     在一个类中上下移动到各个方法，成员变量     |
  |   ctrl + shift + /   |        快速添加多行注释/* */        |
  |     alt + arrow      |           上下行移动代码           |
  |       ctrl + q       |         跳转到上一次编辑的地方         |
  |          f3          |           进入某个方法            |
  |    ctrl + T (F4)     |        快速显示一个类的继承关系         |
  |     ctrl + arrow     |           左右的话是跳词           |
  |      alt + 下，上       |            上向行互换            |
  |       ctrl + m       |           最大化编辑窗口           |



- 生成类

  |          快捷键          |                    含义                    |
  | :-------------------: | :--------------------------------------: |
  |    ctrl + alt + j     |               快速生成javadoc                |
  |   ctrl + shift + j    |                 生成get方法                  |
  | ctrl + shift + k(自定义) |              生成toString()方法              |
  | ctrl + shift + h(自定义) |                  生成构造方法                  |
  |  shift + enter(自定义)   |                 加入一个空白行                  |
  | ctrl + shift + D（自定义） |                try-catch                 |
  |    alt + shift + r    |     重构某个字段，如果是成员变量，按两次，同步修改get set方法     |
  |    alt + shift + L    | 在某个字符串上面选择，然后就会新建一个变量来全局替换一样的变量。比如do("senninha")，选择后就会do(s); String s = "senninha";全局替换。 |
  |      ctrl + 2,L       | String.valueOf("se") 前面的变量名还没有设置，这个时候按ctrl + 2等一下再按L，就会生成变量了，其实就是根据**返回值**快速建立变量 |
  |    alt + shift + v    |             **移动**某个文件到某个地方              |