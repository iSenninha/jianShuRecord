### CGLib动态生成字节码

> CGLib可以动态生成字节码，在不用实现统一接口的情况下就可以实现**动态代理**的功能。

- Maven依赖

  ```xml
  <dependency>
  	<groupId>cglib</groupId>
      <artifactId>cglib</artifactId>
      <version>2.2</version>
  </dependency>
  ```

  ​

- 实现过程

  我们先有方法**add**，然后有一个需求，需要在方法**add**前面添加一个公有的日志方法**B**。可以使用代理方式，为每一个需要使用日志方法**B**的类都建一个代理。这个时候可以通过动态代理，把公有的日志方法方法**B**嵌入需要A方法前的代码里。

  ```java
  public class CGLIBTest {

  	public static void main(String[] args) {
  		Enhancer enhancer = new Enhancer();
  		enhancer.setSuperclass(UserServiceImpl.class);
  		enhancer.setCallbacks(new Callback[] {new MyMethodInterceptor()});
  		UserServiceImpl userService = (UserServiceImpl) enhancer.create();//动态生成新的类
  		userService.add();
  	}
  }

  class UserServiceImpl {
  	public void add() {//add方法
  		System.out.println("This is add service");
  	}

  	public void delete(int id) {
  		System.out.println("This is delete service：delete " + id);
  	}
  }

  //拦截器
  class MyMethodInterceptor implements MethodInterceptor {
  	public Object intercept(Object obj, Method method, Object[] arg, MethodProxy proxy) throws Throwable {
  		System.out.println("Before:" + method);
  		Object object = proxy.invokeSuper(obj, arg);
  		System.out.println("After:" + method);
  		return object;
  	}
  }
  ```

  以上的处理其实是会拦截这个类里的所有方法的，就是delete方法也会拦截，如果不同的操作需要有不同的拦截处理，那么可以添加多个**MethodInterceptor**，然后增加一个**CallbackFilter**去判断拦截

  ```java
  class CallbackFilterImpl implements CallbackFilter{

  	@Override
  	public int accept(Method arg0) {
  		if(arg0.getName().equals("delete")) {
  			return 1;
  		}
  		return 0;
  	}
  }
  ```

  上面的1,2是指加入到**callbacks**里的数组顺序，其实NoOp.instance就是无动态生成的操作：

  ```java
  		Enhancer enhancer = new Enhancer();
  		enhancer.setSuperclass(UserServiceImpl.class);
  		enhancer.setCallbacks(new Callback[] {new MyMethodInterceptor(), NoOp.INSTANCE});
  		enhancer.setCallbackFilter(new CallbackFilterImpl());
  		UserServiceImpl userService = (UserServiceImpl) enhancer.create();
  		userService.add();
  		userService.delete(1);
  ```

  这样就可以只在**add**的时候动态生成，而不会去动态生成**delete**操作了。也就是不拦截**delete**操作。

  ​

> 所以，动态代理可以用在需要为一个类的方法添加某个拦截操作的时候使用。