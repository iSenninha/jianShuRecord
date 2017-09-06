### ClassLoader---自定义类加载器加载指定类

> 自定义加载器是实现热更新的基础，这里就来看看如何实现自定义一个类加载器加载对应我们想要的类。

- 继承ClassLoader类

> 根据双亲委派原则，继承了ClassLoader的自定义加载器在加载一个类的时候，先会去尝试从父加载器里面查找是否被父类加载，如果被父类加载，那么就直接返回，只有父类没有加载的类，才会被我们自定义的加载器加载。
>
> 继承ClassLoader后要**重写findClass**方法，实现从指定的地方加载对应的**字节码class**资源.
>
> ```
> /** 重写的方法在这里 **/
> protected Class<?> findClass(String name) throws ClassNotFoundException {
> 		File file = getClassFile(name);
> 		try {
> 			byte[] bytes = getClassBytes(file);//加载指定的字节码资源
> 			Class<?> c = this.defineClass(name, bytes, 0, bytes.length);//调用difineClass方法。
> 			return c;//返回指定的字节码资源
> 		} catch (Exception e) {
> 			e.printStackTrace();
> 		}
>
> 		return super.findClass(name);
> 	}
>
> 	private File getClassFile(String name) {
> 		/** hardcode，直接指定要加载的字节码资源地址 **/
> 		File file = new File("/home/senninha/Person.class");
> 		return file;
> 	}
>
> 	private byte[] getClassBytes(File file) throws Exception {
> 		// 这里要读入.class的字节，因此要使用字节流
> 		FileInputStream fis = new FileInputStream(file);
> 		FileChannel fc = fis.getChannel();
> 		WritableByteChannel wbc = Channels.newChannel(baos);
> 		ByteBuffer by = ByteBuffer.allocate(1024);
>
> 		while (true) {
> 			int i = fc.read(by);
> 			if (i == 0 || i == -1)
> 				break;
> 			by.flip();
> 			wbc.write(by);
> 			by.clear();
> 		}
>
> 		fis.close();
>
> 		return baos.toByteArray();
> 	}
> ```
> 调用加载器:
>
> ```
> 		try {
> 			Class c = Class.forName("Person", false, new ClassLoaderTest());
> 			Object p = c.newInstance();
> 			System.out.println(p.getClass().getClassLoader().toString());
> 		} catch (ClassNotFoundException e) {
> 			// TODO Auto-generated catch block
> 			e.printStackTrace();
> 		} catch (InstantiationException e) {
> 			// TODO Auto-generated catch block
> 			e.printStackTrace();
> 		} catch (IllegalAccessException e) {
> 			// TODO Auto-generated catch block
> 			e.printStackTrace();
> 		}
> ```
>
> 顺利输出当前的自定义类加载器名字：
>
> ClassLoaderTest@15db9742

- 类加载的时候指定classpath路径

> 这里玩一下小花样，程序是运行在eclipse下的，然后我们再建一个**Person.java**到默认包下，什么都不用做，然后再次运行，怪异的事情出现了
>
> ```
> sun.misc.Launcher$AppClassLoader@73d16e93
> ```
>
> 变成了用**AppClassLoader**去加载这个类了。。
>
> 别方，来分析这个过程：
>
> 根据双亲委托加载的规则，出现这种情况是因为父类加载器已经加载了这个类。那么**父类*是在什么时候加载到这个类的呢？
>
> debug跟进这个工程，发现在ClassLoader的loadClass方法里：
>
> ```
>   protected Class<?> loadClass(String name, boolean resolve)
>         throws ClassNotFoundException
>     {
>         synchronized (getClassLoadingLock(name)) {
>             // First, check if the class has already been loaded
>             Class<?> c = findLoadedClass(name);
>             if (c == null) {
>                 long t0 = System.nanoTime();
>                 try {
>                     if (parent != null) {//尝试从父类里加载
>                         c = parent.loadClass(name, false);
>                     } else {
>                         c = findBootstrapClassOrNull(name);
>                     }
>                 } catch (ClassNotFoundException e) {
>                     // ClassNotFoundException thrown if class not found
>                     // from the non-null parent class loader
>                 }
>
>                 if (c == null) {//父类为空的话，从findClass()里加载
>                     // If still not found, then invoke findClass in order
>                     // to find the class.
>                     long t1 = System.nanoTime();
>                     c = findClass(name);
> 					//findClass在ClassLoader是未实现的空方法，必须由子类去指定到哪里加载，这就是我们重写findClass方法的意义。。
>                     // this is the defining class loader; record the stats
>                     sun.misc.PerfCounter.getParentDelegationTime().addTime(t1 - t0);
>                     sun.misc.PerfCounter.getFindClassTime().addElapsedTimeFrom(t1);
>                     sun.misc.PerfCounter.getFindClasses().increment();
>                 }
>             }
>             if (resolve) {
>                 resolveClass(c);
>             }
>             return c;
>         }
> ```
>
> 从上面的分析，我们可以知道原因了，因为我们往eclipse的默认包下放入了Person这个类名，调用自定义加载器的时候，会先父类的里取寻找这个类，正好eclipse下的Person在**classpath路径**下，于是，还**没**跑到自定义的findClass方法，已经加载到另外一个Person类返回了，所以是显示从**AppClassLoader**里加载到的数据。
>
> 我们把eclipse里的Person删掉，再次运行，再次出现了**ClassLoaderTest**。

