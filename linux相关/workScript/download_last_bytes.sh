#!/bin/bash

if [ $# -lt 2 ]
then
	echo "下载文件尾部后n M数据，用于大日志下载"
	echo "参数1(nM) 参数2(日志地址) 参数3(日志下载完放在哪个目录,默认tmp目录)"
	exit 0
fi

path="/tmp/"
if [ $# -gt 3 ]
then
	path=$3
fi

headers=$(curl -I -s $2 | grep Content-Length: | awk '{print $2}')
length=${#headers}
let "length=length-2"
length=${headers:0:$length}
start=0
let "start=length-$1*1024*1024"
if [ $start -lt 0 ]
then
	start=0
fi
echo "下载:$2 start $start 到end $length 字节的日志"
fileName="$path""tailOf${1}m${2##*/}"
echo "保存在:$fileName"
curl --header "Range: bytes=$start-$length" $2 > $fileName
