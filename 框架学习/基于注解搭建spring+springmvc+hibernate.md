###maven依赖：
新建maven项目就不写了。。。
```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
        <modelVersion>4.0.0</modelVersion>
        <groupId>com.senninha</groupId>
        <artifactId>websocket</artifactId>
        <packaging>war</packaging>
        <version>0.0.1-SNAPSHOT</version>
        <name>websocket Maven Webapp</name>
        <url>http://maven.apache.org</url>

        <!-- 版本配置参数 -->
        <properties>
                <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
                <hibernate.version>4.3.8.Final</hibernate.version>
                <spring.version>4.3.6.RELEASE</spring.version>
                <struts2.version>2.3.20</struts2.version>
                <jackson.version>2.5.0</jackson.version>
                <mysql.version>5.1.38</mysql.version>
                <slf4j.version>1.6.6</slf4j.version>
                <jackson.version>2.8.1</jackson.version>
                <druid.version>1.0.12</druid.version>
                <jstl.version>1.2</jstl.version>
                <servlet-api.version>2.5</servlet-api.version>
                <jsp-api.version>2.0</jsp-api.version>
                <commons-lang3.version>3.3.2</commons-lang3.version>
                <commons-io.version>1.3.2</commons-io.version>
                <commons-net.version>3.3</commons-net.version>
                <commons-codec.version>1.8</commons-codec.version>
                <commons-fileupload.version>1.3.1</commons-fileupload.version>
        </properties>


        <dependencies>
                <dependency>
                        <groupId>junit</groupId>
                        <artifactId>junit</artifactId>
                        <version>4.12</version>
                </dependency>

                <dependency>
                        <groupId>org.springframework</groupId>
                        <artifactId>spring-core</artifactId>
                        <version>${spring.version}</version>
                </dependency>

                <dependency>
                        <groupId>org.springframework</groupId>
                        <artifactId>spring-orm</artifactId>
                        <version>${spring.version}</version>
                </dependency>

                <dependency>
                        <groupId>org.springframework</groupId>
                        <artifactId>spring-websocket</artifactId>
                        <version>${spring.version}</version>
                </dependency>

                <dependency>
                        <groupId>org.springframework</groupId>
                        <artifactId>spring-test</artifactId>
                        <version>${spring.version}</version>
                </dependency>

                <!-- websocket -->
                <dependency>
                        <groupId>javax.websocket</groupId>
                        <artifactId>javax.websocket-api</artifactId>
                        <version>1.1</version>
                </dependency>

                <!-- spring mvc -->

                <!-- https://mvnrepository.com/artifact/org.springframework/spring-web -->
                <dependency>
                        <groupId>org.springframework</groupId>
                        <artifactId>spring-web</artifactId>
                        <version>${spring.version}</version>
                </dependency>


                <!-- MySql -->
                <dependency>
                        <groupId>mysql</groupId>
                        <artifactId>mysql-connector-java</artifactId>
                        <version>${mysql.version}</version>
                </dependency>
                <!-- 连接池 -->
                <dependency>
                        <groupId>com.alibaba</groupId>
                        <artifactId>druid</artifactId>
                        <version>${druid.version}</version>
                </dependency>
                <!-- Apache工具组件 -->
                <dependency>
                        <groupId>org.apache.commons</groupId>
                        <artifactId>commons-lang3</artifactId>
                        <version>${commons-lang3.version}</version>
                </dependency>
                <dependency>
                        <groupId>org.apache.commons</groupId>
                        <artifactId>commons-io</artifactId>
                        <version>${commons-io.version}</version>
                </dependency>
                <dependency>
                        <groupId>commons-net</groupId>
                        <artifactId>commons-net</artifactId>
                        <version>${commons-net.version}</version>
                </dependency>

                <!-- https://mvnrepository.com/artifact/org.springframework/spring-webmvc -->
                <dependency>
                        <groupId>org.springframework</groupId>
                        <artifactId>spring-webmvc</artifactId>
                        <version>${spring.version}</version>
                </dependency>


                <!-- jackson -->
                <dependency>
                        <groupId>com.fasterxml.jackson.core</groupId>
                        <artifactId>jackson-databind</artifactId>
                        <version>2.8.6</version>
                </dependency>

                <!-- https://mvnrepository.com/artifact/javax.servlet/javax.servlet-api -->
                <dependency>
                        <groupId>javax.servlet</groupId>
                        <artifactId>javax.servlet-api</artifactId>
                        <version>3.0.1</version>
                </dependency>


                <dependency>
                        <groupId>javax.websocket</groupId>
                        <artifactId>javax.websocket-api</artifactId>
                        <version>1.0</version>
                        <scope>provided</scope>
                </dependency>

                <!-- validate param -->
                <!-- https://mvnrepository.com/artifact/javax.validation/validation-api -->
                <dependency>
                        <groupId>javax.validation</groupId>
                        <artifactId>validation-api</artifactId>
                        <version>1.1.0.Final</version>
                </dependency>
                <!-- https://mvnrepository.com/artifact/org.hibernate/hibernate-validator -->
                <dependency>
                        <groupId>org.hibernate</groupId>
                        <artifactId>hibernate-validator</artifactId>
                        <version>5.4.0.Final</version>
                </dependency>


                <!-- hibernate -->
                <dependency>
                        <groupId>org.hibernate</groupId>
                        <artifactId>hibernate-core</artifactId>
                        <version>${hibernate.version}</version>
                </dependency>
                
                                <!-- 日志处理 -->
                <dependency>
                        <groupId>org.slf4j</groupId>
                        <artifactId>slf4j-log4j12</artifactId>
                        <version>${slf4j.version}</version>
                </dependency>


        </dependencies>
        <build>
                <finalName>websocket</finalName>
        </build>
</project>

```

