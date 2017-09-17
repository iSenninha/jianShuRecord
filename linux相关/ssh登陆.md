### ssh登陆

- 首先是生成密钥

> ssh-keygen
>
> 没有特殊要求的话就一路enter即可
>
> 然后在~./ssh/目录下会生成一个密钥对（公钥-私钥）

- 使用ssh配置git

> 将公钥的内容复制，然后放到对应的的Github或者其他的地方去配置，然后就可以免密码操作git啦



- 配置ssh登陆远程linux服务器

> 1. 将公钥上传到远程~/.ssh/上
>
> 2. 然后cat ~/.ssh/id_rsa >> authorized_keys
>
> 3. 设置权限 chmod 600 authorized_keys
>
> 4. vi /etc/ssh/sshd_config
>
>    ```
>    RSAAuthentication yes
>    PubkeyAuthentication yes
>    AuthorizedKeysFile      %h/.ssh/authorized_keys
>    ```
>
> 5. 重启ssh服务 
>
>    ```
>    service sshd restart
>    ```
>
>    ​