### Agent的方式实现动态干预运行着的程序

> 动态干预运行着的程序，不用因为某个bug而停服务更新。

- 导入jar包

  > 
  > ```
  > <dependency>
  >     <groupId>io.earcam.wrapped</groupId>
  >     <artifactId>com.sun.tools.attach</artifactId>
  >     <version>1.8.0_jdk8u131-b11</version>
  > </dependency>)
  > ```
  > 不是maven项目就去中央仓库下一个。。



- 将项目跑起来

  > 我这里是新建了一个普通java项目，直接用main方法拉起来的，如下：

  ```
  public class Target {
  	public static boolean flag = true;
  	public static void main(String[] args) {
  		while(flag) {
  			System.out.println("继续");
  			try {
  				Thread.sleep(10000);
  			} catch (InterruptedException e) {
  				// TODO Auto-generated catch block
  				e.printStackTrace();
  			}
  		}
  		System.out.println("结束");
  	}

  }
  ```

  ​	然后直接在eclipse里运行就行了。

  ​

- 构造代理类

  > 代理类就放在本个项目里面，是可以为所欲为，对本项目的所有资源做操作的，并且这个是可以动态加载的，这个才是最诱人的。。在这里仅仅是更改上面类里的**布尔**变量。

  ```
  public class SetParam {
  	@SuppressWarnings("rawtypes")
      public static void agentmain(String args, Instrumentation inst){//方法名必须为这个
  		Target.flag = false;
  		System.out.println("设置为false");
      }
  }

  ```

  ​	然后是打包这个代理构造类为jar包

  ​	export--->jar--->...--->指定Manifest文件如下：--->导出jar包

  ```
  manifest-Version: 1.0
  Agent-Class: com.senninha.agent.SetParam
  Created-By: 1.8.0_144

  ```



- 辅助工具类

  ```
  public class Test {
  	    public static void main(String[] args) throws AttachNotSupportedException,
  	            IOException, AgentLoadException, AgentInitializationException {
  	        VirtualMachine vm = VirtualMachine.attach(args[0]);
  	        vm.loadAgent("/agentjar包的路径/loadagent.jar");
  			//加载上一步导出的jar包
  	    }

  	}
  ```

  ​	编译这个Test文件

  ​	javac -cp 上面依赖的tools.jar包 Test.java



- 运行

  > 先运行Target--->然后jps获取Target的进程id--->然后java Test 进程id
  >
  > 神奇发现死循环停下来了。。

  ```
  继续
  继续
  继续
  继续
  继续
  继续
  继续
  继续
  继续
  设置为false
  结束
  ```



​	参考:[非纯种程序猿 Thinking all about tech & life](http://jiangbo.me/blog/2012/02/21/java-lang-instrument/)
