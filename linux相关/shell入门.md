Shell入门笔记

用文本编辑器编辑

####1.helloworld
```
#!/bin/sh
echo "hello world"
```
保存为hello.sh
运行 ./hello.sh，即输出**hello world**

####2.读取键盘输入
```
#!/bin/sh
echo "plean enter your name"
read person
echo "your name is ${person}"
```
输出 **your name is senninha"**

####3.设置变量
```
#!/bin/sh
person="senninha"
readonly person
echo ${person}
```
注意这里变量名等号两边不能加空格，设置readonly后不能再去修改变量值，然后unset person清除变量。

####4.特殊变量
|变量|含义|
|:----:|:---:|
|$$|当前shell的进程id|
|$0|当前脚本的文件明|
|$#|传递给脚本的参数个数
|$*|传递给脚本或者函数的所有参数|
|$@|传递给脚本的所有函数的所有参数，在被""包裹的时候和$*不同，差异如下|

脚本：
```
for var in "$*"
do
    echo "$var"
done

for var in "$@"
do
    echo "$var"
done

```
执行结果：./hello.sh senninha bruno
> senninha bruno
senninha
bruno
可见，如果$*被**双引号**包裹，那么它就变成了一个一个变量，而$@还是一个数组

####5.shell变量替换，命令替换，转义替换
#####a.转义字符替换

echo  "value is \n"


|转义字符|含义|
|:----:|:---:|
|\\|反斜杠|
|\a|警报|
|\b|退格|
|\f|换页，将当前位置移到下页开头|
|\n|换行|
|\r|回车|
|\t|水平制表符|
|\v|垂直制表符|

#####b.命令替换
```
#!/bin/sh
command=`ls`
echo "${command}
```
这样就会输出**ls**命令的内容，注意这里的不是单引号，是和markdown包裹代码的那个单引号来的。

