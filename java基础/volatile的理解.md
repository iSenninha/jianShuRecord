#####volatile的理解
首先上代码
```
public class VolatileTest implements Runnable{
	private boolean isStop;
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		VolatileTest v = new VolatileTest();
		Thread t = new Thread(v);
		t.start();
		try{
			Thread.sleep(1000);
		}catch(Exception e){
		}
		v.isStop = true;
	}
	
	public void run() {
		while(!isStop){

		}
		System.out.println("停止");
	}

}
```
 运行这段代码,把jvm设置为server模式,主线程在启动子线程后,休眠1s,子线程在这个时候进入一个条件循环,1s后主线程把循环条件置为true,但是这个时候会发现子线程进入了死循环,这是因为**无法看到**主线程对isStop变量的修改.
普遍的解释说法是线程内部维护了一个isStop的变量副本,子线程为了提高运行效率,从变量副本里取isStop,所以主线程对isStop的修改对于子线程不可见.
那么问题来了,这个变量副本是存在哪里的呢?

---

从[rocomp博客](http://www.cnblogs.com/rocomp/p/4780532.html)中看到

> 线程对共享变量的所有操作都必须在自己的工作内存（working memory,是cache和寄存器的一个抽象，而并不是内存中的某个部分，这个解释源于《Concurrent Programming in Java: Design Principles and Patterns, Second Edition》§2.2.7，原文：Every thread is defined to have a working memory (an abstraction of caches and registers) in which to store values. 有不少人觉得working memory是内存的某个部分，这可能是有些译作将working memory译为工作内存的缘故，为避免混淆，这里称其为工作存储，每个线程都有自己的工作存储）中进行，不能直接从相互内存中读写

---

所以说以上的那个程序,子线程一直从自己的工作内存里取出isStop的变量副本,一直无法发现共享内存里已经改变了值.
普遍的解决方法是,对isStop声明了**volatile**变量,这样,对变量的读写都会从共享内存里去取,而不是从工作内存(缓存)里拿.

volatile的语义就是在该变量被修改的时候,不使用线程的缓存,(这里的缓存指的可能是寄存器或者是cpu的1,2,3级高速缓存).直接从共享内存(ram)里取出值.

那么除了将isStop声明为volatile变量,还有其他方法能避免线程使用缓存吗?
误打误撞,发现如果在死循环中打印或者进行wait的话,这个死循环会退出.就是说在进行吃i/0输出或者等待的时候导致了缓存失效?

稍微改改代码:
```
public class VolatileTest implements Runnable{
	private boolean isStop;
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		VolatileTest v = new VolatileTest();
		for(int i = 0 ; i < 1 ; i++){
			Thread t = new Thread(v,"线程" + i);
			t.start();
		}
		try{
			Thread.sleep(1000);
		}catch(Exception e){
		}
		v.isStop = true;
	}
	
	public void run() {
		while(!isStop){
			try {
			//休眠足够时间,好去看看对应进程里线程在干啥
				Thread.currentThread().sleep(30000);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		System.out.println("停止");
	}

}
```

打印出的线程状态:
```
"线程0" #9 prio=5 os_prio=0 tid=0x00007f818c0dd800 nid=0x1968 waiting on condition [0x00007f816dedb000]
   java.lang.Thread.State: TIMED_WAITING (sleeping)
        at java.lang.Thread.sleep(Native Method)
        at cn.senninha.swordtooffer.thread.VolatileTest.run(VolatileTest.java:22)
        at java.lang.Thread.run(Thread.java:745)
```
>
似乎可以得出结论,一旦线程进入等待,缓存就会失效,然后就会从共享内存(ram)里去取值.

扯远了,所以volatile的特性就是:
#####1.可见性:对于volatile变量的读,总是看到任意线程对这个volatile变量最后的写入:
就是说,a线程如果对一个volatile变量进行了写入,那么其他线程对于该volatile变量的缓存就会失效,转而从共享内存里去获取这个变量最新的值.
#####2.原子性:对单个volatile变量的读写具有原子性


----
另外,只要对一个变量用volatile声明,不管它是多复杂的一个类,他的所有变量经过修改后都会马上写回共享内存里,保证可见性,比如如下示例:
```
/**
*声明VolatileNode为volatile变量,实际上用来通信表示线程需要停止的是VolatileNode对象里
*的VolatileNode1里的isStop变量,但是,在这种情况下,isStop的改变仍然会马上写回共享内存
*里,保证可见性.所以,在声明volatile变量时候,粒度应该尽量小一点,不然应该会影响到效率.
**/
public class VolatileTest implements Runnable{
	private boolean isStop;
	private volatile VolatileNode node = new VolatileNode();
	public static void main(String[] args) throws InterruptedException {
		// TODO Auto-generated method stub
		VolatileTest v = new VolatileTest();
		for(int i = 0 ; i < 1 ; i++){
			Thread t = new Thread(v,"线程" + i);
			t.start();
		}
		Thread.currentThread().sleep(1000);
		v.node.node1.isStop = true;
	}
	
	public void run() {
		while(!node.node1.isStop){
			
		}
		System.out.println("停止");
	}

}

class VolatileNode{
	public boolean isStop;
	public VolatileNode1 node1 = new VolatileNode1();
}

class VolatileNode1{
	public boolean isStop;
}
```
