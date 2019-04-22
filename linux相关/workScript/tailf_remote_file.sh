#!/bin/bash
# @author by senninha on 2019/04/19

if [ $# -lt 2 ]
then
    echo "tailf 日志文件尾部"
    echo "参数1(每隔n秒刷新一次) 参数2(日志地址) 参数3(保存目录,不带的话，不会保存所有tail的内容)"
    exit 0
fi

start=-1
second=${1}
filename=${2}
tmpLength=0
echo "每隔${second}秒刷新一下${filename}内容"
path=''

if [ $# -gt 2 ]
then
    path=$3
    echo "文件将保存在${path}/${fileName}"
fi

while [ $second -gt 0 ]
do
    headers=$(curl -I -s ${filename} | grep Content-Length: | awk '{print $2}')
    length=${#headers}
    let "length=length-1"
    length=${headers:0:$length}
    if [ ${length} -eq $tmpLength ]
    then
        # file no change, just continue
        continue
    fi
    
    if [ $start -eq 0 ]
    then
        # first loop, download last 1024 bytes
        let "start=length-1024"
    fi
    
    if [ $start -lt 0 ]
    then
        start=0
    else
        # not first loop, let start = (last query length)
        let "start=tmpLength"
    fi
    if [ ${#path} -eq 0 ]
    then
        # don't need to save the file
        curl -s --header "Range: bytes=$start-$length" ${filename}
    else
        realPathFile=${path}"/"${filename##*/}
        curl -s --header "Range: bytes=$start-$length" ${filename} | tee -a ${realPathFile}}
    fi
    tmpLength=$length
    sleep $second
done