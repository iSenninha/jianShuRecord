###debian配置javaweb开发环境，全部是linux64位的资源

####1.安装mysql 
> apt-get install mysql-server mysql-client
搞定～x


####2.安装jdk环境
[jdk下载地址](http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz)
> //scp -r jdk-8u131-linux-x64.tar.gz root@139.199.0.21:/usr/java
上传文件到远程服务器

> 
tar -zxvf jdk...
vi /etc/profile
追加：
export JAVA_HOME=/home/senninha/soft/jdk/jdk1.8.0_144
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
//\$前面的那个是转义
<br>
使其生效
source /etc/profile

####3.tomcat
[tomcat下载地址](http://mirror.bit.edu.cn/apache/tomcat/tomcat-7/v7.0.77/bin/apache-tomcat-7.0.77.tar.gz) 
解压没啥好写的。。

####4.maven
[maven下载地址](http://mirrors.hust.edu.cn/apache/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz)

> 更改远程仓库为阿里云
   vi /maven/conf/settings.xml
 
 ```
   <mirror>
      <id>alimaven</id>
      <name>aliyun maven</name>
      <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
      <mirrorOf>central</mirrorOf>        
    </mirror>
 ```
 
 > 配置maven环境变量
 MAVEN_HOME=/usr/local/maven/apache-maven-3.3.9
export MAVEN_HOME
export PATH=\${PATH}:\${MAVEN_HOME}/bin
//\是转义字符
 
 
####5.配置debian 163源
```
# 

# deb cdrom:[Debian GNU/Linux 8.7.1 _Jessie_ - Official amd64 NETINST Binary-1 20170116-10:57]/ jessie main

#deb cdrom:[Debian GNU/Linux 8.7.1 _Jessie_ - Official amd64 NETINST Binary-1 20170116-10:57]/ jessie main

deb http://mirrors.163.com/debian/ jessie main
deb-src http://mirrors.163.com/debian/ jessie main

deb http://security.debian.org/ jessie/updates main
deb-src http://security.debian.org/ jessie/updates main

# jessie-updates, previously known as 'volatile'
deb http://mirrors.163.com/debian/ jessie-updates main
deb-src http://mirrors.163.com/debian/ jessie-updates main

```

4.网易云需要使用depin版本打64位

dpkg -i 安装后使用
```
apt-get update && apt-get -f install

```
解决依赖
