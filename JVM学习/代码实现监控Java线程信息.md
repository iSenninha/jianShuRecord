##### 代码实现监控Java线程信息

> Thread里提供了成员方法**getAllStackTraces()**，我们可以用这个接口获取到线程的信息，然后提供给web或者其他协议调用。

如下：

```
public class HelloWorld {

	public static void main(String[] args) {
			new HelloWorld().getAllStacks();
	}
	
	private void getAllStacks() {
		Thread t = Thread.currentThread();
		Map<Thread, StackTraceElement[]> stackMap = t.getAllStackTraces();
		Set<Entry<Thread, StackTraceElement[]>> entrySet = stackMap.entrySet();
		for(Entry<Thread, StackTraceElement[]> entry : entrySet) {
			System.out.println(entry.getKey().getName() + ": ");
			for(StackTraceElement element : entry.getValue()) {
				System.out.println(element.toString());
			}
			System.out.println("\n");
		}
	}
```

即可生成线程栈信息，可以给前端一个接口获取，不用每一次都上服务器取搞这些信息了。