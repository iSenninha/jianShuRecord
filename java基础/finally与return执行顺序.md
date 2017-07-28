###finally与return执行顺序

####1.return语句在try语句里的
```
private String t(){
		String s = new String();
		try{
			s = "wocal";
			return s;
		}catch(Exception e){
			e.printStackTrace();
		}finally{
			s = "finally";
		}
		
	}
```

debug的时候可以看到，程序到return s语句时是直接跳到finally块里的，然后此时s以及被改成了**"finally"**，执行完finally块后返回继续执行return s，然后发现返回的值其实还是运行finally块前的**wocal**

> 所以return语句在try语句里的，finally块在return前执行，但是返回值的内容不受finally块的影响。


####2.return语句在finally里的
```
	private String t(){
		String s = new String();
		try{
			s = "wocal";
			return s;
		}catch(Exception e){
			e.printStackTrace();
		}finally{
			s = "finally";
			return s;
		}
	}
```
return语句在finally块里的话，try catch外的代码就是不可达的，所以这里最外边不用加return可以编译通过
debug后发现，返回值是finally
> 所以如果try块和finally块里同时有return语句，那么返回值受finally块里的影响

<br>
那么问题来了，为什么return的值有时候受影响有时候不呢，

第一种情况，try里return s的时候，已经把值"wocal"放进临时栈中，所以之后finally里对s的引用改变并不会改变返回值。

第二种情况，尽管第一个return已经放"wocal"放进临时栈了，但是finally里又把值"finally"放进了返回栈，（应该是直接压入？），所以最后返回的是较新的那个，暂且理解为后进先出吧。。
