### EventLoopInNetty
> 这里主要记录netty的EventLoop类库的结构体系

#### 1.结构

![类库继承结构](./pic/EventLoopStruct.jpg)

- EventExecutorGroup

  继承了JDK的**ScheduledService**，加入了自己的**shutdownGracefully**和重要的**next()**方法返回组内的下一个执行器**EventExecutor**

- EventExecutor & EventLoopGroup
  这两个接口，**EventExecutor**新增了**inEventLoop()**方法返回当前的线程是否处于事件loop中，用于并发新增的任务处理。
  **EventLoopGroup**主要新增了**register(Channel channle)**方法，这个方法是用于将**channel**注册进这个**EventLoop**里面去的，整个继承先上**第一个与通信**相关的接口

- EventLoop接口
  然后**EventLoop**接口又继承了**EventExecutror**与**EventLoopGroup**接口，作为处理所有channel的**I/O**操作的统一接口。
  ```
  /**
   * Will handle all the I/O operations for a {@link Channel} once registered.
   *
   * One {@link EventLoop} instance will usually handle more than one {@link Channel} but this may depend on
   * implementation details and internals.
   *
   */
  public interface EventLoop extends OrderedEventExecutor, EventLoopGroup {
      @Override
      EventLoopGroup parent();
  }
  ```

- SingleThreadEventLoop.java

  这里继承了**SingleThreadEventExecutor**（实现了任务处理），并实现了**register(Channel channel)**。

  ```
      @Override
      public ChannelFuture register(Channel channel) {
          return register(new DefaultChannelPromise(channel, this));
      }

      @Override
      public ChannelFuture register(final ChannelPromise promise) {
          ObjectUtil.checkNotNull(promise, "promise");
          promise.channel().unsafe().register(this, promise);
          return promise;
      }
  ```

- NioEventLoop

  我们用Netty，通常是使用**Nio**模式来通信，整个**Nio**的读写操作以及任务队列的执行的策略都在**NioEventLoop**里实现，而其他的核心是**run**方法，这里不贴代码了。

- MultithreadEventExecutorGroup & NioEventLoopGroup

  上面那些都是单个线程的**EventLoop**，这里将上面的整合起来，前者留出**newChild(ThreadFactory factory, Object... args)**实现多线程的接口。后者实现了这个接口的逻辑:

  ```
  @Override
      protected EventLoop newChild(Executor executor, Object... args) throws Exception {
          return new NioEventLoop(this, executor, (SelectorProvider) args[0],
              ((SelectStrategyFactory) args[1]).newSelectStrategy(), (RejectedExecutionHandler) args[2]);
      }
  ```

  与**NioEventLoop**整合起来了。
#### 2.NioEventLoop实现

##### 2.1.使用SelectedSelectionKeySet替换默认的Selector里的HashSet

