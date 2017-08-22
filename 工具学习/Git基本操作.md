###Git基本操作

git config --global user.name "senninha"
git config --global user.email "senninha@163.com"

git init
	将某个目录变成git管理的仓库

git add file.xxx
	添加某个file

git status
	察看当前状态，是否有未提交的仓库

git diff
	若当前状态被修改过，用这个命令可以看不同

git commit -m "提交信息"
	提交更改到仓库

git log 
	察看提交，加入--pretty=oneline 可以察看提交的其他数据。

git reset --hard HEAD^
	表示回退到上一个版本，～xx回退到上几个版本

git reset --hard commitId
	如果回退版本后又后悔了，可以通过commitId再回到某个版本。

git reflog 
	可以察看每一次提交历史

cat xxx.txt
	可以察看文件内容，并用vi修改。

只有提交到暂存区（status）的修改才会被commit，
	git diff head -- read.txt 上面表示的是仓库里的信息，有+ -符号的是工作空间与仓库信息的差别。

git checkout -- readme.txt
	将工作区的文件恢复到最近commit或者add到暂存区的状态。(按先恢复暂存区，再到工作区的顺序，撤销暂存区状态间下一条命令)

git reset head -- readme.txt 
	撤销在暂存区的add

当工作区删除了一个文件的时候，git status可是看到是删除了一个文件
	如果是确实要删除的，用git rm tt.xx　即可把删除仓库里的文件删除掉。
	如果是误删除，可以用git checkout tt.xx 恢复工作区里的文件。

ssh keygen -t rsa -C "senninha@163.com" 
	生成公匙私匙

git remote add orign git@github.com:iSenninha@git.git
	添加本地仓库与远程仓库关联，这里的orign可以自己设置别名，git@xx是指远程仓库的ssh地址。在此之前要先添加ssh公匙。

git remote remove orign 
	解除上述建立的关联

git push -u orign master
	将本地仓库推送到远程仓库，第一次推送增加-u参数，表示把本地的master与远程的master关联，第二次推送可以简化参数不用写-u
	第一个orign是远程仓库的名字，master是对应的分支名

git clone 地址，可以克隆远程仓库。

git branch new_branch_name
	创建新分支

git branch 
	可以查看所有的分支，当前分支以星号显示

git checkout branch_name
	切换分支，这里的checkout与恢复工作区的文件的区别是恢复工作区有--+

git mearge branch_name
	当前分支与branch_name分支合并

git branch -d branch_name
	删除分支

git branch -D branch_never_be_merged
	强行删除没有被融合过的分支

git checkout -b branchname
	建立新分支并且切换到该新分支
	切换分支时会自动把工作空间同步成当前的仓库。

git log --graph
	可以察看分支的合并等信息。

git merge --no-ff -m "merge with no-ff" dev
	不使用fast forward来融合。这样会产生一个新的commit。所以需要一个-m

git stash 
	当前工作未完成，但是要紧急修复一个bug时候，可把当前工作区隐藏起来

git stash list
	把所有隐藏的工作区展示出来

git stash apply	
	恢复工作区
	这样的话不会删除隐藏的工作区，需要git stash drop来删除

git stash pop
	堆栈的思想，恢复工作区，同时删除隐藏的工作区

git stash apply stash@{0}
	有多次git stash时可选择

git remote 
	可以察看关联的远程数据库

git remote —v
	可以察看详细信息。

协同开发的时候：
	首先使用
		git push origin branch-name 推送自己的修改
			这里的origin是远程仓库的名和远程仓库的分支名
	如果推送失败，说明远程分支本本地更新，先用git pull试图合并
		如果git pull失败，说明本地分分支和远程分支的连接关系没有创建
		git branch --set-upstream branch-name oringin/branch-name.
	如果合并有冲突，解决冲突，并commit。

标签
	git tag tagname.命名一个快照，将这个tag放在最新的那个commit上

	git tag -d tagname 删除本地的tag

	git tag 可以查看所有的tag

	git show tagname 察看某个版本

	git push origin tagname 推送本地标签到远程仓库

	git puth origin --tags 一次性推送全部尚未推送到远程的本地标签

	git puth origin :refs/tags/tagname 删除远程仓库的标签。

自定义git
	编辑.gitignore文件

	设置别名
	git config --global alias.st "status" 用st来表示工作区状态。

linux下git status无法显示utf-8
	git config --global core.quotepath false
