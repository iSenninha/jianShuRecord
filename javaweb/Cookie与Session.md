####1.首先是cookie的基本用法：
```//获取cookie
		Cookie[] c = request.getCookies();
		System.out.println("cookie 的长度"+c.length);
		for(Cookie ct:c){
			System.out.println(ct.getName());
		}
		//添加cookie
		Cookie cookie = new Cookie("brun","ss");
		response.addCookie(cookie);
```
日常开发中可以使用cookie来保持状态来达到保持连接的功能，日常开发中常用session


而session保持状态的期中一部分就是通过cookie来实现的，如上代码，我们会发现console会打印出  JSESSIONID，同时会发现浏览器里有这个cookie（按f12），并且这个cookie是httpOnly，不可以被js代码去获取的，并且退出会话后将会自动销毁（即退出浏览器）
![session.png](http://upload-images.jianshu.io/upload_images/3454506-09cd158a28901d42.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

即是session用cookie来保持状态；
如果将浏览器设置为禁止使用cookie，session也将失效，如下：
```//这种使用cookie来实现session连接的在关闭cookie后将无法继续工作
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
		String path = "redirect.jsp";
		HttpSession session = request.getSession(false);
		if(session != null){
			System.out.println("old session is not null");
			session.invalidate();
			//清处掉原来的session保持的数据，同事会把cookie都清除
		}
		session = request.getSession(true);
		session.setAttribute("bruno", "senninha");
		response.sendRedirect(path);
	}
```
	
####2.对于关闭cookie的浏览器，一般是用URLRewriting来实现跟踪的功能：

如上，将
```
session = request.getSession(true);
session.setAttribute("bruno","senninha");
```
//一定要在重新获取session对象后再去encode，不然没有session自然无法添加对应的sessionid
String path2 = response.encodeURL(path);
		
然后path2，如下：
		http://localhost:8888/zhb/redirect.jsp;jsessionid=BE7B7F60D7CD0965EAD3A3F1F87F49D3
		
		
如果允许使用cookie的话，相同的代码会发现并不会在url里加上一坨sessionid。
因为在response的encodeURL方法里，通过判断sessionFromCookie()来判断session是否来自cookie
<br>
在允许cookie的浏览器第一次访问时，由于本地没有cookie，那么会无法通过上诉方法判断是否需要encode，待本地有cookie后才会停止在url后追加sessionid；
	浏览器可能会过滤掉有cookie情况下的url追加
	
	
总结：
- 在cookie允许的情况下，会在浏览器本地储存一个session-id -value的cookie的键值对，每一次浏览器访问时会把这个cookie携带上去，服务器根据这个cookie值作为key去获取储存在内存里的值。然后服务器就知道这个访问的浏览器是否已经登陆过了。通过这种方式在http协议无状态的情况下达到会话保持的效果。

- 在服务器不允许cookie或者第一次访问(本地无cookie)的情况下，默认request.geSession(false)是无法获取一个session对象的。
	request.getSession(true);//才可以获取一个session对象
