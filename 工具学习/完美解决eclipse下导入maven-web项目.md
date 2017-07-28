很多时候项目并不是我们自己建的，有可能是直接u盘烤过来或者是git上来下来的，那么问题来了，怎么倒入为web项目呢。。这个问题一开始也困扰了很久，现在解决这个问题算是比较有心得了。

###1.导入项目
 file-->import
![倒入1.png](http://upload-images.jianshu.io/upload_images/3454506-40ad841761b2daec.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

选择文件夹所在路径finish。
然后项目里右键properties-->输入facet，勾选如图的三个选项

![导入2.png](http://upload-images.jianshu.io/upload_images/3454506-56ea4cb72e7896a8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

倒入项目基本完毕

###2.设置Maven库依赖:
项目里右键properties-->Deployment Assemt

![3.png](http://upload-images.jianshu.io/upload_images/3454506-036b0c05a58b6adf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

添加add:

![4.png](http://upload-images.jianshu.io/upload_images/3454506-682d224730012d94.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

添加maven 库:

![](http://upload-images.jianshu.io/upload_images/3454506-1f456e0fc5e2c7e4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

添加完毕后如图：

![](http://upload-images.jianshu.io/upload_images/3454506-1d0847b67d1a5307.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

finish完毕～

然后悲剧地发现项目里还报错？可能是JRE库太低的问题。。
###3.修改JRE库
Build path-->edit
![7.png](http://upload-images.jianshu.io/upload_images/3454506-3b353922d49c988d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

修改成：

![](http://upload-images.jianshu.io/upload_images/3454506-20a8e3f349f54f2b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

ok~maven update 一下，可以啦
