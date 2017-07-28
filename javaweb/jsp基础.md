以前的笔记。。。
jsp是Java Server Page 的缩写。是建立在Servlet基础上的。

####1.基础：jsp的标记：
	1.注释 
		<%-- %> 值得一提的是注释在用户端是隐藏的，而html的注释的可以看到的
	
	2.jsp声明
		<%! xxx --%> 声明全局变量
	
	3.jsp小脚本表达
		<%  xxx; %>
		
	4.jsp表达式
		<%=xxx> 只有一句，且最后不需要加分号
		
	5.jsp指令 directive
		<%@ xxx> 指令有三种：
					<%@ page...%>		配置语言以及导入的包(默认导入Servlet等包),<%@ page import = "java.util.ArrayList" session = "true" pageEncoding = "utf-8>
					<%@ include %>		动态包含代码
					<%@ taglib..%>	
	
	6.jsp 的action:
		<jsp:xxx> jsp的action有如下：
					<jsp:useBean>
					<jsp:setProperty>
					<jsp:getProperty>
					<jsp:param>
					<jsp:include>
					<jsp:forward>
					<jsp:plugin>
				

####2.Jsp的9个内置对象：
	1.request HttpServletRequest
	2.response HttpServletResponse
	3.pageContext:jsp.PageContext对象
	4.appplication:ServletContext对象
	5.out:PrintWriter对象
	6.config:ServletConfig对象 初始化Servlet初始化数据如下：<%=config.getInitParameter("senninha") %>
	7.page:相当于this关键字，代表产生的Servlet需要强转为JspPage类型
	8.session:HttpSession对象
	9.exception：Exception对象
	
####3.Jsp的Scope:	
	在servlet里，有Context，Session，Request三种，在Jsp里，对应的分别是Application，Session，Request，还有一个就是page，在Servlet里没有对应。
	
####4.高级属性
	a.动态属性：
		<input tyep = "text" name = "useranme" value = "<%= request.getParameter("ss")%>,只有表达式可以，而小脚本不可以
		
	b.静态和动态包含(include)
		一.静态包含：
					<%@ include file = "xxx.jsp">
					静态包含不可以去修改或者设置xxx.jsp的内容
				
		二.动态包含：
					被包含的jsp里有这样一行代码：
					<%=request.getParameter("senninha")%> //paramater要和attribute区分开来
					
					然后在包含的代码里还可以动态修改para的值：
						<jsp:include page="Test.jsp" flush = "false">
							<jsp:param value = "senninha" name = "senninha"/>
						</jsp:include>
			
	c.错误捕获
		如果在jsp里出现错误，如果显示在网页上体验不好，可以定义一个网页专门显示error
			在可能出错的网页里指定处理错误的网页
			<%@ page errorPage="Error.jsp" %>
			try{}
			catch(){
			throw new Exception("xxxcuowu")}
			
			然后在Error.jsp里：
				第一是设置<%@ page isErrorPage="true"%>
					然后就可以用内置对象来进行显示了。<%=exception.getMessage()>
	
	d.设置其他:
		设置内容：
				<%@page contentType = "text/html" %> || <% response.setContentType("text/html");|| response.setContentType("appplication/vnd.ms-excel");


####5.解析jsp和javabean的关系：
	a.<useBean>
	<jsp:useBean id="book" class="bean.BookBean" scope = "request">
		<%
			if(book.getName() == null){
				out.print("book is null");
			}else{
				out.print("booke is not null");
			}
			//如果已经存在了这个bean，则这些代码就不会执行。
			//例如这里设置的是request，假如在上一个转发的页面里  request.setAttribute("book",bookBean);
			//那么这个useBean就会直接调用这个实例化对象，而不会再去新建一个对象。
		%>
	</jsp:useBean>
	id是通配全局的变量，之后就可以直接调用了，scope是指调用的位置。这个语句相当于实例化一个BookBean对象。
	需要特别注意的是，这里一定要给BookBean一个空的构造方法。
	记得getParameter和attribute的区别。parameter是获取表单提交的数据。
	
	b.<jsp:setProperty param = "表单里的名字" name = "bean的id" property = "bean里要设置的那个参数">
