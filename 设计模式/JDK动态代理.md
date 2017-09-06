### JDK动态代理

> Java动态代理可以在运行时生成对应的代理类去供调用者使用，而且可以在代理类里对一个方法前后作拦截，就是AOP的思想。



- 统一的接口

```java
interface Service {
	public void say();
	public void hello();
}
```



- 接口实现类

```java
class ServiceImpl implements Service {

	@Override
	public void say() {
		System.out.println(this.getClass().getSimpleName());
	}

	@Override
	public void hello() {
		System.out.println("hello");
	}
}
```



- 实现InvocationHandler接口

```
	class MyInvocationHandler implements InvocationHandler {
	private Service servic;

	public MyInvocationHandler(Service servic) {
		super();
		this.servic = servic;
	}

	@Override
	public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
		System.out.println("invoke");
		return method.invoke(this.servic, args);
	}

}
```



- 调用代码

```
		Service service = new ServiceImpl();
		InvocationHandler handler = new MyInvocationHandler(service);
		Service ser = (Service) Proxy.newProxyInstance(handler.getClass().getClassLoader(),
				service.getClass().getInterfaces(), handler);
		ser.say();
		ser.hello();
```



> 动态代理可以包装所有的使用这个方法的类，然后在对应方法执行的时候加入我们需要的逻辑，前置通知，后置通知都可以。
>
> 使用场景如性能监测，访问控制，事务管理、缓存、对象池管理以及日志记录。





- 附录代码

```
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

public class ProxyTest {

	public static void main(String[] args) {
		Service service = new ServiceImpl();
		InvocationHandler handler = new MyInvocationHandler(service);
		Service ser = (Service) Proxy.newProxyInstance(handler.getClass().getClassLoader(),
				service.getClass().getInterfaces(), handler);
		ser.say();
		ser.hello();
	}

}

interface Service {
	public void say();

	public void hello();
}

class ServiceImpl implements Service {

	@Override
	public void say() {
		System.out.println("say:" + this.getClass().getSimpleName());
	}

	@Override
	public void hello() {
		System.out.println("hello");
	}

}

class MyInvocationHandler implements InvocationHandler {
	private Service servic;

	public MyInvocationHandler(Service servic) {
		super();
		this.servic = servic;
	}

	@Override
	public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
		System.out.println("invoke");
		return method.invoke(this.servic, args);
	}
}
```

