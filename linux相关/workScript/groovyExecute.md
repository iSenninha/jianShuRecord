### groovy调用系统命令执行多参数脚本的坑
> 尝试用groovy写脚本调用shell脚本，然后发现有一个脚本调用总是有问题，但是用py调是没问题的

#### groovy调用代码
```
	commnad = "query 0 1 \"select count(*) from user\"
	result = command.execute(command)
	println result
```
ps:query是封装了mysql命令的简单shell脚本,传递几个命令进去查询不同版本的线上库，后面双引号包裹的是执行的**sql**命令。
执行这个groovy脚本，不管怎么弄返回值都是空。相同的命令在py上调用是完全正常的。


#### query脚本里打出完整命令和参数
于是在query脚本里echo出命令，发现传入的参数是:
```
	0 1 "select count(*) from user"
```
参数命令个数是:6个,这就明显不对了。

对比py执行的时候的打印:
```
	0 1 select count(*) from user
```
命令参数是:3个

很明显，是groovy执行的脚本的时候，把"号给做了转义，这就坑了。

#### 解决办法
google了一下[google](https://stackoverrun.com/cn/q/6505134)
多命令可以用数组，然后直接用数组执行execute(),如下:
```
 command = ["query", "0", "1", "select count(*) from user"]
 proc = command.execute()
 print proc.text
```
完美解决。