使用**SelectedSelectionKeySet**替换默认**Selector**实现里的**HashSet**，前者是一个数组实现的**fake Set**，仅仅是为了与接口兼容。使用两个等容量的数组来优化直接使用HashSet来加速迭代减少GC压力，然后select的时候，就绪的selectedKeys就会添加到这里来。具体的[提交记录](https://github.com/netty/netty/commit/3ce9ab2e72235bf2ae45f57de11803249419cb69)和优化讨论在[Discuss SelectedSelectionKeySet optimization in NioEventLoo #6105](https://github.com/netty/netty/issues/6105)

##### 2.2.select与任务

**NioEventLoop**的**run**方法实现了对应的I/O select和任务的处理:

```
 @Override
    protected void run() {
        for (;;) {
            try {
                try {
                // 1.优化wakeup的时机
                    switch (selectStrategy.calculateStrategy(selectNowSupplier, hasTasks())) {
                    case SelectStrategy.CONTINUE:
                        continue;
                    case SelectStrategy.BUSY_WAIT:
                    case SelectStrategy.SELECT:
                        select(wakenUp.getAndSet(false));

                        if (wakenUp.get()) {
                            selector.wakeup();
                        }
                        // fall through
                    default:
                    }
                } catch (IOException e) {
                    rebuildSelector0();	// 2.处理空轮询的问题，重建selector
                    handleLoopException(e);
                    continue;
                }

                cancelledKeys = 0;
                needsToSelectAgain = false;
                final int ioRatio = this.ioRatio;
                if (ioRatio == 100) {	// 3.I/O比例在整个线程的工作时间内的比例
                    try {
                        processSelectedKeys(); // 4.处理就绪的selectedKey
                    } finally {
                        // Ensure we always run tasks.
                        runAllTasks();
                    }
                } else {
                    final long ioStartTime = System.nanoTime();
                    try {
                        processSelectedKeys();
                    } finally {
                        // Ensure we always run tasks.
                        final long ioTime = System.nanoTime() - ioStartTime;
                        runAllTasks(ioTime * (100 - ioRatio) / ioRatio);
                    }
                }
            } catch (Throwable t) {
                handleLoopException(t);
            }
            // Always handle shutdown even if the loop processing threw an exception.
            try {
                if (isShuttingDown()) {
                    closeAll();
                    if (confirmShutdown()) {
                        return;
                    }
                }
            } catch (Throwable t) {
                handleLoopException(t);
            }
        }
    }
```

- 1-3直接在队列代码里注释了。


- 4.这里处理就绪的**selectedKeys**，代码如下:

  ```
      private void processSelectedKeys() {
          if (selectedKeys != null) {
              processSelectedKeysOptimized();
          } else {
              processSelectedKeysPlain(selector.selectedKeys());
          }
      }
  ```

  如果这个**selectedKeys**不为空，那么说明是走的是优化版的**set**(见2.1)，就绪的keys直接会在**select**的时候添加进这里来。否则，按正常的nio进行迭代就绪keys。

  着重看优化后的:

  ```
   private void processSelectedKeysOptimized() {
          for (int i = 0; i < selectedKeys.size; ++i) {
              final SelectionKey k = selectedKeys.keys[i];
              selectedKeys.keys[i] = null;

              final Object a = k.attachment();

              if (a instanceof AbstractNioChannel) {
                  processSelectedKey(k, (AbstractNioChannel) a);
              } else {
                  @SuppressWarnings("unchecked")
                  NioTask<SelectableChannel> task = (NioTask<SelectableChannel>) a;
                  processSelectedKey(k, task);
              }

              if (needsToSelectAgain) {
                  selectedKeys.reset(i + 1);
                  selectAgain();
                  i = -1;
              }
          }
      }
  ```

##### 2.3.accept bossThread-->workThread

- 上面直接讲到了**select**和处理就绪**keys**的过程。netty的示例demo是这样的:

  ```
   public void run() throws Exception {
          EventLoopGroup bossGroup = new NioEventLoopGroup(); // (1)
          EventLoopGroup workerGroup = new NioEventLoopGroup();
          try {
              ServerBootstrap b = new ServerBootstrap(); // (2)
              b.group(bossGroup, workerGroup)
               .channel(NioServerSocketChannel.class) // (3)
               .childHandler(new ChannelInitializer<SocketChannel>() { // (4)
                   @Override
                   public void initChannel(SocketChannel ch) throws Exception {
                       ch.pipeline().addLast(new DiscardServerHandler());
                   }
               })
               .option(ChannelOption.SO_BACKLOG, 128)          // (5)
               .childOption(ChannelOption.SO_KEEPALIVE, true); // (6)
      
              // Bind and start to accept incoming connections.
              ChannelFuture f = b.bind(port).sync(); // (7)
      
              // Wait until the server socket is closed.
              // In this example, this does not happen, but you can do that to gracefully
              // shut down your server.
              f.channel().closeFuture().sync();
          } finally {
              workerGroup.shutdownGracefully();
              bossGroup.shutdownGracefully();
          }
      }
  ```

  如上，是分两个**EventLoopGroup**的，一个**Boss**是用来accept连接的，另外一个**Work**是来连接完成后处理其他正常通信的。一个请求连接后是如何从**Boss**转给**Work**的EventLoop呢？

- ServerBootstrap  ServerBootstrapAcceptor

  ServerBootstrap 初始化的时候，会添加如下Handler:

  ```
    p.addLast(new ChannelInitializer<Channel>() {
              @Override
              public void initChannel(final Channel ch) throws Exception {
                  final ChannelPipeline pipeline = ch.pipeline();
                  ChannelHandler handler = config.handler();
                  if (handler != null) {
                      pipeline.addLast(handler);
                  }

                  ch.eventLoop().execute(new Runnable() {
                      @Override
                      public void run() {
                          pipeline.addLast(new ServerBootstrapAcceptor(
                                  ch, currentChildGroup, currentChildHandler, currentChildOptions, currentChildAttrs));
                      }
                  });
              }
          });
  ```

  **ServerBootstrapAcceptor**是**ServerBootstrap**的内部类，它的**channelRead**方法如下:

  ```
    public void channelRead(ChannelHandlerContext ctx, Object msg) {
              final Channel child = (Channel) msg;

              child.pipeline().addLast(childHandler);

              setChannelOptions(child, childOptions, logger);

              for (Entry<AttributeKey<?>, Object> e: childAttrs) {
                  child.attr((AttributeKey<Object>) e.getKey()).set(e.getValue());
              }

              try {
              // 调用work eventloop线程组注册accept完毕后的连接
                  childGroup.register(child).addListener(new ChannelFutureListener() {
                      @Override
                      public void operationComplete(ChannelFuture future) throws Exception {
                          if (!future.isSuccess()) {
                              forceClose(child, future.cause());
                          }
                      }
                  });
              } catch (Throwable t) {
                  forceClose(child, t);
              }
          }
  ```

  如上，连接**Accept**完毕后，就注册到**childGroup**(即work)里去进行接下去的读写操作。