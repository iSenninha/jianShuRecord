##JAVA代码模拟获取cookie以及携带cookie

去年做android的时候，网络连接没有用类似OKHttp之类的框架，而是完全用jdk自带的api实现，今天不想看书。。就把笔记整理一下吧。。

这里有个小demo，是先实现登陆，登陆的过程是通过post方式请求，登陆后通过携带的cookie判断是否已经成功登陆。

###1.获取cookie
```
public void connect(String u) throws IOException{
		HttpURLConnection conn = null;
		OutputStream os = null;
		InputStream is = null;
		try {
			URL url = new URL(u);
			conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("POST");
			conn.setDoInput(true);
			conn.setDoOutput(true);
			os = conn.getOutputStream();
			String param = "account=senninha&password=senninha";
			String eparam = param;
			//这里是把post参数携带上去。
			os.write(eparam.getBytes("utf-8"));
			is = conn.getInputStream();
			byte[] b = new byte[1024];
			int len = is.read(b);
			while(len != -1){
				System.out.println(new String(b,0,len,"utf-8"));
				len = is.read(b);
			}
			//这里是读取第一次登陆时服务器返回的cookie，然后用一个全局变量cookie接收。因为是服务器往客户端发送cookie，所以名字是Set-Cookie
			cookie = conn.getHeaderField("Set-Cookie");
			System.out.println("read over" + cookie);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}	finally{
			if(os != null){
				os.close();
			}
			
			if(is != null){
				is.close();
			}
			if(conn != null){
				conn.disconnect();
			}
			
			System.out.println("all close");
		}
	}
```
###2.携带cookie
```
public void isLogin(String u) throws IOException{
		HttpURLConnection conn = null;
		InputStream is = null;
		try {
			URL url = new URL(u);
			conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("POST");
			//把上一步获取的cookie携带上去
			conn.setRequestProperty("cookie", cookie);
			conn.setDoInput(true);
			is = conn.getInputStream();
			byte[] b = new byte[1024];
			int len = is.read(b);
			while(len != -1){
				System.out.println(new String(b,0,len,"utf-8"));
				len = is.read(b);
			}
			System.out.println("read over");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}	finally{
			if(is != null){
				is.close();
			}
			if(conn != null){
				conn.disconnect();
			}
			
		}
			System.out.println("all close");
		}
```

ok，以后每次访问，只要携带上这个cookie，就可以畅通无阻了。当然，是指用cookie维持登陆的网站。

ps：java后端的维持登陆状态的cookie叫JSESSIONID，php的叫phpSessionId好像。。
ps：对于安卓客户端来说，获取到的cookie可以存到数据库里，这样重启app后一样可以再次保持登陆状态。
