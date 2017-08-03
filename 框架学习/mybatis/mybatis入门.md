####mybatis入门

- 配置文件

#####1.总的配置文件
> Configuration.xml
```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
	<!-- 这里设置别名 -->
	<typeAliases>
		<typeAlias alias="User" type="com.senninha.mybatis.util.User" />
	</typeAliases>
	<environments default="development">
		<environment id="development">
			<transactionManager type="JDBC" />
			<dataSource type="POOLED">
			<!-- 这里使用打是mariaDB -->
				<property name="driver" value="org.mariadb.jdbc.Driver" />
				<property name="url" value="jdbc:mariadb://127.0.0.1:3306/senninha" />
				<property name="username" value="senninha" />
				<property name="password" value="" />
			</dataSource>
		</environment>
	</environments>
	<!-- 导入具体的mapper，也可以全部写在一个文件夹里-->
	<mappers>
		<mapper resource="com/senninha/mybatis/util/User.xml" />
	</mappers>
</configuration>
```
#####2.mapper配置文件
> com.senninha.mybatis.util.User.xml
```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-config.dtd">
<!--命名空间要唯一 -->
<mapper namespace = "com.senninha.mybatis.UserManager">
	<resultMap id = "user" type = "com.senninha.mybatis.util.User">
		<result column = "_id" property = "id" jdbcType = "INTEGER"></result>
		<result column = "name" property = "name" jdbcType = "VARCHAR"></result>
		<result column = "age" property = "age" jdbcType = "INTEGER"></result>
	</resultMap>
	
	<select id = "select" parameterType = "int" resultMap = "user">
		select * from user where _id = #{id}
	</select>
</mapper>

```
> 对应的java文件:
```
public class User {
	private int id;
	private String name;
	private int age;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getAge() {
		return age;
	}

	public void setAge(int age) {
		this.age = age;
	}

	@Override
	public String toString() {
		return "User [id=" + id + ", name=" + name + ", age=" + age + "]";
	}

}
```

#####3.建库相关
```
create database senninha charset=utf8;

use senninha;

create table user(
_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(50),
age INT);

insert into user (name, age) value("senninha", 21);
```
&nbsp;

- 工具类代码

#####1.DBUtil.java
```
public class DBUtil {
	private static SqlSessionFactory sqlMapper;

	private static Object obj = new Object();

	private static DBUtil dbUtil = null;

	private DBUtil() {
		try {
			Reader reader = Resources.getResourceAsReader("Configuration.xml");
			sqlMapper = new SqlSessionFactoryBuilder().build(reader);
			reader.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static DBUtil getDBUtil() {
		if (dbUtil == null) {
			synchronized (obj) {
				if (dbUtil == null) {
					dbUtil = new DBUtil();
				}
			}
		}
		return dbUtil;
	}

	public SqlSessionFactory getSqlMapper() {
		return sqlMapper;
	}

	public void setSqlMapper(SqlSessionFactory sqlMapper) {
		this.sqlMapper = sqlMapper;
	}

}
```

#####2.测试代码
```
private static void selectOne() {
		DBUtil dbUtil = DBUtil.getDBUtil();
		SqlSessionFactory sessionFactory = dbUtil.getSqlMapper();
		SqlSession session = sessionFactory.openSession();
		User user = (User)session.selectOne("com.senninha.mybatis.UserManager.select", 1);
		System.out.println(user.toString());
	}
```
&nbsp;

> 代码跑起来。现在来分析一下这个映射的过程是如何实现的。
从DBUtil里看起，首先是读取主配置文件Configuration.xml。主配置文件里包括的内容包括:
1.连接数据库相关的配置，比如地址，端口号，登录用户名，密码等
2.和映射文件相关打mapper文件，所以mapper文件才是关键。

Mapper文件解析：
还是要先从代码开始：
```
User user = (User)session.selectOne("com.senninha.mybatis.UserManager.select", 1);
```
这段代码直接就把数据库打数据映射成了User对象，看一下这个参数"***com.senninha.mybatis.UserManager.select***"是什么东西

从mapper文件里可以看出来***com.senninha.mybatis.UserManager***是mapper配置文件里的命名空间，而***select***是select标签的id

```
<!-- User.xml配置文件 -->
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-config.dtd">
<mapper namespace = "com.senninha.mybat，is.UserManager">
	<resultMap id = "user" type = "com.senninha.mybatis.util.User">
		<result column = "_id" property = "id" jdbcType = "INTEGER"></result>
		<result column = "name" property = "name" jdbcType = "VARCHAR"></result>
		<result column = "age" property = "age" jdbcType = "INTEGER"></result>
	</resultMap>
	
	<select id = "select" parameterType = "int" resultMap = "user">
		select * from user where _id = #{id}
	</select>
</mapper>
```
> 可以猜测，在mybatis启动的时候，会扫描所有配置在resultMap里的类，然后保存在一个数据结构里(Map?)，然后在运行的时候，根据***命名空间+select id***的方式，就可以通过反射讲数据库中打数据映射成对象。

&nbsp;

- 面向接口编程
> 上面的代码中，要执行某个CRUD操作的时候，要输入一大坨字符串，使用另外一种面向接口编程的风格可以改变这种情况

#####1.首先改造一下user.xml文件里打命名空间和对应的select id
```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-config.dtd">
<!-- 这里这个包下对应的是一个接口的类名 -->
<mapper namespace = "com.senninha.mybatis.util.UserManager">
	<resultMap id = "user" type = "com.senninha.mybatis.util.User">
		<result column = "_id" property = "id" jdbcType = "INTEGER"></result>
		<result column = "name" property = "name" jdbcType = "VARCHAR"></result>
		<result column = "age" property = "age" jdbcType = "INTEGER"></result>
	</resultMap>
	
	<select id = "select" parameterType = "int" resultMap = "user">
		select * from user where _id = #{id}
	</select>
</mapper>
```

#####2.接口UserManager.java
```
public interface UserManager {
	User select(int id);
}

```

#####3.测试代码变成如下:
```
DBUtil dbUtil = DBUtil.getDBUtil();
		SqlSessionFactory sessionFactory = dbUtil.getSqlMapper();
		SqlSession session = sessionFactory.openSession();
		UserManager userManager = session.getMapper(UserManager.class);
		System.out.println(userManager.select(1));
```
> 1.mapper里类的命名空间要与对应接口的完整路径完全相符合;
2.mapper里对应的id要与对应接口的方法名完全符合;

这里面的原理？为什么一个接口蜜汁就有了实现类?
加上如下代码看看这个userManager是什么东西：
```
	Class clazz = userManager.getClass();
	System.out.println("class's name is :" + clazz.getName());
	//class's name is :com.sun.proxy.$Proxy1
	//调用jdk的动态代理实现？埋个坑，以后再看。
```

&nbsp;

- 增删改查

```

	<select id = "select" parameterType = "int" resultMap = "user">
		select * from user where _id = #{id}
	</select>
	
	<insert id = "insert" parameterType = "user" useGeneratedKeys="true" keyProperty="_id">
		insert into user (name, age) value(#{name}, #{age})
	</insert>
	
	<update id = "update" parameterType = "user">
		update user set name = #{name}, age = #{age} where _id = #{id}	
	</update>
	
	<delete id = "delete" parameterType = "int">
		delete from user where _id = #{id}
	</delete>
```
> userGenerateKeys 表明要mybatis获取数据库自动生成的主键，name，age对应的是User类里的成员变量名，并且要有对应的set，get方法。
对数据产生改变的操作记得提交事物管理，否则无法更改生效。

> mybatis的基本用法就是这些了。
