###Git基本操作

- 基本概念：
```
git add 
	操作把文件添加到**暂存区**;
git commit 
	把暂存区的文件提交到**当前分支**;
	而文件夹中修改后未经过上面操作的就是**工作区**
```	

- 设置基本信息
```
git config --global user.name "senninha"
git config --global user.email "senninha@163.com"
```

-

- 添加修改恢复文件相关
```
还原工作区的更改
	git checkout -- <fileName>
	按 暂存区> 版本库 的顺序恢复，即，回复到最近一次add or commit的文件状态
	如果误删了，也可以用这个命令回复该文件
	
回复暂存区的数据到工作区
	git reset HEAD <fileName>
	即是丢弃暂存区的此次修改，回退到工作区
	
只添加已经提交过的文件到索引
	git add -u
	意思就是不添加新增的文件到索引
	
删除版本库中的某个文件
	git rm t.txt
	等于这两步操作：
	rm t.txt 
	git add t.txt
```
- 回退版本
```
以上的是对文件的修改，这个是对一次commit的回复
	git reset --hard HEAD^
	回退到上一个版本，是整个git库回退
	把HEAD^替换为版本号就可以退到制定版本库了
	
那么怎么看版本库呢？
	git log --pretty=oneline
	加上后面的参数可以界面更友好
	git reflog 
	这个可以看每次操作日志
	只许前几位版本号就可以定位到哪个版本

```

- 分支相关
```
新建分支名字
	git branch <newBranchName>
	
切换分支名字
	git checkout <branchName>
	这个命令和回退某个文件的命令就差了 -- 

展示所有分支
	git branch

删除分支
	git branch -d <branchName>
	git branch -D <branchName>
	后者是强制删除未融合过的分支
	
分支融合
	git checkout master
	git merge <branchName>
	这就是把<branchName>融合到master分支
	
创建并切换分支
	git checkout -b <newBranchName>
```

- 隐藏工作空间
```
这个功能的使用场景是，开发着A功能，接到了紧急的B功能，A功能开发到了一半，无法提交A功能的工作，这个时候，可以用
	git stash
隐藏工作区，等到工作完成后：
	git stash pop
弹出工作区。这一步等于：
	git stash apply （可以加指定的那个版本）
	git stash drop 弄出来+删除
也可以用查看stash list的内容：
	git stash list 
```

- 远程相关
```
关联远程仓库
	git remote add origin <git的地址>
	origin是约定俗成的
	
推送到远程仓库
	git push -u origin master
	-u表示把origin master与当前的分支关联起来，第二次推送的时候就不用加了
	
删除远程仓库
	git remote remove <remoteName>
	这里的<remoteName>即上面的origin
	
查看远程仓库
	git branch -a
	就是查看所有分支
	
推送远程分支
	git push <origin> <branchName>
	
拉取远程分支
	git checkout -b <本地分支名> <远程仓库名/远程分支名>
	之所以我们直接clone下来就能使用，是因为默认帮我们在本地建立了master分支去跟踪远程的master分支
	
删除远程分支
	git push origin :远程分支名
	origin后要空一格 加:加分支名
```

- 标签
```
打标签
	git tag <tagName>
	git tag <commitId> <tagName>
	加标签到对应的版本上

列出标签
	git tag
	
展示标签信息
	git show tagName
	
推送远程标签
	git push origin tagName
	
删除远程标签
	git push origin :refs/tags/1.0
```

- 一些问题
```
linux下git status无法显示utf-8
	git config --global core.quotepath false
	

```