#####c.变量替换，查询变量是否为空，是否定义了
|形式|含义|
|:----:|:---:|
|${var}|变量本来的值|
|${var:-word|如果为空，返回word的至，但是不修改var的值|
|${var:=word|如果为空，则返回word的值，并且修改var为word的值|
|${var:?message"|如果变量 var 为空或已被删除(unset)，那么将消息 message 送到标准错误输出，可以用来检测变量 var 是否可以被正常赋值。
若此替换出现在Shell脚本中，那么脚本将停止运行。|
|${var:+word}|如果变量var被定义，则返回word|

```
#!/bin/sh
test="senninha"

senninha=${test:+"word"}
echo ${senninha}

```
如此将返回word

#####6.运算符
######a.算术运算符
> 原生bash不支持简单的数学运算，但是可以通过其他命令来实现，例如 awk 和 expr，expr 最常用。expr 是一款表达式计算工具，使用它能完成表达式的求值操作。

注意 操作数与符号之间需要有**空格**

|运算符|含义|
|:---:|:---:|
|+|`expr 1 + 1`|
|*|`expr 1 \* 1`乘法比较奇葩，需要转义字符|
|=|赋值|
|==|比较两个数字是否相同，${a}==${b}|
|!=|不相等，${a}!=${b}|

######b.关系运算符(可以直接在shell里使用)
|运算符|含义|
|:---:|:---:|
|-eq|相等|
|-ne|不相等|
|-gt|左边的大于右边|
|-lt|左边小于右边|
|-ge|左边大于等于右边|
|-le|左边小于等于右边|


布尔运算符：

|运算符|含义|
|:---:|:---:|
|!|非|
|-o|或|
|-1|与|

```
#!/bin/sh
command=`expr 1 + 1`
if [ 1 -le 1 ]
then
echo "true"
fi
```
> 貌似只能在if语句里使用，if语句也有点奇葩 ，if右边必须空格

#####5.字符串运算符
|运算符|含义|
|:---:|:---:|
|=|判断是否相等|
|!=|判断是否相等|
|-z|若长度为0,返回true|
|-n|不为0,返回true|
|str|不为空返回ture（null）|

```
#!/bin/sh
s=""
if [ -z ${s} ]
then
echo "true"
fi

s="senninha"
if [ -n ${s} ]
then
echo "${s}"
fi

if [ ${ss} ]
then
echo "hi"
fi

```

#####6.检查文件相关
运算符|含义|
|:---:|:---:|
|-e "path"|文件是否存在|
|-w "path"|可读|
|-r "path"|可写|
|-x "path"|可执行|
|-f "path"|是否是普通文件，除目录，设备文件|
|-d "path"|是否是目录
|-e "path"|检查文件是否为空，不空返回true|

#####7.注释
打#即是注释，多行注释可以定义为函数，不调用这个函数即可以看成是注释

#####8.字符串
str="str"
字符串的长度
${#str}
查找字符串
> `expr index "$string" t`

使用expr表达式，index是命令的一部分，表示最后的t表示的是要查找的目标串

提取子串
> `expr substr "${str} 1 2"

提取子字符串,一样使用expr表达式，这里的1,2表示起止位置，奇葩的是起始位置1表示的是从第一个字符开始。。就是一个闭区间


#####9.echo的使用
输出重定向：
1.覆盖一个写入文件：
```
#!/bin/sh
senninha="senninha"
echo ${senninha} > senninha.text
```
把senninha输出到senninha.text文件里

上面那个是覆盖，下面这个是追加：
```
echo ${senninha} >> senninha.txt 
#即是把> 换成了 >>
```

#####10.if语句

有点脑残的if
if [ xx=xx ]
if 和 [ ] 直接必须有空格
然后if-else是这样的：
if [ ]
then
必须有表达式
else

fi(结尾)

if-elseif
if []
这里必须有表达式
then
elif [ ]
这里必须有表达式
then
else
fi
满足条件后的表达式不能为空，必须有表达式


#####11.test表达式
校验数值是否相等
```
if test ${} -eq ${}
then
echo "equals"
else
echo "not equals"
fi
```
其他含义字符：

|运算符|含义|
|:--:|:--|
|-eq|相等|
|-ne|不相等|
|-le|小于等于|
|-ge|大于等于|
|-lt|小于|
|-gt|大于|

校验字符串是否相等
```
str1 = "str1"
str2 = "str1"

if ${str1} = ${str2}
then
echo "equals"
else
echo "not equals"
fi

```

|运算符|含义|
|:--:|:--|
|=|相等|
|!=|不相等|
|-z|字符串长度伪则为真，即字符串存在则为真|
|-n|字符串长度不伪则为真|

校验文件
```
if test -e senninha.md
# if + test + 判断符号 + 文件名
```

|运算符|含义|
|:--:|:--|
|-e|文件存在|
|-r|文件可读|
|-w|文件可写|
|-x|文件可执行|
|-d|存在且为目录|
|-f|存在且为普通文件|

#####12.for循环
for 遍历储存的变量 in 被遍历的对象
do
echo ${遍历储存的变量}
done

```
for str in 1 2 3 4 5
do 
echo ${str}
done
#将会输出1 换行2 。。。
```

如果给1,2,3,4,5加双引号，将会看成是一个整体
```
for loop in "1 2 3 4 5" senninha
do
echo "the value is ${loop}"
done

```
> 
the value is 1 2 3 4 5
the value is senninha


循环输出文件名
显示主目录下以 .bash 开头的文件：
```
for FILE in $HOME/.bash*
do
   echo $FILE
done
```

遍历数组：
如果要使用数组，声明改成：
```
#!/bin/bash
array=(1 2 3)
for tem in ${array[*]}
do
echo ${tem}
done
```
#####13.函数
> 函数可以让我们将一个复杂功能划分成若干模块，让程序结构更加清晰，代码重复利用率更高。像其他编程语言一样，Shell 也支持函数。Shell 函数必须先定义后使用。

```
function 函数名(){
	xxxx
	return 0
	#返回值只能是整数，默认是返回0
}
函数名 #调用函数不需要加()
returnValue=$? #调用完函数后使用这个语句可以将函数返回值存入变量里
```
如果你希望直接从终端调用函数，可以将函数定义在主目录下的 .profile 文件，这样每次登录后，在命令提示符后面输入函数名字就可以立即调用。
添加后想删除某个函数，unset -f f