###2.建立相关的java替代xml配置
####a.新建一个WebAppIntializer类，对应的是web.xml文件
    新建一个webAppIntializer类继承AbstractAnnotationConfigDispatcherServletInitializer,容器在启动时会自动扫描是否有类继承了这个抽象类，如果有则用它来配置servlet容器。

```
public class WebAppInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {

        /*
         * 对应的是spring的配置文件,这个文件在下边
         */
        @Override
        protected Class<?>[] getRootConfigClasses() {
                // TODO Auto-generated method stub
                return new Class<?>[]{RootConfig.class};
        }
       
        /*
        *对应的也是配置文件，这个文件也在下边
        */
        @Override
        protected Class<?>[] getServletConfigClasses() {
                // TODO Auto-generated method stub
                return new Class<?>[]{WebConfig.class};
        }
        
        /*
         * 将DispathcerServlet映射到"/"里
         */
        @Override
        protected String[] getServletMappings() {
                // TODO Auto-generated method stub
                return new String[]{"/"};
        }

}

```
####b.RootConfig：
```
//这里的basepackages里设置的是扫描路径。
@Configuration
@ComponentScan(basePackages={"com.senninha.spring.annotation4mvc","com.senninha.spring.controler"},
                excludeFilters = {@Filter(type = FilterType.ANNOTATION,value = EnableWebMvc.class)})
public class RootConfig {

}

```

