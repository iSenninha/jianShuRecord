### docker基本操作
#### 镜像
- 搜索镜像
```
docker search kafka
```

- 拉取镜像
```
docker pull images'name
```

#### 新建一个镜像
```
docker run -d images'name myContainerName
```
docker run 有很多参数可选,直接--help可以看到:
> -a 依附上标准输入输出
> -c cpu核心数
> -d (--detach,分离)后台运行容器并打印出容器id
> -i --interactive (交互式)
> -m --memory bytes(内存限制)
> -n --name 容器的名字(后面可以用这个名字去启动停止容器)
> -p 容器端口:宿主机端口
> -P 随即映射容器端口到宿主机端口
> -t --tty 生成一个假冒的终端,常和-i搭配使用
> -v --volume list 挂载本地磁盘到容器内


#### 重新启动一个存在的镜像
```
docker start name(or hash_of_the_container)
docker stop name
```

#### 修改一个存在的镜像配置

- 查看配置
```
docker inspect docker_name
```

- 修改配置
```
1.stop the container and docker service
2.change setting /var/lib/docker/containers/[hash_of_the_container]/hostconfig.json
3.restart your docker engine
4.start the container
```

[参考sf](https://stackoverflow.com/questions/19335444/how-do-i-assign-a-port-mapping-to-an-existing-docker-container)

#### 进入查看容器运行的情况
比如我们需要查看某个服务的日志，当然可以用**docker log**命令，如果要配合gas进行分割的话，还是直接进入console环境方便(可以直接挂在日志文件到宿主机上)。
这里用到的命令是:

> docker exec
> Usage:	docker exec [OPTIONS] CONTAINER COMMAND [ARG...]

从字面意思是在容器内运行一个命令,[ARG...]就是要运行的命令，加上**-it*参数交互式和虚拟tty，就可以构造一个console环境啦:

```
docker exec -it container_name /usr/bash
```

如果容器内有其他更好的bash环境，可以用其他。
以此类推，如果容器内只是运行了一个可以交互式的服务，类似mysql的话，直接可以把/usr/bin替换成mysql啦。一样可以起到这个作用。
