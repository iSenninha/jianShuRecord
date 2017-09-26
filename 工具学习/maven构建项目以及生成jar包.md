1. 构建项目目录
```
  -src
    -main
      -java
        -package

    -test
      -java
       -package
  -pom.xml
```

2. 配置pom.xml文件，并放到与src平行的目录下。

   ```
   <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd"> 
           <modelVersion>4.0.0</modelVersion> 
           <groupId>com.senninha</groupId> 
           <artifactId>test</artifactId> 
           <version>0.0.1-SNAPSHOT</version> 
    
           <properties> 
                   <mybatis-version>3.0.6</mybatis-version> 
                   <junit-version>4.12</junit-version> 
           </properties> 
    
           <dependencies> 
                   <dependency> 
                           <groupId>junit</groupId> 
                           <artifactId>junit</artifactId> 
                           <version>${junit-version}</version> 
                           <scope>test</scope> 
                   </dependency> 
           </dependencies> 
           <properties>
                   <mybatis-version>3.0.6</mybatis-version>
                   <junit-version>4.12</junit-version>
           </properties>

           <dependencies>
                   <dependency>
                           <groupId>junit</groupId>
                           <artifactId>junit</artifactId>
                           <version>${junit-version}</version>
                           <scope>test</scope>
                   </dependency>
           </dependencies>

   		<!--这个是为了改变编译方式，因为默认使用JDK1.3编译，不支持注解 -->
           <build>
                   <plugins>
                           <plugin>
                                   <groupId>org.apache.maven.plugins</groupId>
                                   <artifactId>maven-compiler-plugin</artifactId>
                                   <configuration>
                                           <source>1.5</source>
                                           <target>1.5</target>
                                   </configuration>
                            </plugin>
                    </plugins>
            </build>
      </project>
   ```

   ​

3. 编写相关代码(main目录下的代码)

> 这个时候运行
>
> ```
> mvn clean compile
> ```
>
> 就可以编译对应的main下面的代码到target目录l

4. 编写测试代码

> 在**src/test/java**目录下编写测试代码，加上Junit的**@Test**注解。
>
> 然后运行如下:
>
> ```
> mvn clean test
> ```
>
> 即可执行对应测试

5. 打包项目成jar包并加入本地仓库

> 运行如下代码：
>
> ```
> mvn clean package
> ```
>
> 就会在对应的**src/target**目下下生成对应的版本号的**jar**包
>
> 以上只是把项目打包，如果需要引用的话依然需要手动build路径，我们可以把这些jar包直接通过以下命令打包到本地仓库里：
>
> ```
> mvn clean install
> ```
>
> 就可以在对应的**本地仓库**看到生成的这个jar包，然后别的项目直接通过**pom**文件引入依赖即可使用这个jar包



6. 生成可执行的jar包

> 以上的方法并没有生成一个可执行的jar包，因为没有在**manifest**配置文件里指定对应的main方法入口，借助以下插件可以生成配置对应的入口main方法：
>
> ```
> 			<plugin>
> 				<groupId>org.apache.maven.plugins</groupId>
> 				<artifactId>maven-shade-plugin</artifactId>
> 				<version>1.2.1</version>
> 				<executions>
> 					<execution>
> 						<phase>package</phase>
> 						<goals>
> 							<goal>shade</goal>
> 						</goals>
> 						<configuration>
> 							<transformers>
> 								<transformer
> 	implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
> 									<mainClass>com.senninha.test.Test</mainClass>
> 								</transformer>
> 							</transformers>
> 						</configuration>
> 					</execution>
> 				</executions>
> 			</plugin>
> ```
>
> 然后执行
>
> ```
> mvn clean package
> ```
>
> 生成jar包，然后运行：
>
> ```
> java -jar 生成的jar包，就会看到按照入口值进行执行
> ```
>
> 再来看看对应的**manifest**文件：
>
> ```
> Manifest-Version: 1.0
> Archiver-Version: Plexus Archiver
> Built-By: senninha
> Created-By: Apache Maven 3.5.0
> Build-Jdk: 1.8.0_144
> Main-Class: com.senninha.test.Test//这里写明了入口类
> ```

7. 在maven/conf/setting.xml 目录下修改镜像以及本地仓库的位置

```
	<localRepository>E:\JAVA WEB TOOLS\apache-maven-3.3.9-bin\repository</localRepository>
	<mirror>
        <id>nexus-aliyun</id>
        <mirrorOf>*</mirrorOf>
        <name>Nexus aliyun</name>
        <url>http://maven.aliyun.com/nexus/content/groups/public</url>
    </mirror> 
```

​	

8. 手动增加本地jar包到仓库

> 还有可能需要手动添加jar包到本地仓库的需求，如下：
>
> ```
> mvn install:install-file -Dfile=taobao-sdk-java-auto_1455552377940-20160607.jar -DgroupId=alidayu.taobao -DartifactId=taobao -Dversion=1.0 -Dpackaging=jar
> ```
>
> jar包路径，jar包groupId，jar包artifactId，jar包version，jar包打包方式，就是jar咯。




