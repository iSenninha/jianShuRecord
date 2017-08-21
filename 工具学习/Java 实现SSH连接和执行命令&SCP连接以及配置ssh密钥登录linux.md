### Java 实现SSH连接和执行命令&SCP连接

> 部署热更的时候需要调用对应的远程服务器的环境去编译热更代码，由于开发内网pc是windows，只能采用第三方java实现的SSH工具去实现调用。

- JSch 实现SSH连接

  1.首先依赖jar包

```java
		<dependency>
			<groupId>com.jcraft</groupId>
			<artifactId>jsch</artifactId>
			<version>0.1.53</version>
		</dependency>
		
```

​	2.SSH连接

```
		JSch jsch = new JSch();
		Session session = jsch.getSession(user, host, port);
		session.setConfig("StrictHostKeyChecking", "no");
		/**
		*如果是用证书登录的话，在这里指定证书即可
		*jsch.addIdentity("/root/.ssh/id_rsa");
		*/
		session.setPassword(password);
		session.connect();
		ChannelExec channelExec = (ChannelExec) session.openChannel("exec");
	//有一个坑就是，编译java文件的时候，如果输出错误，我那边的环境竟然要channelExec.getErrorStream()才能看到出错的信息。
		InputStream in = channelExec.getInputStream();
		channelExec.setCommand(command);
		channelExec.setErrStream(System.err);
		channelExec.connect();

		byte[] b = new byte[1024];
		int len = in.read(b);
		StringBuilder sb = new StringBuilder();
		while (len != -1) {
			sb.append(new String(b, 0, len, "utf-8"));
			len = in.read(b);
		}

		channelExec.disconnect();
		session.disconnect();

		return sb.toString();
```

​	3.JSch的方式实现SFTP连接

```
JSch jsch = new JSch();
Session session = null;
try{
  session = jsch.getSession(username, host, 900);
  session.setPassword(password);//证书登录参考上面
  ChannelSftp sftp = (ChannelSftp) session.openChannel("sftp");
  ch.connect();
  sftp.put(localFile, remoteFileDirectory);
}catch(Exception e){
  e.printStackTrace();
}finally{
  if(session != null){
  session.close();
  }
}
```



- 使用ganymed实现scp上传文件

  1.依赖

  ```
  <dependency>
  			<groupId>ch.ethz.ganymed</groupId>
  			<artifactId>ganymed-ssh2</artifactId>
  			<version>build210</version>
  		</dependency>
  ```

  2.代码

  ```
  		Connection connection = new Connection(host);
  		connection.connect();
  		connection.authenticateWithPassword(user, password);
  		//connection.authenticateWithPublicKey(username, new File("/root/.ssh/id_rsa")), null);证书登录用这行代码替代
  		try {
  			SCPClient scpClient = connection.createSCPClient();
  			scpClient.put(localFile, remoteTargetDirectory);
  		} catch (Exception ex) {
  			ex.printStackTrace();
  		} finally {
  			connection.close();
  		}
  ```



- 其他

```
证书一般存在/root/.ssh/目录下
可能需要设置证书权限 chmod 600 /root/.ssh/对应密钥

生成ssh密钥
key-keygen
一路往下，然后默认在~/.ssh/id_rsa  ~/.ssh/id_rsa.pub(公钥)
将公钥放在github上，就可以用ssh免密码来push了
放在

linux上，这个位置配置了当前机子的密钥配置
/etc/ssh/ssh_config
```

