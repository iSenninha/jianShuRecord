1.构建项目目录

	-src
	  -main
	    -java
	      -package
		
	  -test
	    -java
	     -package
	-pom.xml

2.编写相关代码。

3.配置pom.xml文件，并放到与src平行的目录下。
```
	<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.senninha</groupId>
	<artifactId>maven</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	<!--引入junit4jar包-->
	<dependencies>
		<dependency>
			<groupId>junit</groupId>
			<artifactId>junit</artifactId>
			<version>4.10</version>
		</dependency>
	</dependencies>
	</project>
```
4.在maven/conf/setting.xml 目录下修改镜像以及本地仓库的位置。
```
	<localRepository>E:\JAVA WEB TOOLS\apache-maven-3.3.9-bin\repository</localRepository>
	<mirror>
        <id>nexus-aliyun</id>
        <mirrorOf>*</mirrorOf>
        <name>Nexus aliyun</name>
        <url>http://maven.aliyun.com/nexus/content/groups/public</url>
    </mirror> 
```


	
5.增加本地jar包到仓库
> mvn install:install-file -Dfile=taobao-sdk-java-auto_1455552377940-20160607.jar -DgroupId=alidayu.taobao -DartifactId=taobao -Dversion=1.0 -Dpackaging=jar

jar包路径，jar包groupId，jar包artifactId，jar包version，jar包打包方式，就是jar咯。

6.生成源码jar包
> git上来下源码后需要打包成源码的时候使用一下命令
1.目录切换到对应的pom.xml配置文件下，运行：
mvn source:jar
会以pom配置文件里的配置信息去打包源码


7.打包成普通jar包
>切换到对应的pom.xml配置文件下，运行即可： 
mvn package


