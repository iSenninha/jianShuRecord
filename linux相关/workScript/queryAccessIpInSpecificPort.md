### 查询特定端口的ip访问情况

> 版瓦工上的ss老是有奇怪的ip连上来，写个脚本记录一下

#### 1.脚本

```bash

#!/bin/bash
hasIp=0
tmp="/tmp/tmpIp.log"
netstat -ntp | grep 6144 | awk  '{print $5}'| awk -F ':' '{print $1}' | sort | uniq > $tmp
while read line 
do 
	hasIp=1
	curl http://ip.taobao.com/service/getIpInfo.php?ip=$line
done < $tmp

if [ $hasIp -eq 1 ]
then
	echo `date` "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
fi
```

用了某宝的接口...



#### 2.设置定时任务

```shell
crontab -e
*/10 * * * * /bin/bash /root/queryip.sh >> /tmp/ip.log
```

每十分钟执行一次...