###vue环境搭建
> debian下vue开发环境搭建

####下载node安装包
[node](https://nodejs.org/dist/v8.9.4/node-v8.9.4-linux-x64.tar.xz)
然后解压，配置一下环境，把解压出来的**bin**目录配置到**/etc/profile**里就行了

```
npm -v 
node -v
//测试走一波
```

####安装某宝cnpm
```
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

####安装vue脚手架
```
cnpm install vue-cli -g
```

####新建项目
- 新建文件夹，进入
- vue init webpack projectName
  这一步，不用去安装router那些东西，然后初始化那里选no，就是不用npm去install，墙太强大。。
- 进入项目,**cnpm install**
- **cnpm run dev** ok，搞定
