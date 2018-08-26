#### HttpInNetty
学习Netty中的Http编解码来了解如何优雅实现协议编解码。

##### 1.简单了解Http协议
- 一个简单的Http请求如下：
```
GET /maven2/ch/qos/logback/logback-classic/ HTTP/1.1
Host: central.maven.org
Connection: keep-alive
Cache-Control: max-age=0
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.62 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8
```
第一行是分别是**http动作**,**请求资源路径**,**http版本**
第二行是**host**地址
Http行结束的标志是**\r\n**(回车，换行)
含义后续再表。

- Http响应：
```
HTTP/1.1 200 OK
content-Type: application/javascript
\r\n
content
```
响应的构建也很简单
第一行：http协议版本 响应状态
...
\r\n空白行作为分隔符，然后就是内容。

我们现在常用的http协议版本是**HTTP1.1**，主要有以下特性:
- 引入了持久连接
以上我们看到了请求头包含了**Connecton:keep-alive**，其实http1.1是默认支持这个特性的，不写也是可以的。
这意味着一个Http请求完成后，底层的Tcp链接不会马上释放，而是等待被复用，一段时间不活动后，才会释放Tcp链接。规范的做法是，客户端在最后一个请求时，
发送**Connection:close**，明确要求服务器关闭Tcp链接。

- 管道机制
允许客户端同时发送多个请求，比如a，b请求同时发出，不需要等待a请求得到响应后再发送b请求。

- Content-Length字段
因为底层的Tcp链接是可以复用的，所以必须标明本次Http响应的content边界。
```
Content-Length:2222
```
表明本次http响应的长度是2222个字节，接下去的字节就属于下一个http请求了。

- 分块传输机制
使用**Content-Length**的前提条件是，服务器响应的时候已经知道了数据长度，对于一些耗时的动态操作，需要等待处理完毕才发送回传请求，效率不高，所以
有了分块传输机制，每个非空的数据块之前，会有一个16进制的数值表示这个块的长度，最后一个大小为0。
```
	HTTP/1.1 200 OK
	Content-Type: text/plain
	Transfer-Encoding: chunked

	23
	This is the data in the first chunk

	1a
	and this is the second one

	3
	con

	8
	sequence

	0
```

- 其他功能
1.1版新增了许多动词方法：**PUT**,**PATCH**,**HEAD**,**OPTIONS**,**DELETE**
另外，客户端请求头信息新增了**HOST**字段，用来指定服务器的域名。


##### 2.netty中http服务端解码(Decode)的实现
netty本身是自带了http服务相关的，甚至自带了demo,**HttpSnoopServer**就可以食用。。
另外，服务端解码，其实就是解析**request**,解析**request**主要是在**HttpObjectDecoder**这个类里。

首先，抽象出了这几个枚举作为解码过程中的状态:
```
/**
* The internal state of {@link HttpObjectDecoder}.
* <em>Internal use only</em>.
*/
private enum State {
	SKIP_CONTROL_CHARS,					// 跳过控制字符
    READ_INITIAL,						// 读取第一行字符
	READ_HEADER,
 	READ_VARIABLE_LENGTH_CONTENT,
	READ_FIXED_LENGTH_CONTENT,
    READ_CHUNK_SIZE,
    READ_CHUNKED_CONTENT,
    READ_CHUNK_DELIMITER,
    READ_CHUNK_FOOTER,
    BAD_MESSAGE,
    UPGRADED
}
```

重点看decode()方法:
- SKIP_CONTROL_CHARS(跳过控制字符)

- READ_INITIAL(读初始化)
  读初始化代码如下：
  ```java
          case READ_INITIAL: try {
              AppendableCharSequence line = lineParser.parse(buffer);	// 读取第一行
              if (line == null) {
                  return;
              }
              String[] initialLine = splitInitialLine(line);			// 根据空格，分出三个字符
              if (initialLine.length < 3) {
                  // Invalid initial line - ignore.
                  currentState = State.SKIP_CONTROL_CHARS;
                  return;
              }
  
              message = createMessage(initialLine);					// 创建HttpMessage对象
              currentState = State.READ_HEADER;						// 切换至下一个状态
              // fall-through
          } catch (Exception e) {
              out.add(invalidMessage(buffer, e));
              return;
          }
  ```

  读取行是抽象出了一个**HeaderParser**接口，针对不同的功能，读取**ByteBuf**里的内容。这里使用的是**LineParser**实现类。

  如果读取成功，并切分成三份字符串，分别对应的其实就是以下***动作,资源路径,******版本：

  ```
  GET /index.html HTTP/1.1
  ```

