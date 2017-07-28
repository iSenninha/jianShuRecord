####1.Servlet路径配置问题
首先是在servlet里配置
- 注解配置：
		@WebServlet("/TestInit")
		public class TestInit extends HttpServlet 
		//在类的前面加一个注解，这里的注解加一个  "/" 表示当前的根目录下，就是  地址/项目名/TestInit
	
- xml配置：
		在xml里配置也是一个道理
		<url-pattern>/TestInit</url-pattern>
		这里的路径也是在 地址/项目名/TestInit
	
####2.网页里的路径
如果还是按/xxxx的话，比如：
```
		<form action = "/xxx" method = "get">
			<input type = "submit" value = "跳转"/>
		</form>
```		
会跳转到一个localhost:8888/se
当然是404了。
	
直接设置相对路径:
```
	<form action = "se" method = "get">
			<input type = "submit" value = "跳转"/>
		</form>
```
就可以正确跳转了。
但是如果我们要访问的路径是上一个目录下的，这时候如何设置相对路径呢，比如：
```
当前页面路径是localhost:8888/test/test/test
但是我们要访问的路径是localhost:8888/test/test1/test
这时候相对路径写:  ../test1/test
即可，../表示当前路径向前退一个路径，在linux里也是这样的，cd ..退到上一个路径
```

需要注意的是即使是在servlet里转发跳转，直接/xxx 还是会跳到服务器根目录去所以在servlet里跳转一样要遵循在html里的方法。

#### 2.servlte的初始化参数：
注意，必须是在xml里配置的那个url访问才可以get到这个初始化方法，并且顺序是先username1-->username2并且当前servlet配置的信息只能被当前的servlet所共享，要全局初始化的话，要用context的初始化参数，见下
```
	//1.首先是配置对应的xml文件里的数据:
		<servlet>
			<servlet-name>test</servlet-name>
			<servlet-class>
				xxx.xxx
			</servlet-class>
			
			<init-param>
				<param-name>username</param-name>
				<param-value>senninha</param-value>
			</init-param>
			//并且可以设置多组初始化数据
			<init-param>
				<param-name>username1</param-name>
				<param-value>senninha1</param-value>
			</init-param>
		</servlet>
		
		
	//2.然后在是servlet里重写inti()方法：
			@Override
			public void init(ServletConfig config) throws ServletException {
				// TODO Auto-generated method stub
				Enumeration<String> initParaNames = config.getInitParameterNames();
				while(initParaNames.hasMoreElements()){
				String name = initParaNames.nextElement();
			    System.out.println(name + ":"+config.getInitParameter(name));
			}
				super.init(config);
			}
```
获取全局初始化参数,这个方法可以在全局获取，并且注解或者xml里配置的url都可以获取到
	既可以在重写的init方法里获取context对象:
```
		ServletContext context = config.getServletContext();
	
	//也可以在doGet方法里通过：
		ServletContext context = request.getServletContext()
		
	//然后获取初始化值就大同小异了：
		Enumeration<String> param = context.getInitParameterNames;
		while(param.hasMoreElements){
			String name = param.nextElement():
			System.out.println(name+ ":"+ context.getInitParameter(name)
		}
```
