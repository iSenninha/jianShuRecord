再来一发好久之前的笔记。。
JSTL是Jsp Standard Langeage 的缩写，要使用jstl，首先要把jar包放在WebContent/WebInfo/lib下，然后build，不放在这里的话服务器会报错。
	然后<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
	就可以正常使用了。


####1.out输出语句：
	<c:out value = "xxx"/>
	如果要用el表达式，应该是这样子单引号:
	<c:out value = '${param.name}'/>

####2.set设置:
	a.初始化或者修改bean里的值
	<c:set value = "要设置什么值" taget = "设置的目标对象" property = "子参数"/>
	如下修改bean：
	<c:set target = '${beanName}' property="name" value = "senninha"></c:set>
	如果没有新建，如果有就修改
	
	b.修改request,session.application attribute。
	<c:set var = "要设置是attribute名称" value = "值" scope = "域"/>
	<c:set var = "name" value = "senninha" scope = "request"/>
	注意，并不能设置parameter的值。

####3.remove 使用和set相似。


####4.if
	<c:if test = "要判断的逻辑语句 只能是el表达式子" var = "判断结果保存在这里">
		<c:out value = "逻辑判断:${tem}">
		如果true，则运行这里，否则不行
		可以在这里写html语句
		<h1>我是h1</h1>
	</c:if>
	
####5.choose(catch)
	<c:choose >
		<c:when test = "">
			statement
		</when>
		
		<c:otherwise test = "">
			statement
		</when>
	</c:choose>
	相当于多重选择语句if else

####6.forToken(StringTokenizer)
	<c:forToken var = "处理后保存在这里" items = "被处理的对象" delims = "分隔符||多个用这个符号隔开">
	</c:forToken>
	
####7.forEach循环
	a.简单循环输出数字
	  <c:forEach var = "tem" begin = "1" end = "10" step = "2" varStatus = "statusTem">
		<c:out value = "${statusTem.first.last.count.index"}//输出循环的次数，计数以及长度
	 
	b.循环输出数组集合等
	  <c:forEach var = "item" items = "集合或者数组" >
	  <c:out value = "${item}"/>
	  </c>

####8.catch
	<c: var = exception对象>
		可能出问题的语句
	</c:var>
	然后：
	<c:out value = "${exception.message.cause"/>
	
####9.url(点击时候保持session，并且可以在跳转的时候保存request参数)
	a.首先生成url字符串:
		<c:url var = "url" value = "se.jsp">
			//这里可以设置表单值
			<c:param name = "ss" value = ""/>
			//或者attributte
			<c：set var = "ss" value = "senn" scope = "session"/>
		</c:url>
	
	b.然后使用即可：
		<a href = "${url}"/>
		
####10.import
	1.把其他服务器网页或者自己的服务器网页引入
		<c:import url="http://163.com"></c:import>
	2.把其他网页的源码引入作为输出：
		<c:import url = "http://163.com" var = "保存在这里">
		</c:import>
		
		然后就可以在网页上显示这些源码了
		<c:out value = "${tem}"/>
		
####11.redirect
	能够在cookie不起作用时自动通过urlWriting保存session
	<c:redirect url = "${9<c:url>生成的对象}"
