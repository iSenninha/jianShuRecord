### SocketChannel学习

> Nio的优势如下：
>
> If you need to manage thousands of open connections simultanously, which each only send a little data, for instance a chat server, implementing the server in NIO is probably an advantage. Similarly, if you need to keep a lot of open connections to other computers, e.g. in a P2P network, using a single thread to manage all of your outbound connections might be an advantage. This one thread, multiple connections design is illustrated in this diagram.
>
> Nio用于多个长连接，并且每个连接的数据量都不大的情况下，通过非阻塞的方式，一个线程可以管理多个连接。核心类包括**SocketChannel**，**Selector**，**Buffer**(主要是**ByteBuffer**)

- SocketChannel

  > Document from oracle:
  >
  > A channel represents an open connection to an entity such as a hardware device, a file, a network socket, or a program component that is capable of performing one or more distinct I/O operations, for example reading or writing.
  >
  > 代表一个开放的连接，这个连接可以**双向**读写，不像Stream一样是单向的。

- Selector

  > ​	A selector may be created by invoking the [`open`](https://docs.oracle.com/javase/7/docs/api/java/nio/channels/Selector.html#open()) method of this class, which will use the system's default [``selector provider``](https://docs.oracle.com/javase/7/docs/api/java/nio/channels/spi/SelectorProvider.html) to create a new selector. A selector may also be created by invoking the [`openSelector`](https://docs.oracle.com/javase/7/docs/api/java/nio/channels/spi/SelectorProvider.html#openSelector()) method of a custom selector provider. A selector remains open until it is closed via its [`close`](https://docs.oracle.com/javase/7/docs/api/java/nio/channels/Selector.html#close()) method.
  >
  > 调用本类的open()方法将会默认打开系统提供的多路选择器，selector的作用是管理多个channel连接。下面的是结合SocketChannel的代码解析

  ```
              int port = 8888;
              int capacity = 1024;
              ServerSocketChannel server = null;
              Selector selector = null;
  			server = ServerSocketChannel.open();//打开ServerSocketChannel
  			server.configureBlocking(false);//要用多路选择器管理的话，必须使用非阻塞模式
  			selector = Selector.open();//打开多路选择器
  			server.register(selector, SelectionKey.OP_ACCEPT);//注册ServerSocketChannel为对accept事件感兴趣//见下面解析1
  			server.bind(new InetSocketAddress(port));//绑定监听端口
  			selector.select();//见下面解析2
  			Iterator<SelectionKey> iterator = selector.selectedKeys().iterator();
  ```

  ​	解析1：

  ​		注册感兴趣的事件是的类型通过SelectionKey，每个不同的事件其实是这样的：

  ```
      public static final int OP_ACCEPT = 1 << 4;
      ....
      
  ```

  ​		应该猜到了，采用高低位的方式，一个int型就可以储存四种事件，accept,read,write,connect。所以设置感兴趣的事件的时候，可以采用 **| 与**的方式。

  ​	解析2：

  ​		先来看**select()**api说明:

  > Selects a set of keys whose corresponding channels are ready for I/O operations.
  >
  > This method performs a blocking [selection operation](#selop). It returns only after at least one channel is selected, this selector's `wakeup` method is invoked, or the current thread is interrupted, whichever comes first.
  >
  > 选择准备好进行io事件的通信通道，并且这是一个阻塞的方法，这个方法会在满足下列任意一个条件的时候返回:1.有一个通道准备好了;2wakeup方法被调用了;3.当前线程被中断。

- 接受连接并操作并注册

```
			while (true) {
				while (iterator.hasNext()) {
					SelectionKey key = iterator.next();
					if (key.isAcceptable()) {
						SocketChannel channel = server.accept();
						channel.configureBlocking(false);
						System.out.println("连接：" + channel.getRemoteAddress().toString());
						channel.register(selector, SelectionKey.OP_READ | SelectionKey.OP_CONNECT);
					} else {
						if (key.isReadable()) {//状态为可读取的时候，进入读取
							SocketChannel channel = (SocketChannel) key.channel();
							ByteBuffer buf = (ByteBuffer) key.attachment();
							if (buf == null) {
								buf = ByteBuffer.allocate(capacity);
								key.attach(buf);
							}

							int len = -1;
							while ((len = channel.read(buf)) != 0 && len != -1) {
								System.out.print(
										"收到[" + channel.getRemoteAddress() + "]:" + new String(buf.array(), 0, len));
								buf.flip();
								channel.write(buf);
								buf.clear();
							}

							if(len == -1) {//读取的为1的时候，关闭通道，关闭的同时，也从selector里移除了注册
								System.out.println("disconnect:" + channel.getRemoteAddress());
								channel.close();
								continue;
							}
							System.out.print("\n----------------\n");
						}
						
						if(key.isConnectable()) {
							System.out.println("is connectable");
						}
					}

					iterator.remove();
				}
				if (selector.select() > 0) {
					iterator = selector.selectedKeys().iterator();
				}
			}
```



总结

> 整个程序基本就是这样了，客户端使用的是**netcat**测试，测试过程中发现有趣的地方：
>
> 1.直接ctrl + z终止程序，服务端不能获取到任何的反馈，反而是关掉终端，反而会触发read事件，只是这个时候读入的是-1，所以以上程序在这里是用-1代表连接断掉。所以检测断掉连接还是用心跳比较靠谱。
>
> 2.selector是线程安全的，所以可以考虑多个线程取管理连接，同时，debug的状态下，发现select()方法是立即返回的，比较奇怪。(线程安全：Selectors are themselves safe for use by multiple concurrent threads; their key sets, however, are not.
>
> 3.业务处理可以从selector里去分发给其他的线程去处理。

完整代码，监听8888端口：



```
/**
 * 
 * @author senninha
 *
 */
public class SocketChannelTest {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		startServer();
	}

	public static void startServer() {
		int port = 8888;
		int capacity = 1024;
		ServerSocketChannel server = null;
		Selector selector = null;
		try {
			server = ServerSocketChannel.open();
			server.configureBlocking(false);
			selector = Selector.open();
			server.register(selector, SelectionKey.OP_ACCEPT);
			server.bind(new InetSocketAddress(port));
			selector.select();
			Iterator<SelectionKey> iterator = selector.selectedKeys().iterator();

			while (true) {
				while (iterator.hasNext()) {
					SelectionKey key = iterator.next();
					if (key.isAcceptable()) {
						SocketChannel channel = server.accept();
						channel.configureBlocking(false);
						System.out.println("连接：" + channel.getRemoteAddress().toString());
						channel.register(selector, SelectionKey.OP_READ | SelectionKey.OP_CONNECT);
					} else {
						if (key.isReadable()) {
							SocketChannel channel = (SocketChannel) key.channel();
							ByteBuffer buf = (ByteBuffer) key.attachment();
							if (buf == null) {
								buf = ByteBuffer.allocate(capacity);
								key.attach(buf);
							}

							int len = -1;
							while ((len = channel.read(buf)) != 0 && len != -1) {
								System.out.print(
										"收到[" + channel.getRemoteAddress() + "]:" + new String(buf.array(), 0, len));
								buf.flip();
								channel.write(buf);
								buf.clear();
							}

							if(len == -1) {
								System.out.println("disconnect:" + channel.getRemoteAddress());
								channel.close();
								continue;
							}
							System.out.print("\n----------------\n");
						}
						
						if(key.isConnectable()) {
							System.out.println("is connectable");
						}
					}

					iterator.remove();
				}
				if (selector.select() > 0) {
					iterator = selector.selectedKeys().iterator();
				}
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {

			try {
				if (server != null && server.isOpen())
					server.close();

				if (selector != null && selector.isOpen())
					selector.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}

}

```