- READ_HEADER(读取头部信息)
  读取头部信息，读取到头部信息后又有一个switch，是个复杂的状态处理
  ```
      private State readHeaders(ByteBuf buffer) {
        final HttpMessage message = this.message;
        final HttpHeaders headers = message.headers();
  
        AppendableCharSequence line = headerParser.parse(buffer);	// 读取一行头信息，以LF作为结尾
        if (line == null) {
            return null;
        }
        if (line.length() > 0) {
            do {
                char firstChar = line.charAt(0);
  			// 分包的情况下，需要拼接name-value对,这里要注意，如果header的name和value不在同一行，value行开头需要用一个' 'or '\t'
                if (name != null && (firstChar == ' ' || firstChar == '\t')) {			
  				StringBuilder buf = new StringBuilder(value.length() + line.length() + 1);
                    buf.append(value)
                       .append(' ')
                       .append(line.toString().trim());
                    value = buf.toString();
                } else {
                    if (name != null) {
                        headers.add(name, value);
                    }
                    splitHeader(line);							// 完整地分割一个header的name-value对
                }
  
                line = headerParser.parse(buffer);
  			// 如果读取到末尾的话，会读取到\r\n(回车、换行),所以正常结束的不会为null,即header与content之间隔着一个空行(\r\n)
                if (line == null) {								
                    return null;
                }
            } while (line.length() > 0);						// 循环读取所有的
        }
  
        // Add the last header.
        if (name != null) {
            headers.add(name, value);
        }
        // reset name and value fields
        name = null;
        value = null;
  
        State nextState;
  
  	// 读取完所有的header后，开始判断是哪种请求
        if (isContentAlwaysEmpty(message)) {						// 这个是用作客户端解码的时候用到的，这里讲服务端
            HttpUtil.setTransferEncodingChunked(message, false);
            nextState = State.SKIP_CONTROL_CHARS;
        } else if (HttpUtil.isTransferEncodingChunked(message)) {	// 这个chunk的情况，下一个状态变成READ_CHUNK_SIZE
            nextState = State.READ_CHUNK_SIZE;
        } else if (contentLength() >= 0) {							// 直接读取固定长度大小
            nextState = State.READ_FIXED_LENGTH_CONTENT;			
        } else {
            nextState = State.READ_VARIABLE_LENGTH_CONTENT;
        }
        return nextState;
    }
  ```
- READ_FIXED_LENGTH_CONTENT（读取定长的字节，已经在上一层把**content-length**弄到**chunk**里去了:
  读取定长的content
  ```
	  case READ_FIXED_LENGTH_CONTENT: {
		  int readLimit = buffer.readableBytes();

		  // Check if the buffer is readable first as we use the readable byte count
		  // to create the HttpChunk. This is needed as otherwise we may end up with
		  // create a HttpChunk instance that contains an empty buffer and so is
		  // handled like it is the last HttpChunk.
		  //
		  // See https://github.com/netty/netty/issues/433
		  if (readLimit == 0) {
			  return;
		  }

		  int toRead = Math.min(readLimit, maxChunkSize);
		  if (toRead > chunkSize) {
			  toRead = (int) chunkSize;
		  }
		  ByteBuf content = buffer.readRetainedSlice(toRead);
		  chunkSize -= toRead;

		  if (chunkSize == 0) {				// 读取就完了
			  // Read all content.
			  out.add(new DefaultLastHttpContent(content, validateHeaders));
			  resetNow();
		  } else {
			  out.add(new DefaultHttpContent(content));
		  }
		  return;
	  }
  ```

 - READ_CHUNK_SIZE & READ_CHUNK_CONTENT
   如果是进入了chunk模式的话，是在两个状态之间来回读取，直到读取完毕。
   需要注意的是，在**READ_CHUNK_CONTENT**状态下，读取完成一个chunk-content后，必须会带有**\r\n**作为分隔符，所以会有这个处理：
   只有chunk-content内的\r\n才需要计算进**chunk-size**，chunk-content结尾的不需要计算。[wiki里的解释](https://en.wikipedia.org/wiki/Chunked_transfer_encoding)
   ```
           case READ_CHUNKED_CONTENT: {
               assert chunkSize <= Integer.MAX_VALUE;
               int toRead = Math.min((int) chunkSize, maxChunkSize);
               toRead = Math.min(toRead, buffer.readableBytes());
               if (toRead == 0) {
                   return;
               }
               HttpContent chunk = new DefaultHttpContent(buffer.readRetainedSlice(toRead));
               chunkSize -= toRead;
   
               out.add(chunk);
   
               if (chunkSize != 0) {
                   return;
               }
               currentState = State.READ_CHUNK_DELIMITER;		// 已经读取完了chunk-content,去读取内容末尾的\r\n了
               // fall-through
           }
           case READ_CHUNK_DELIMITER: {
               final int wIdx = buffer.writerIndex();
               int rIdx = buffer.readerIndex();
               while (wIdx > rIdx) {
                   byte next = buffer.getByte(rIdx++);
                   if (next == HttpConstants.LF) {
                       currentState = State.READ_CHUNK_SIZE;
                       break;
                   }
               }
               buffer.readerIndex(rIdx);
               return;
           }
   ```

 - READ_CHUNK_FOOTER
   当读取到chunk-size为0的时候，进入chunk-footer模式。

   ```
           case READ_CHUNK_FOOTER: try {
               // 读取Chunk的TrailingHeader
               LastHttpContent trailer = readTrailingHeaders(buffer); 
               if (trailer == null) {
                   return;
               }
               out.add(trailer);
               resetNow();
               return;
           } catch (Exception e) {
               out.add(invalidChunk(buffer, e)); return; }
   ```
   [firefox](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Trailer)这个wiki解释了
   > The Trailer response header allows the sender to include additional fields at the end of chunked messages in order to supply metadata that might be dynamically generated while the message body is sent, such as a message integrity check, digital signature, or post-processing status.

   附加用来解释chunk-data的格式之类

   示例:
   ```
   HTTP/1.1 200 OK 
   Content-Type: text/plain 
   Transfer-Encoding: chunked
   Trailer: Expires
   
   7\r\n 
   Mozilla\r\n 
   9\r\n 
   Developer\r\n 
   7\r\n 
   Network\r\n 
   0\r\n 
   Expires: Wed, 21 Oct 2015 07:28:00 GMT\r\n
   \r\n
   ```
 至此，HttpHeader Server端的解码就解析完成了。

##### 3.Http服务端Encode编码实现
 服务端的编码，其实就是构造Response。按照和Request的一样的思路来。重点实现是在**HttpObjectEncoder**。
