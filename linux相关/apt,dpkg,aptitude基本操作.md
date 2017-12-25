###apt,dpkg,aptitude基本操作
> apt是Debian以及衍生的发行版的软件包管理工具,使用这个方式安装软件可以自动解决依赖，dpkg是直接安装deb包，不会自动处理依赖，aptitude在管理包的时候，比apt更好一点。

####设置软件源
设置软件源，相当于设置应用市场用哪个：
> vi /etc/apt/sources.list

然后可以设置如下几个源：
> deb http://mirrors.163.com/debian/ stretch main
deb-src http://mirrors.163.com/debian stretch main
deb http://ftp.de.debian.org/debian jessie main contrib


然后，更新：
> apt-get update


####安装某个软件
如果知道软件包的报名
> apt-get install packageName

如果不确定软件包的报名，可以先搜索
> apt search packageName

采用dpkg安装后解决依赖：
> apt-get -f install

####卸载
卸载但保留配置
> apt-get remove packageName

卸载不保留配置
> apt-get --purge remove packageName

####更新
更新已经安装的软件
> apt-get upgrade

更新系统
> apt-get dist-upgrade

####释放空间
> apt-get clean
apt-get autoclean
apt-get autoremove

####列出所有已经安装软件包
> dpkg -l

####aptitude
aptitude的操作和apt-get基本一样。
