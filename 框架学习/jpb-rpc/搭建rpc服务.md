###搭建rpc服务
> rpc是Remote procedure call（远程调用）的意思，传统的web接口开发，在这个意义上也是rpc服务，只是交换的数据格式是json或者xml这样的格式，需要在接受信息后通过对应的解析工具解析为接收方语言能识别的数据结构。
而这里的rpc框架，在请求或者接受请求的时候，使用的数据结构都是该语言自己的，就是说rpc框架把这层数据的转换(通过pb),以及通讯过程中的各种细节(通过socket)封装好了，我们按照它的规则，写少量的接口，然后就可以通过rpc服务的代理，像是在调用本进程的接口一样,调用远程的服务，这就是rpc框架。
这里，我们用百度的基于**protobuf**和**netty**的rpc框架搭建rpc服务，[github地址](https://github.com/baidu/Jprotobuf-rpc-socket)。

</br>

####被调用者
被调用者，需要暴露自己的接口，通过注解的方式，可以很方便地实现这个过程：
```
public class HelloServiceImpl {
	@ProtobufRPCService(serviceName = "hello", methodName = "hello")
	public HelloMessage hello(HelloMessage hello) {
		System.out.println("服务收到:" + hello.getInfo());
		hello.setInfo("我收到了");
		return hello;
	}
}
```
注意注解里的**serviceName**和**methodName**，这两个是标明一个接口身份的标识，就跟在本进程调用一个接口一样，需要**包名**+**方法名**

然后是启动rpc服务
```
                pcServer rpcServer = new RpcServer();
		HelloServiceImpl helloService = new HelloServiceImpl();
		rpcServer.registerService(helloService);
		rpcServer.start(1031);
```
注册我们的rpc服务，然后以一个端口发布rpc服务，这里是用官方demo的**1031**端口

---

####调用者
上面说了，rpc服务调用远程服务，就像在调用本进程的资源一样，就是说，那么就要有统一的接口，回顾一下我们刚刚暴露的服务接口格式，没错，在调用者这里，需要一个一样的接口：
```
public interface HelloService {
	@ProtobufRPC(serviceName = "hello", onceTalkTimeout = 200)
	HelloMessage hello(HelloMessage hello);
}
```
注意这个**服务名**和**方法名**，需要与暴露的服务相匹配。

然后就是调用了：
```
		RpcClient rpcClient = new RpcClient();
		// 创建EchoService代理
		ProtobufRpcProxy<HelloService> pbrpcProxy = new ProtobufRpcProxy<HelloService>(rpcClient, HelloService.class);
		pbrpcProxy.setPort(1031);
		// 动态生成代理实例
		HelloService service = pbrpcProxy.proxy();
		HelloMessage hello = new HelloMessage("senninha");
		HelloMessage response = service.hello(hello);
		System.out.println(response.getInfo());
		rpcClient.stop();
```
利用动态代理的方式，利用接口(JDK动态代理)，生成的代理对象替我们做了如下的事情：

- Java数据结构--->Pb数据结构
- 二进制发送到远程服务提供者
- 接收到服务应答
- Pb--->Java数据结构
- 返回