####c.WebConfig:
```
@Configuration
@EnableWebMvc
@ComponentScan("com.senninha.spring.annotation4mvc")
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
        
        //这里可以配置自定义的拦截器
        @Override
        public void addInterceptors(InterceptorRegistry registry) {
        // TODO Auto-generated method stub
        	registry.addInterceptor(xxxx));
        }
        
        /*
         *夸鱼访问支持，前后端分离开发时用得到
         */
        @Override
        public void addCorsMappings(CorsRegistry registry) {
        // TODO Auto-generated method stub
        	registry.addMapping("*").allowedOrigins("*");
        }
}
```
关于拦截器的文章在这里可以看到[springmvc拦截器](http://www.jianshu.com/p/13a00e37cd91)


###3建立一个简单的controller吧（对应Servlet)
```
//记得要把所在包加入扫描路径
@Controller
@Scope("prototype")
public class UploadController {

	//这里是访问的路径/test
	@RequestMapping(value = "/test")
	public String test() {
		//对应的是test.jsp视图
		return "test";
	}
```
访问loaclhost:8080/项目名/test 就可以转发到定义的那个test.jsp视图了。


以上已经建立了springmvc + spring 的web项目了，下面加上hiberante和druid连接池,由于没找到怎么配置hibernate的注解，就只好用xml了。。。
###3.引入配置文件：
db.properties文件
```
jdbc.driver=com.mysql.jdbc.Driver
#jdbc.url=jdbc:mysql://localhost:3306/esmp?characterEncoding=utf-8
jdbc.url=jdbc:mysql://127.0.0.1:3306/senninha?autoReconnect=true&useSSL=false&autoReconnectForPools=true&useUnicode=true&characterEncoding=UTF-8
jdbc.username=root
jdbc.password=
## Hibernate\u914d\u7f6e
#\u6570\u636e\u5e93\u751f\u6210\u7b56\u7565
hibernate.hbm2ddl.auto=update
#\u683c\u5f0f\u5316sql
hibernate.format_sql=true
#\u662f\u5426\u663e\u793asql
hibernate.show_sql =true
#sql\u65b9\u8a00
hibernate.dialect=org.hibernate.dialect.MySQL5Dialect
##druid\u8fde\u63a5\u6c60\u914d\u7f6e
#\u521d\u59cb\u5316\u65f6\u5efa\u7acb\u7269\u7406\u8fde\u63a5\u7684\u4e2a\u6570
jdbc.pool.initialSize=1
#\u6700\u5927\u8fde\u63a5\u6c60\u6570\u91cf
jdbc.pool.maxActive=20
#\u6700\u5c0f\u8fde\u63a5\u6c60\u6570\u91cf
jdbc.pool.minIdle=1
#\u83b7\u53d6\u8fde\u63a5\u65f6\u6700\u5927\u7b49\u5f85\u65f6\u95f4\uff0c\u5355\u4f4d\u6beb\u79d2
jdbc.pool.maxWait=6000
jdbc.pool.timeBetweenEvictionRunsMillis=60000
#\u8fde\u63a5\u4fdd\u6301\u7a7a\u95f2\u800c\u4e0d\u88ab\u9a71\u9010\u7684\u6700\u957f\u65f6\u95f4
jdbc.pool.minEvictableIdleTimeMillis=300000
#\u68c0\u6d4b\u8fde\u63a5\u662f\u5426\u6709\u6548
jdbc.pool.testWhileIdle=true
#\u7533\u8bf7\u8fde\u63a5\u65f6\u6267\u884cvalidationQuery\u68c0\u6d4b\u8fde\u63a5\u662f\u5426\u6709\u6548\uff0c\u505a\u4e86\u8fd9\u4e2a\u914d\u7f6e\u4f1a\u964d\u4f4e\u6027\u80fd\u3002
jdbc.pool.testOnBorrow=false
#\u5f52\u8fd8\u8fde\u63a5\u65f6\u6267\u884cvalidationQuery\u68c0\u6d4b\u8fde\u63a5\u662f\u5426\u6709\u6548\uff0c\u505a\u4e86\u8fd9\u4e2a\u914d\u7f6e\u4f1a\u964d\u4f4e\u6027\u80fd
jdbc.pool.testOnReturn=false
#\u662f\u5426\u7f13\u5b58preparedStatement\uff0c\u4e5f\u5c31\u662fPSCache\u3002PSCache\u5bf9\u652f\u6301\u6e38\u6807\u7684\u6570\u636e\u5e93\u6027\u80fd\u63d0\u5347\u5de8\u5927\uff0c\u6bd4\u5982\u8bf4oracle\u3002\u5728mysql\u4e0b\u5efa\u8bae\u5173\u95ed\u3002
jdbc.pool.poolPreparedStatements=false
#\u8981\u542f\u7528PSCache\uff0c\u5fc5\u987b\u914d\u7f6e\u5927\u4e8e0\uff0c\u5f53\u5927\u4e8e0\u65f6\uff0cpoolPreparedStatements\u81ea\u52a8\u89e6\u53d1\u4fee\u6539\u4e3atrue\u3002\u5728Druid\u4e2d\uff0c\u4e0d\u4f1a\u5b58\u5728Oracle\u4e0bPSCache\u5360\u7528\u5185\u5b58\u8fc7\u591a\u7684\u95ee\u9898\uff0c\u53ef\u4ee5\u628a\u8fd9\u4e2a\u6570\u503c\u914d\u7f6e\u5927\u4e00\u4e9b\uff0c\u6bd4\u5982\u8bf4100
jdbc.pool.maxOpenPreparedStatements=20
#druid\u76d1\u63a7
jdbc.pool.filters=stat,log4j
jdbc.pool.connectionProperties=druid.stat.mergeSql=true;druid.stat.slowSqlMillis=5000
```

引入xml文件：
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:context="http://www.springframework.org/schema/context" xmlns:p="http://www.springframework.org/schema/p"
	xmlns:aop="http://www.springframework.org/schema/aop" xmlns:tx="http://www.springframework.org/schema/tx"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.0.xsd
	http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.0.xsd
	http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-4.0.xsd http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx-4.0.xsd
	http://www.springframework.org/schema/util http://www.springframework.org/schema/util/spring-util-4.0.xsd">

	<!-- 加载配置文件 -->
	<context:property-placeholder location="classpath:db.properties" />
	<!-- 数据库连接池 -->
	<bean id="dataSource" class="com.alibaba.druid.pool.DruidDataSource"
		destroy-method="close">
		<property name="url" value="${jdbc.url}" />
		<property name="username" value="${jdbc.username}" />
		<property name="password" value="${jdbc.password}" />
		<property name="driverClassName" value="${jdbc.driver}" />
		<!-- druid连接池配置 -->
		<property name="initialSize" value="${jdbc.pool.initialSize}" />
		<property name="maxActive" value="${jdbc.pool.maxActive}" />
		<property name="minIdle" value="${jdbc.pool.minIdle}" />
		<property name="maxWait" value="${jdbc.pool.maxWait}" />
		<property name="timeBetweenEvictionRunsMillis" value="${jdbc.pool.timeBetweenEvictionRunsMillis}" />
		<property name="minEvictableIdleTimeMillis" value="${jdbc.pool.minEvictableIdleTimeMillis}" />
		<property name="testWhileIdle" value="${jdbc.pool.testWhileIdle}" />
		<property name="testOnBorrow" value="${jdbc.pool.testOnBorrow}" />
		<property name="testOnReturn" value="${jdbc.pool.testOnReturn}" />
		<property name="poolPreparedStatements" value="${jdbc.pool.poolPreparedStatements}" />
		<property name="maxOpenPreparedStatements" value="${jdbc.pool.maxOpenPreparedStatements}" />
		<property name="filters" value="${jdbc.pool.filters}" />
		<property name="connectionProperties" value="${jdbc.pool.connectionProperties}" />
		<!-- 防止MYSQL 8小时断开重连,该属性在配置testWhileIndle=true时有效 -->
		<property name="validationQuery" value="select 1" />
	</bean>

	<!-- hibernate配置 -->
	<bean id="sessionFactory"
		class="org.springframework.orm.hibernate4.LocalSessionFactoryBean">
		<property name="dataSource" ref="dataSource" />
		<!--注解配置该属性 hibernate自动扫描包路径 -->
		<property name="packagesToScan">
			<!-- 扫描符合路径包下所有实体 -->
			<value>com.senninha.*.orm</value>
		</property>
		<property name="hibernateProperties">
			<props>
				<prop key="hibernate.hbm2ddl.auto">${hibernate.hbm2ddl.auto}</prop>
				<prop key="hibernate.dialect">${hibernate.dialect}</prop>
				<prop key="hibernate.show_sql">${hibernate.show_sql}</prop>
				<prop key="hibernate.format_sql">${hibernate.format_sql}</prop>
			</props>
		</property>
	</bean>
	<!-- 可以在这里设置扫描的路径，也可以在RootConfig.java里设置-->
	<context:component-scan base-package="com.senninha.*.dao"></context:component-scan>
	
		<!-- 配置声明式事务管理（采用注解的方式） -->
	<bean id="transactionManager"
		class="org.springframework.orm.hibernate4.HibernateTransactionManager">
		<property name="sessionFactory" ref="sessionFactory"></property>
	</bean>
	<!-- 注解驱动 -->
	<tx:annotation-driven transaction-manager="transactionManager" />
</beans>
```

然后在b.RootConfig.java里引入这个xml配置文件：
```


@Configuration
@ComponentScan(basePackages={"com.senninha.spring.annotation4mvc","com.senninha.spring.controler"},
                excludeFilters = {@Filter(type = FilterType.ANNOTATION,value = EnableWebMvc.class)})
 @ImportResource(value = {"classpath:applicationContext-dao.xml"})
public class RootConfig {

}
```


然后在符合com.senninha.*.orm路径的包下建立实体类即可自动建表(数据库要先用sql建好 create database senninha character set=utf8)
```
@Entity
@Table(name = "admin_login", catalog = "senninha")
public class AdminLogin implements Serializable {
	private int id;
	private String password;
	private String salt;
	private Date lastLoginTime;
	
	@Column(name = "id" ,unique = true)
	@Id
	@GeneratedValue(strategy = IDENTITY)
	public int getId() {
		return id;
	}
	
	@Column(name = "password" , length = 64)
	public String getPassword() {
		return password;
	}
	
	@Column(name = "salt" , length = 10)
	public String getSalt() {
		return salt;
	}
	
	@Column(name = "last_login_time")
	public Date getLastLoginTime() {
		return lastLoginTime;
	}
	

	public void setId(int id) {
		this.id = id;
	}
	public void setPassword(String password) {
		this.password = password;
	}
	public void setSalt(String salt) {
		this.salt = salt;
	}
	public void setLastLoginTime(Date lastLoginTime) {
		this.lastLoginTime = lastLoginTime;
	}
}
```
对应数据库的操作应该有dao层，service层（实物注解放在这里）

dao
```
@Repository
public class Dao{
	
	@Autowired
	private SessionFactory sessionFactory;

	@Override
	public int add(AdminLogin login) {
		// TODO Auto-generated method stub
		int flag=0;
		try{
			Session session=sessionFactory.getCurrentSession();
			session.save(login);
			flag=1;
		}catch(Exception e){
			e.printStackTrace();
		}
		return flag;
	}
```

service
```

@Service
@Transactional(rollbackFor=Exception.class)
public class  Service{
	
	@Autowired
	private Dao dao;

	@Override
	public int add() {
		// TODO Auto-generated method stub
		AdminLogin login = new AdminLogin();
		//设置属性
		login.setxxxx...
		dao.add(login);
		return 1;
	}
```

至于谁来调用service呢，contoller那里的test就可以
```
@Controller
@Scope("prototype")
public class UploadController {
	@Autowired
	private Service service;
	//这里是访问的路径/test
	@RequestMapping(value = "/test")
	public String test() {
		//对应的是test.jsp视图
		service.add();
		return "test";
	}
```

至此就搭建完啦。
