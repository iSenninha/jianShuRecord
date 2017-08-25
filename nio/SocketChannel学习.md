### SocketChannel学习

> Nio的优势如下：
>
> If you need to manage thousands of open connections simultanously, which each only send a little data, for instance a chat server, implementing the server in NIO is probably an advantage. Similarly, if you need to keep a lot of open connections to other computers, e.g. in a P2P network, using a single thread to manage all of your outbound connections might be an advantage. This one thread, multiple connections design is illustrated in this diagram.
>
> 所以，I/O 多路复用的特点是通过一种机制一个进程能同时等待多个文件描述符，而这些文件描述符（套接字描述符）其中的任意一个进入读就绪状态，select()函数就可以返回。
>
> Nio用于多个长连接，并且每个连接的数据量都不大的情况下，通过非阻塞的方式，一个线程可以管理多个连接。核心类包括**SocketChannel**，**Selector**，**Buffer**(主要是**ByteBuffer**)

- SocketChannel

  > Document from oracle:
  >
  > A channel represents an open connection to an entity such as a hardware device, a file, a network socket, or a program component that is capable of performing one or more distinct I/O operations, for example reading or writing.
  >
  > 代表一个开放的连接，这个连接可以**双向**读写，不像Stream一样是单向的。

- Selector

  > ​	A selector may be created by invoking the [`open`](https://docs.oracle.com/javase/7/docs/api/java/nio/channels/Selector.html#open()) method of this class, which will use the system's default [``selector provider``](https://docs.oracle.com/javase/7/docs/api/java/nio/channels/spi/SelectorProvider.html) to create a new selector. A selector may also be created by invoking the [`openSelector`](https://docs.oracle.com/javase/7/docs/api/java/nio/channels/spi/SelectorProvider.html#openSelector()) method of a custom selector provider. A selector remains open until it is closed via its [`close`](https://docs.oracle.com/javase/7/docs/api/java/nio/channels/Selector.html#close()) method
  >
  > 调用本类的open()方法将会默认打开系统提供的多路选择器.

  ​	之所以可以做到非阻塞，就是因为采用了seletor，也就是io复用模型：

  > IO多路复用是指内核一旦发现进程指定的一个或者多个IO条件准备读取，它就通知该进程。
  >
  > 主要的io复用方式有如下：**select**,**poll**,**epoll**
  >
  > 效率比较高，并且没有文件描述符限制的是epoll：
  >
  > epoll是在2.6内核中提出的，是之前的select和poll的增强版本。相对于select和poll来说，epoll更加灵活，没有描述符限制。epoll使用一个文件描述符管理多个描述符，将用户关系的文件描述符的事件存放到内核的一个事件表中，这样在用户空间和内核空间的copy只需一次。[引用](http://www.cnblogs.com/Anker/p/3263780.html)

  ​	java select底层是根据不同的系统采用不同的模式的如下：

  ```
  If linux kernel >= 2.6 is detected, then the java.nio.channels.spi.SelectorProvider will use epoll.

  public static SelectorProvider create() {
      String osname = AccessController.doPrivileged(
          new GetPropertyAction("os.name"));
      if ("SunOS".equals(osname)) {
          return new sun.nio.ch.DevPollSelectorProvider();
      }

      // use EPollSelectorProvider for Linux kernels >= 2.6
      if ("Linux".equals(osname)) {
          String osversion = AccessController.doPrivileged(
              new GetPropertyAction("os.version"));
          String[] vers = osversion.split("\\.", 0);
          if (vers.length >= 2) {
              try {
                  int major = Integer.parseInt(vers[0]);
                  int minor = Integer.parseInt(vers[1]);
                  if (major > 2 || (major == 2 && minor >= 6)) {
                      return new sun.nio.ch.EPollSelectorProvider();
                  }
              } catch (NumberFormatException x) {
                  // format not recognized
              }
          }
      }

      return new sun.nio.ch.PollSelectorProvider();
  }


  ```

  > 采用epoll的话，有两种模式[引用](https://segmentfault.com/a/1190000003063859#articleHeader15)
  >
  > epoll对文件描述符的操作有两种模式：**LT（level trigger）**和**ET（edge trigger）**。LT模式是默认模式，LT模式与ET模式的区别如下：
  > 　　**LT模式**：当epoll_wait检测到描述符事件发生并将此事件通知应用程序，`应用程序可以不立即处理该事件`。下次调用epoll_wait时，会再次响应应用程序并通知此事件。
  > 　　**ET模式**：当epoll_wait检测到描述符事件发生并将此事件通知应用程序，`应用程序必须立即处理该事件`。如果不处理，下次调用epoll_wait时，不会再次响应应用程序并通知此事件。
  >
  > jdk采用的是水平触发
  >
  > netty采用的是边缘触发，边缘触发模式在很大程度上减少了epoll事件被重复触发的次数，因此效率要比LT模式高。epoll工作在ET模式的时候，必须使用非阻塞套接口，以避免由于一个文件句柄的阻塞读/阻塞写操作把处理多个文件描述符的任务饿死。

  下面的是结合SocketChannel的代码解析

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
							ByteBuffer buf = (ByteBuffer) key.attachment();//附带attachment，复用buf，并且可以用到拆包的地方
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

