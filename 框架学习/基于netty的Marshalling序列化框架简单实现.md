##Marshalling序列化框架简单实现

###1.导入相关jar包
    maven项目直接添加依赖即可。
```
		<!-- MarshAlling dependency -->
		<dependency>
			<groupId>org.jboss.marshalling</groupId>
			<artifactId>jboss-marshalling-osgi</artifactId>
			<version>2.0.0.Beta5</version>
		</dependency>
```

###2.创建序列化传输的类
```
//记得要实现Serializable接口
public class UserInfo implements Serializable {
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
	@Override
	public String toString() {
		return "UserInfo [username=" + username + ", age=" + age + "]";
	}
	
	
	
	
}

```

###3.编写创建MarshallingEncoder和MarshallingDecoder的工厂类
```
public class MarshallingCodeFactory {
	public static MarshallingEncoder getEncoder(){
	//这里表示的是支持java serial对象的序列化。所以我们传输的对象要实现Serializable接口
		MarshallerFactory factory = Marshalling.getProvidedMarshallerFactory("serial");
		MarshallingConfiguration configuration = new MarshallingConfiguration();
		configuration.setVersion(5);
		MarshallerProvider provider = new DefaultMarshallerProvider(factory, configuration);
		MarshallingEncoder encoder = new MarshallingEncoder(provider);
		return encoder;
	}
	
	public static MarshallingDecoder getDecoder(){
		MarshallerFactory factory = Marshalling.getProvidedMarshallerFactory("serial");
		MarshallingConfiguration configuration = new MarshallingConfiguration();
		configuration.setVersion(5);
		UnmarshallerProvider provider = new DefaultUnmarshallerProvider(factory, configuration);
		MarshallingDecoder decoder = new MarshallingDecoder(provider);
		return decoder;
	}
```

###4.Server端
```
package cn.senninha.concurrent.server;

import cn.senninha.concurrent.code.MarshallingCodeFactory;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelOption;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.codec.marshalling.MarshallingDecoder;
import io.netty.handler.codec.marshalling.MarshallingEncoder;

public class TimeServerMarshalling {
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
			//这里添加marshalling的序列化支持
			MarshallingEncoder encoder = MarshallingCodeFactory.getEncoder();
			MarshallingDecoder decoder = MarshallingCodeFactory.getDecoder();
			ch.pipeline().addLast(encoder);
			ch.pipeline().addLast(decoder);
			ch.pipeline().addLast(new TimeServerHandler());
		}
	}

	public static void main(String[] args) {
		int port = 12580;
		try {
			new TimeServerMarshalling().bind(port);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}

```
对应的serverhanlder：

```
package cn.senninha.concurrent.server;

import java.nio.ByteBuffer;

import org.msgpack.MessagePack;
import org.omg.Messaging.SyncScopeHelper;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandlerAdapter;
import io.netty.channel.ChannelHandlerContext;

public class TimeServerHandler extends ChannelHandlerAdapter {

	@Override
	public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
		// TODO Auto-generated method stub
//		ByteBuf in = (ByteBuf) msg;
		try {
			System.out.println(msg);
			String remsg = new String("has receive");
			ctx.write(remsg);
			ctx.flush();
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

###5.Client端
```
package cn.senninha.concurrent.client;

import java.net.UnknownHostException;

import cn.senninha.concurrent.code.MarshallingCodeFactory;
import io.netty.bootstrap.Bootstrap;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelOption;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.handler.codec.marshalling.MarshallingDecoder;
import io.netty.handler.codec.marshalling.MarshallingEncoder;

public class NettyClientMarshalling {

	
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
	
	private class ClientHandlerInit extends ChannelInitializer<SocketChannel>{

		@Override
		protected void initChannel(SocketChannel ch) throws Exception {
			// TODO Auto-generated method stub
			//添加对marshalling框架的支持
			MarshallingEncoder encoder = MarshallingCodeFactory.getEncoder();
			MarshallingDecoder decoder = MarshallingCodeFactory.getDecoder();
			ch.pipeline().addLast(encoder);
			ch.pipeline().addLast(decoder);
			ch.pipeline().addLast(new ClientHandler());
		}
		
	}

	public static void main(String[] args) throws UnknownHostException {
		// TODO Auto-generated method stub
		NettyClientMarshalling client = new NettyClientMarshalling();
		client.bind(12580,"localhost");
	}

}
```

对应的clienthandler代码：
```
package cn.senninha.concurrent.client;

import cn.senninha.concurrent.code.model.UserInfo;
import io.netty.channel.ChannelHandlerAdapter;
import io.netty.channel.ChannelHandlerContext;
import javassist.bytecode.ByteArray;

public class ClientHandler extends ChannelHandlerAdapter {
	private byte[] request = ("senninha" + System.getProperty("line.separator")).getBytes();

	@Override
	public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
		// TODO Auto-generated method stub
		System.out.println(msg);
	}

	@Override
	public void channelActive(ChannelHandlerContext ctx) throws Exception {
		// TODO Auto-generated method stub
		for (int i = 0; i < 500; i++) {
			UserInfo userInfo = new UserInfo();
			userInfo.setAge(i + "year");
			userInfo.setUsername("senninha");
			ctx.write(userInfo);
			ctx.flush();
		}
		System.out.println("-----------------send over-----------------");
	}

	@Override
	public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
		// TODO Auto-generated method stub
		System.out.println("error");
	}
}

```
###6.运行
```
UserInfo [username=senninha, age=0year]
UserInfo [username=senninha, age=1year]
UserInfo [username=senninha, age=2year]
UserInfo [username=senninha, age=3year]
UserInfo [username=senninha, age=4year]
```
参考《netty权威指南》
