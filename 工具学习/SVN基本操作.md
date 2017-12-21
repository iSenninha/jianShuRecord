###SVN基本操作
> svn也是一个版本管理的工具，区别与git的重要一点是他不是分布式的，所以呢，没有网的情况下，就没办法commit了

####检出操作-checkout
首先要把项目**checkout**出来
```
svn checkout xxx
```

####添加-add
svn的add比较恶心，有时要借助简单的脚本来达到一次性提交多个更改过的文件
```
svn add xxx xxx.file
svn rm xxx
```

####对比差异
```
svn diff
```

####提交
```
svn commit -m ""
```
和git没什么差别

####处理冲突
出差冲突完毕后，输入以下消除冲突状态：
```
svn resolve main.py --accept working
```

####版本回滚
这个才是坠重要的。。先假设一个场景吧：
> 有a-b-c三个版本，当前在c版本。

- 清除工作空间
我在c版本的基础上更改了一些文件，比如改了**2b.2b**这个文件，我想回滚回版本c：
```
svn revert 2b.2b
```

如果我要把所有文件都回滚回c版本呢？
```
svn revert -R 当前目录
```

- review某个版本的代码
```
svn update -r 版本号
```
这个命令只是切换当前的工作空间到对应的版本号，这个时候是无法提交的，如果要提交，要切换到最新的版本后再提交

- 回退到任意版本，可提交
```
svn merge -r 当前版本:历史版本 要回滚的文件夹地址。
```
然后就会发现工作空间变成了历史版本,这个时候可以再次进行提交等操作。
然后运行：
```
svn revert -R ./
```
又可以清除当前这个回滚操作，如果你不想回滚就提交吧。。闷声作大死。。。

与此同时，比如我们当前在f版本，我只想清除c版本的提交，该怎么做呢，就是精确回滚c版本对版本库的影响。
可以通过脚本的方式，只回滚c操作更改过的代码。


####获取帮助
```
svn help
//获取所有的svn命令
svn help xxx命令
```

####一些操作
- 纯打包，不download svn配置文件
```
svn export url
```

- 获取工作空间的信息
```
svn info [url]
//如果url绑定了的话就不用了
```

- 查看某个文件的版本信息，不下载到本地
```
svn list x.file
```
列出列表后可以用这个查看
```
svn cat x.file
```

- 查看某个文件的log信息
```
svn log xx.xx
```

- 查看某两次提交的文件差异
```
svn diff --summarize -r 493:492
```
加入--summarize之输出造成差异的文件，而不是输出详细--


ps:[使用说明网站](http://riaoo.com/subpages/svn_cmd_reference.html)
