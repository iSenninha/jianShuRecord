#!/bin/bash
# @author by senninha on 2019/04/19

if [ $# -lt 3 ]
then
    echo "tailf 日志文件尾部"
    echo "参数1(每隔n秒刷新一次) 参数2(首次tail多少个字节) 参数3(日志地址) 参数4(保存目录,不带的话，不会保存所有tail的内容)"
    exit 0
fi

start=-1
second=${1}
# first tail bytes
firstBytes=${2}
filename=${3}
tmpLength=0
echo "每隔${second}秒刷新一下${filename}内容"
path=''

if [ $# -gt 3 ]
then
    path=$4
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
    
    if [ $length -lt $tmpLength ]
    then
        # log switch file,just let start=0
        let "start=0"
    elif [ $start -eq -1 ]
    then
        # first loop, download last 1024 bytes
        let "start=length-${firstBytes}"
        echo "${firstBytes} - ${start} - ${length}" > /tmp/ttt
    fi
    
    if [ $start -lt 0 ]
    then
        start=0
    else
        if [ ${tmpLength} -gt 0 ] 
        then
        # not first loop, let start = (last query length)
        let "start=tmpLength"
        fi
    fi

    if [ ${#path} -eq 0 ]
    then
        # don't need to save the file
        curl -s --header "Range: bytes=$start-$length" ${filename}
    else
        if [ ! -d ${path} ] 
        then
            echo "${path} 不存在，将新建"
            mkdir -p ${path}
        fi
        realPathFile=${path}"/"${filename##*/}
        curl -s --header "Range: bytes=$start-$length" ${filename} | tee -a ${realPathFile}
    fi
    tmpLength=$length
    sleep $second
done