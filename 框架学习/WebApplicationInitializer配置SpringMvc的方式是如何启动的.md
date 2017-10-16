### WebApplicationInitializer配置SpringMvc的方式是如何启动的

> 首先，Spring推荐的一种采用代码配置的SpringMvc的方式是通过[WebApplicationInitializer](/基于注解搭建spring+springmvc+hibernate.md)的接口实现类的方式来实现的。这里面的原理是怎么样的呢？

- Tomcat的启动机制

  ​	spring jar包下**META_INF/services**有一个文件**javax.servlet.ServletContainerInitializer**指明了启动时候需要加载的类的所在路径，spring3.1的值是这个**org.springframework.web.SpringServletContainerInitializer**，并且这个类必须是实现**ServletContainerInitializer**。

  ​	然后，在**org.springframework.web.SpringServletContainerInitializer**，会扫描到实现了**WebApplicationInitializer**接口的类，这里我们使用的是**AbstractAnnotationConfigDispatcherServletInitializer**，使用注解的方式来启动和配置spring。


- 其他的启动扫描不详。