- 再捋一下双亲加载器的加载过程

  1. 我们自定义了一个加载器，必须重写findClass方法，并且指定加载的类**必须不在classpath**的路径下，因为在classpath路径下的类，必然被AppClassLoader检查到并被加载。。

  2. 如何知道当前的classpath在哪里呢。很简单，一行代码：

     ```
     System.out.println(System.getProperty("java.class.path"))
     ```

     在eclipse下执行这串代码，classpath路径除了**环境变量**外，还有**eclipse当前工作空间的生成class的路径**

     命令行编译的时候指定**-cp**就是在指定classpath的路径。

     ps:[附带其他property的获取方式](../java基础/Property获取Java的相关环境参数.md)

  ----

  ​

- 完整代码

  ```
  import java.io.ByteArrayOutputStream;
  import java.io.File;
  import java.io.FileInputStream;
  import java.nio.ByteBuffer;
  import java.nio.channels.Channels;
  import java.nio.channels.FileChannel;
  import java.nio.channels.WritableByteChannel;

  public class ClassLoaderTest extends ClassLoader {

  	public ClassLoaderTest(ClassLoader parent) {
  		super(parent);
  	}

  	public ClassLoaderTest() {
  		super();
  	}

  	public static void main(String[] args) {
  		try {
  			Class c = Class.forName("Person", false, new ClassLoaderTest());
  			Object p = c.newInstance();
  			System.out.println(p.getClass().getClassLoader().toString());
  			System.out.println(System.getProperty("java.class.path"));
  		} catch (ClassNotFoundException e) {
  			// TODO Auto-generated catch block
  			e.printStackTrace();
  		} catch (InstantiationException e) {
  			// TODO Auto-generated catch block
  			e.printStackTrace();
  		} catch (IllegalAccessException e) {
  			// TODO Auto-generated catch block
  			e.printStackTrace();
  		}
  	}

  	@Override
  	public Class<?> loadClass(String name) throws ClassNotFoundException {
  		// TODO Auto-generated method stub
  		return super.loadClass(name);
  	}

  	protected Class<?> findClass(String name) throws ClassNotFoundException {
  		File file = getClassFile(name);
  		try {
  			byte[] bytes = getClassBytes(file);
  			Class<?> c = this.defineClass(name, bytes, 0, bytes.length);
  			return c;
  		} catch (Exception e) {
  			e.printStackTrace();
  		}

  		return super.findClass(name);
  	}

  	private File getClassFile(String name) {
  		File file = new File("/home/senninha/Person.class");
  		return file;
  	}

  	private byte[] getClassBytes(File file) throws Exception {
  		// 这里要读入.class的字节，因此要使用字节流
  		FileInputStream fis = new FileInputStream(file);
  		FileChannel fc = fis.getChannel();
  		ByteArrayOutputStream baos = new ByteArrayOutputStream();
  		WritableByteChannel wbc = Channels.newChannel(baos);
  		ByteBuffer by = ByteBuffer.allocate(1024);

  		while (true) {
  			int i = fc.read(by);
  			if (i == 0 || i == -1)
  				break;
  			by.flip();
  			wbc.write(by);
  			by.clear();
  		}

  		fis.close();

  		return baos.toByteArray();
  	}
  }

  ```

  ​