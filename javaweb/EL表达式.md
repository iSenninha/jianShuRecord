好久之前的笔记，现在整理一起发了。。。
EL表达式的语法是:${expression}.

####1.获取request，session，context里的值：
	request.setAttribute("senninha","request");
	session.setAttribute("senninha","session");
	context.setAttribute("senninha","context");
	
	${senninha} 将获取到request的值，获取attribute的时候是按request-->session-->context 的顺序(由小到大)走的
	
	获取request的parameter参数也很简单：
	${param["name"]}  or ${param.name} 即可获取到表达的参数
	
####2.EL支持的一些算术表达和逻辑运算
	a.大于等于 >= ge(grater equals) ${1 ge 0} = true;
	b.诸如此类
	c.也支持java的三目运算符：
		${(3 ge 2) == (3 ge 4) ? "yes they are equals":"no they are not equals"}
		这样就可以很方便显示
	d.empty 判读是否为空：
		${empty array} 如果为空(对于集合来说,对于一般对象则是表示是否为null) 则显示true。
		
####3.EL表达式也有内置对象:
	a.pageContext
	b.pageScope
	c.requestScope:相当于request变量的map集合
	d.sessionScope:相当于session变量的map集合
	e:applicationScope:相当于application变量的map集合
	f:param:相当于request的参数值的map:
	g:paramValues:request的参数组名parameter[] 的map
	h:header:request的header的Map
	i:headerValues:request的header[] 数组的map
	
	有了这些就可以避免1中在多个同名值的时候无法选的问题了。
	如下：
			${requestScope.senninha}
			${sessionScope.senninha}
			${applicationScope.senninha}
			
			当param或者header内存在多个同名值的时候：
			如下：
				${paramValues.name[1]}
				适合在表格输入的时候使用
