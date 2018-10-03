### crossover安装
> 内存不够，带不起虚拟机，类似EIM的软件又必须得用windows，尴尬，就用wine来使用这些软件吧。

#### 1.安装并xx
- [官网下载](http://www.crossoverchina.com/xiazai.html)
	然后安装，安装的时候如果依赖不全的话，换成以下的源:
	```
	deb http://mirrors.163.com/debian/  stretch main non-free contrib
	deb http://mirrors.163.com/debian/  stretch-updates main non-free contrib
	deb http://mirrors.163.com/debian/  stretch-backports main non-free contrib
	deb-src http://mirrors.163.com/debian/  stretch main non-free contrib
	deb-src http://mirrors.163.com/debian/  stretch-updates main non-free contrib
	deb-src http://mirrors.163.com/debian/  stretch-backports main non-free contrib
	deb http://mirrors.163.com/debian-security/  stretch/updates main non-free contrib
	deb-src http://mirrors.163.com/debian-security/  stretch/updates main non-free contrib

	deb http://ftp.us.debian.org/debian/ stretch main non-free contrib
	deb http://ftp.us.debian.org/debian/ stretch-proposed-updates main non-free contrib
	deb-src http://ftp.us.debian.org/debian/ stretch main non-free contrib
	deb-src http://ftp.us.debian.org/debian/ stretch-proposed-updates main non-free contrib
	deb http://ftp.us.debian.org/debian/ stretch-backports main contrib non-free
	deb-src http://ftp.us.debian.org/debian/ stretch-backports main contrib non-free
	deb http://security.debian.org/ stretch/updates main
	deb-src http://security.debian.org/ stretch/updates main
	```
- [你懂的](./CrossOver_Patch.zip)
	解压，然后覆盖，ok
	```
	mv ./winewrapper.exe.so /opt/cxoffice/lib/wine/winewrapper.exe.so
	```
[引用](https://www.k-xzy.xyz/archives/3287)

### 2.可以正常使用的软件
	- EIM	目测开机的时候可以登陆，如果退出了必须重启才能再次登陆
	- QQ-Lite	正常使用
	- navicat [下载](https://pan.baidu.com/s/1nvIIOad)
	```
	NAVN-LNXG-XHHX-5NOO

	```
	[参考](https://blog.csdn.net/weixin_40426638/article/details/78933585)
