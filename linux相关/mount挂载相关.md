mount挂载相关

> 挂载磁盘有很多的应用场景，比如插入一个U盘。。

- 首先确定要挂载的磁盘是哪一个

  - less /proc/partitions

    ```shell
    major minor  #blocks  name

       8        0  488386584 sda
       8        1  125830112 sda1
       8        2          1 sda2
       8        5  181404672 sda5
       8        6   90691584 sda6
       8        7   86529024 sda7
       8        8    3926016 sda8
    ```

    可以查看所有的可用磁盘，插入前后比较就知道应该挂载哪个了

  - less /dev/disk/by-uuid/

    ```shell
    lrwxrwxrwx 1 root root 10 12月 11 09:02 000447BC000DEADE -> ../../sda6
    lrwxrwxrwx 1 root root 10 12月 11 09:02 000D6DD4000E20DA -> ../../sda5
    lrwxrwxrwx 1 root root 10 12月 11 09:02 0938cb37-1e1b-4229-a9d4-fd79c2a9920f -> ../../sda7
    lrwxrwxrwx 1 root root 10 12月 11 09:02 9e39aaea-0803-4395-85f7-2cf28fe2de22 -> ../../sda8
    lrwxrwxrwx 1 root root 10 12月 11 09:02 BA34AC0C34ABC9A9 -> ../../sda1
    ```

    这样也可以获取对应的UUID。通过UUID也可以挂载



- 挂载

  - 通过磁盘文件名挂载

    ```shell
    mouont /dev/sda1 /media/senninha/
    后一个参数是挂载点
    ```

  - 通过磁盘UUID挂载

    ```
    mount UUID="xxx" /media/senninha/
    ```



- 自动挂载

  默认只会挂载根目录，我们可以更改配置文件**/etc/fstab**来在开机的时候自动挂载磁盘

  - 按标准增加我们要挂载的磁盘UUID

  - 然后通过以下命令测试是否成功

    ```shell
    mount -a
    ```

    挂载全部磁盘，如果成功，那么下次开机的时候就会自动挂载了。

  - 如果这里出问题，下次开机出问题了，可以通过下面的方法修改

    ```shell
    mount -n -o remount,rw /
    ```



- 挂载镜像文件

  ```shell
  mount -o loop /tmp/iso文件 /tmp/iso镜像所在地/
  ```

  ​

  ​