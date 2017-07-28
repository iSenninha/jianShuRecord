#####配置拦截器，比如拦截登陆状态的这类拦截器。拦截特定的url

###1.首先是拦截器代码
    继承HandlerInterceptorAdapter，重写preHanle()方法
```
public class LoginInterceptor extends HandlerInterceptorAdapter {
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
			throws Exception {
		// 不拦截登陆请求
		if (request.getRequestURI().contains("loginIn.action")) {
			return true;
		} else {
			//这里的Auth是自定义的注解，通过注解在controller的方法上来实现是否拦截该请求或者不拦截该请求。
			HandlerMethod handlerMethod = (HandlerMethod) handler;
			Method method = handlerMethod.getMethod();
			Map<String, Object> map = new HashMap<>();
			Auth auth = method.getAnnotation(Auth.class);
			if (auth != null) {
				String login = (String) request.getSession().getAttribute("login");
				if (login == null) {
					map.put("code", 1);
					map.put("info", "please login");
					printJson(map, response);
					return false;
				}
			} else {
				System.out.println("isLogin");
				return true;
			}
		}
		return true;
	}

```

###2.自定义的注解
```
@Documented
@Inherited
@Target({ElementType.METHOD,ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface Auth {
    boolean validate() default true;
}

```

###3.配置拦截器
由于是基于java config 配置的spring_mvc项目，只需要在继承于WebMvcConfigurerAdapter的类里加上自己的拦截器：
```
@Configuration
@EnableWebMvc
@ComponentScan
public class WebConfig extends WebMvcConfigurerAdapter{
        //配置jsp视图解析器
        @Bean
        public ViewResolver viewResolver(){
                InternalResourceViewResolver resolver = new InternalResourceViewResolver();
                resolver.setPrefix("/WEB-INF/pages/");
                resolver.setSuffix(".jsp");
                resolver.setExposeContextBeansAsAttributes(true);
                return resolver;
        }
        
        
        @Override
        public void configureDefaultServletHandling(DefaultServletHandlerConfigurer configurer) {
                // TODO Auto-generated method stub
                //配置静态资源处理
                configurer.enable();;
        }
        
        @Override
        public void addInterceptors(InterceptorRegistry registry) {
        // TODO Auto-generated method stub
		//这里，注册拦截器。
        	registry.addInterceptor(new LoginInterceptor());
        }
        
        /*
         * supprot the Cors access
         */
        @Override
        public void addCorsMappings(CorsRegistry registry) {
        // TODO Auto-generated method stub
	//允许跨越访问
        	registry.addMapping("*").allowedOrigins("*");
        }
}

```

###4.来一个示例
```
	@Auth
	@RequestMapping("/isLogin")
	public @ResponseBody Map<String,Object> isLogin(){
		Map<String,Object> map = new HashMap<String,Object>();
		HttpSession session = request.getSession();
		if(session.getAttribute("login") != null){
			map.put("code", 0);
			map.put("info","login staus!");
		}else{
			map.put("code", 1);
			map.put("info","please login");
		}
		return map;
	}
```
需要拦截的请求加上@Auth即可拦截。

当然，如果项目里只是需要拦截小部分请求，其他都不需要拦截的话，修改拦截器里的判断逻辑即可。
