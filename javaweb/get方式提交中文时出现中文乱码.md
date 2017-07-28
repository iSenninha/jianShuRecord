
因为get方式提交的参数编码，只支持iso8859-1编码:
所以在get到后要进行转码
```
String  s = new String(request.getParameter("ss").getByBytes("iso8859-1"),"utf-8");
```
