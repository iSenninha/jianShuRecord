### mybatis的类扫描工具
之前自己写过一个类扫描工具，但是总是会出现一些考虑不周而出现的问题：
1.开发机是Debian，在Windows上跑分隔符没考虑;
2.Ide环境下没问题，但是在打成jar包部署的时候出问题;
3.不同的部署环境下又有问题,比如打成springboot的包的时候的方式不一样。。

所以这个时候，应该去参考成熟的框架是如何做类扫描的，这里就拿mybatis举例子。

这里的Mybatis是3.4.5，类扫描主要是实现在**DefaultVFS**这个类里，对照了公司用的3.0.6版本，类扫描的实现是在**ResolverUtil**里。

####1.使用方法
使用方法非常之简单：
```
        ResolverUtil util = new ResolverUtil();
        util.find(new ResolverUtil.Test() {
            @Override
            public boolean matches(Class<?> type) {
                System.out.println(type.getCanonicalName());
                return true;
            }
        }, "cn.senninha");
	Set<Class> set = util.getClasses();
```
实现Test()接口，过滤指定包名下需要的类,这里是默认全部返回true，然后set里就可以获取到所有在**cn.senninha**包名下的类
