### Vim配置类IDE环境
#### 1.安装依赖&升级vim版本
- apt-get install python-dev
- apt-get install build-essential
- apt-get install vim-nox


#### 2.配置文件
[配置文件](./.vim.rc)


#### 3.安装Vundle管理插件
```
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```
安装好这个插件后就可以自动下载管理插件了。

#### 4.安装YouCompleteMe
- clone插件
```
git clone https://github.com/Valloric/YouCompleteMe.git ~/.vim/bundle/
```

- 安装
```
cd ~/.vim/buldel/YouCompleteMe
./install.py
```

- 安装完毕后，打开vi，输入
```
:PluginInstall
```
显示done的时候就全部ok了。
