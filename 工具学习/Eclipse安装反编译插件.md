### Eclipse安装反编译插件

- 插件准备

  [云盘下载linux版本](https://pan.baidu.com/s/1nuGtB3z)

  有两个文件，一个是jar包，另外一个是jad无格式文件放到一个不会被删除的路径。



- 安装

  把jar包放到**eclipse/plugins/**下

  **删除**eclipse/configuration/org.eclipse.update/文件夹



- 配置

  重启eclipse，

  Window-->Preference-->Java-->JadClipse（新安装的插件）-->配置Path to decompiler为那个无格式文件**jad**的路径-->apply

  Window-->Preference-->General-->editor-->File association-->.class设置为默认用JadClipse打开-->.class without source也设置为默认用JadClipse打开(这个可能要在下面手动添加，然后设置未**default**)-->apply



- 搞定。