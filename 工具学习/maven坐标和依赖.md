### maven坐标和依赖

- 坐标

  > maven的坐标由如下几个标签来确定唯一的坐标

  - groupId：定义当前maven项目隶属的实际项目，一般可以用域名的倒序
  - artifactId：一般使用当前项目的项目名
  - version：版本号
  - packaging：定义maven的打包方式
  - scope：依赖有效性范围



- 依赖范围

  > 依赖范围是指**依赖**在**编译**，**运行**，**测试**这三个状态下是否有效。
  >
  > 依赖的有效性是通过指定不同的**classpath**实现的。

  - compile：缺省设置，表示这个依赖一直有效
  - test：只在测试的时候有效
  - provided：已提供依赖范围，对于编译和测试有效，但是在运行时无效，比如servlet，运行的时候不需要，因为容器已经提供
  - runtime：运行时依赖接口，比如jdbc
  - system：系统依赖范围，与provide范围相同，但是需要手动指定具体的依赖路径



- 传递性依赖

> 所谓依赖性传递是通俗地说是这样的：
>
> A依赖了B，B依赖了C，那么
>
> A传递性依赖了C
>
> 有了这种机制，使用一个诸如Spring这样的依赖了很多别的包的项目，不需要担心它依赖的项目没有被引入依赖，或者是重复引入依赖了

​	传递性的依赖范围又是怎么样的呢？

> 先引入这个概念：
>
> A依赖于B，B依赖于C，那么A对于B是第一直接依赖，B对C是第二直接依赖。A与C就是传递性依赖的范围取决于上述两个依赖

​	如果第二直接依赖是**compile**，那么间接依赖与**第一直接依赖相同**，

​	当第二直接依赖的范围是 test 的时候,依赖不会得以传递;

​	当第二直接依赖的范围是 provided 的时候,只传递第一直接依赖范围也为 provided 的依赖,且传递性依赖的范围同样为 provided;

​	当第二直接依赖的范围是runtime 的时候,传递性依赖的范围与第一直接依赖的范围一致,但 compile 例外,此时
传递性依赖的范围为 runtime。



- 排除依赖

> 考虑这样一个场景，B依赖于C，但是B依赖的C在Maven中央仓库里没有，但是可以有别的替代，这个时候可以用排除依赖的方法来实现这个。
>
> ```
> <dependency>
>   <groupId>com.juvenxu.mvnbook</groupId>
>     <artifactId>project-b</artifactId>
>     <version>1.0.0</version>
>     <exclusions>
>       <exclusion>
>       <groupId>com.juvenxu.mvnbook</groupId>
>       <artifactId>project-c</artifactId>
>        </exclusion>
>  	 </exclusions>
> </dependency>
>
> 然后再在这里重新指定C的依赖。
> ```
>
> 

