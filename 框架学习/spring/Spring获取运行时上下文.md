### Spring获取运行时上下文

> 使用Spring容器托管的Web应用中， 还嵌入了一个netty的TCP服务器，为了实现Netty的业务分发，使用了自定义的类扫描机制来缓存对应的解码以及分发，等于是在Spring容器外自己又造了一个容器。这就导致自己造的容器内无法使用Spring容器里的东西，这个就非常蛋疼了。因为像dao，service都是在spring容器里，总不能自己的容器里又搞一套。于是，需要获取一个Spring上下文，在自己造的容器对象里手动去注入Spring容器里的对象。

- 以下有一个可行的解决方案：

  - 1.继承ApplicationContextAware

  - 2.代码如下

    ```java
    @Component
    public class SpringContextUtil implements ApplicationContextAware {
             private static ApplicationContext applicationContext; // Spring应用上下文环境
             /*
              * 实现了ApplicationContextAware 接口，必须实现该方法；
              *通过传递applicationContext参数初始化成员变量applicationContext
              */
             public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
                   SpringContextUtil.applicationContext = applicationContext;
             }
     
             public static ApplicationContext getApplicationContext() {
                    return applicationContext;
             }

              @SuppressWarnings("unchecked")
              public static <T> T getBean(String name) throws BeansException {
                         return (T) applicationContext.getBean(name);
               }
    }

    ```

  - 3.记得要把这个工具类加入到Spring的扫描路径下，这样才能在初始化时注入

  - 4.使用方法：

    ```java
    	ApplicationContext context = SpringContextUtil.getApplicationContext();
    		LoginDao lDao = context.getBean(LoginDao.class);
    ```

    放心使用，在未经spring管理的对象里调用这个方法，就能获取到spring容器里的东西了。



- 总结：

  其实这个过程就是想办法获取Spring的上下文，把这个上下文引用放到整个应用可及的地方供我们调用。然后在我们自己的容器里去注入。

  ​