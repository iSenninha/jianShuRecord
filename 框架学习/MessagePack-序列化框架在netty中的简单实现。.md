##MessagePack 序列化框架的简单实现。


###1.导入相关jar包
     如果使用maven的话，直接添加依赖即可：
```
		<properties>
			<msgpack.version>0.6.12</msgpack.version>
		</properties>

		<!-- MessagePack dependency -->
		<dependency>
			<groupId>org.msgpack</groupId>
			<artifactId>msgpack</artifactId>
			<version>${msgpack.version}</version>
		</dependency>
```
     如果是普通java项目，去[maven中央仓库](https://search.maven.org/#search%7Cga%7C1%7Cg%3A%22ch.dissem.msgpack%22)下载即可

###2.编写Encoder(编码器)
     继承MessageToByteEncoder
```
public class MsgpackEncoder extends MessageToByteEncoder {

	@Override
	protected void encode(ChannelHandlerContext ctx, Object msg, ByteBuf out) throws Exception {
		// TODO Auto-generated method stub
		MessagePack msgpack = new MessagePack();
		out.writeBytes(msgpack.write(msg));
	}

}
```

###3.编写Decoder(编码器)
     继承MessageToMessageDecoder，设置类型为ByteBuf
```
public class MsgpackDecoder extends MessageToMessageDecoder<ByteBuf> {

	@Override
	protected void decode(ChannelHandlerContext ctx, ByteBuf msg, List<Object> out) throws Exception {
		// TODO Auto-generated method stub
		final int length = msg.readableBytes();
		byte[] b = new byte[length];
		msg.getBytes(msg.readerIndex(), b,0,length);
		MessagePack msgpack = new MessagePack();
		out.add(msgpack.read(b));
	}

}
```

###4.在Client端和Server端增加编码器和解码器，顺便增加粘包/拆包支持：
     客户端代码：
```
public class NettyClient {

	
	private void bind(int port,String host){
		EventLoopGroup group = new NioEventLoopGroup();
		Bootstrap b = new Bootstrap();
		b.group(group).channel(NioSocketChannel.class)
		.option(ChannelOption.TCP_NODELAY, true).handler(new ClientHandlerInit());
		
		try {
			ChannelFuture f = b.connect(host, port).sync();
			f.channel().closeFuture().sync();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally{
			group.shutdownGracefully();
		}
		
		
		
	}
	/*
	*这里是增加相应的解码编码器。
	*/
	private class ClientHandlerInit extends ChannelInitializer<SocketChannel>{

		@Override
		protected void initChannel(SocketChannel ch) throws Exception {
			// TODO Auto-generated method stub
			//这里设置通过增加包头表示报文长度来避免粘包
			ch.pipeline().addLast("frameDecoder",new LengthFieldBasedFrameDecoder(1024, 0, 2,0,2));
			//增加解码器
			ch.pipeline().addLast("msgpack decoder",new MsgpackDecoder());
			//这里设置读取报文的包头长度来避免粘包
			ch.pipeline().addLast("frameEncoder",new LengthFieldPrepender(2));
			//增加编码器
			ch.pipeline().addLast("msgpack encoder",new MsgpackEncoder());
			ch.pipeline().addLast(new ClientHandler());
		}
		
	}

	public static void main(String[] args) throws UnknownHostException {
		// TODO Auto-generated method stub
		NettyClient client = new NettyClient();
		client.bind(12580,"localhost");
	}

}
```
    Server端代码，和client端大同小异，不再赘述

```
public class TimeServer {
	public void bind(int port) throws Exception {
		EventLoopGroup bossGruop = new NioEventLoopGroup();
		EventLoopGroup workGroup = new NioEventLoopGroup();
		ServerBootstrap bootstrap = new ServerBootstrap();
		bootstrap.group(bossGruop, workGroup).channel(NioServerSocketChannel.class)
				.option(ChannelOption.SO_BACKLOG, 1024).childHandler(new ChildChannelHandler());

		try {
			ChannelFuture future = bootstrap.bind(port).sync();
			future.channel().closeFuture().sync();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			bossGruop.shutdownGracefully();
			workGroup.shutdownGracefully();
		}
	}

	private class ChildChannelHandler extends ChannelInitializer<SocketChannel> {

		@Override
		protected void initChannel(SocketChannel ch) throws Exception {
			// TODO Auto-generated method stub
			ch.pipeline().addLast("frameDecoder",new LengthFieldBasedFrameDecoder(1024, 0, 2,0,2));
			ch.pipeline().addLast("msgpack decoder",new MsgpackDecoder());
			ch.pipeline().addLast("frameEncoder",new LengthFieldPrepender(2));
			ch.pipeline().addLast("msgpack encoder",new MsgpackEncoder());
			ch.pipeline().addLast(new TimeServerHandler());
		}
	}

	public static void main(String[] args) {
		int port = 12580;
		try {
			new TimeServer().bind(port);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
```
###5.接下来自定义一个model类来实作为消息类：
```
/*
*这里出现了两个坑，一个是需要在消息类上加上注解Message，另一个就是必须要有默认的无参构造器，不然就会报如下的错误：
*org.msgpack.template.builder.BuildContext build
*SEVERE: builder: 这个问题在github上有个issue解释了
*/

@Message
public class UserInfo {
	private String username;
	private String age;
	public String getUsername() {
		return username;
	}
	public String getAge() {
		return age;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public void setAge(String age) {
		this.age = age;
	}
	public UserInfo(String username, String age) {
		super();
		this.username = username;
		this.age = age;
	}
	
	public UserInfo(){
		
	}
	
	
}
```
[github关于错误的issue](https://github.com/msgpack/msgpack-java/issues/226)

###6.对应的ServerHandler和ClientHandler代码：
serverhandler：
```
public class TimeServerHandler extends ChannelHandlerAdapter {

	@Override
	public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
		// TODO Auto-generated method stub
		try {
		//直接输出msg
			System.out.println(msg.toString());
			String remsg = new String("has receive");
		//回复has receive 给客户端
			ctx.write(remsg);
		} catch (Exception e) {
			e.printStackTrace();
		}finally {
		}
	}

	@Override
	public void channelReadComplete(ChannelHandlerContext ctx) throws Exception {
		// TODO Auto-generated method stub
		ctx.flush();
	}
}

```
clientHanlder：
```
public class ClientHandler extends ChannelHandlerAdapter {

	@Override
	public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
		// TODO Auto-generated method stub
		System.out.println(msg);
	}

	@Override
	public void channelActive(ChannelHandlerContext ctx) throws Exception {
		// TODO Auto-generated method stub
		//发送50个UserInfo给服务器，由于启用了粘包/拆包支持，所以这里连续发送多个也不会出现粘包的现象。
		for (int i = 0; i < 50; i++) {
			UserInfo userInfo = new UserInfo();
			userInfo.setAge(i + "year");
			userInfo.setUsername("senninha");
			ctx.write(userInfo);
		}
		ctx.flush();
		System.out.println("-----------------send over-----------------");
	}

	@Override
	public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
		// TODO Auto-generated method stub
		System.out.println("error");
	}
}
```

客户端控制台：
```
-----------------send over-----------------
"has receive"
"has receive"
"has receive"
"has receive"
"has receive"
"has receive"
........
```
服务器控制台：
```
["senninha","0year"]
["senninha","1year"]
["senninha","2year"]
["senninha","3year"]
["senninha","4year"]
["senninha","5year"]
["senninha","6year"]

```

至此，一个MessagePack序列化框架的入门就搭建好了，参考了《Netty权威指南》。
