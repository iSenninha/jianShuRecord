AtomicReference 源码学习

前面写了原子类的使用([传送门](http://www.jianshu.com/p/c62c6f8a762f)),现在直接撸一下源码吧

先看一下如何使用AR
```
	        AtomicReference<String> ar = new AtomicReference<String>();
		ar.set("senninha");
		//CAS操作更新
		ar.compareAndSet("senninha", "senninha1");
```

AR类只有200多行源代码,一下子就能撸完,先看一下成员变量吧:
```
    
    private static final long serialVersionUID = -1848883965231344442L;
    //unsafe类,提供cas操作的功能
    private static final Unsafe unsafe = Unsafe.getUnsafe();
    //value变量的偏移地址,说的就是下面那个value,这个偏移地址在static块里初始化,见下面
    private static final long valueOffset;
    //实际传入需要原子操作的那个类实例
    private volatile V value;

```

类装载的时候初始化偏移地址:
```
 static {
        try {
            valueOffset = unsafe.objectFieldOffset
                (AtomicReference.class.getDeclaredField("value"));
        } catch (Exception ex) { throw new Error(ex); }
    }
```

compareAndSet方法
```
/**
*也没什么好说的,就是调用Unsafe的cas操作,传入对象,expect值,偏移地址,需要更新的值,即可,如果更新成功,返回true,如果失败,返回false
public final boolean compareAndSet(V expect, V update) {
        return unsafe.compareAndSwapObject(this, valueOffset, expect, update);
    }
```
> 这里有个坑就是,对于String变量来说,必须是对象相同才视为相同,而不是字符串的内容相同就可以相同,如下:

```
		AtomicReference<String> ar = new AtomicReference<String>();
		ar.set("senninha");
		System.out.println(ar.compareAndSet(new String("senninha"), "senninha1"));//false

```

weakCompareAndSet方法

```
   //没看出和上面那个有啥区别
   public final boolean weakCompareAndSet(V expect, V update) {
        return unsafe.compareAndSwapObject(this, valueOffset, expect, update);
    }
```

还有写奇怪的自旋set的方法,没找到UnaryOperator的实现类...反正就是自旋操作
```
  public final V getAndUpdate(UnaryOperator<V> updateFunction) {
        V prev, next;
        do {
            prev = get();
            next = updateFunction.apply(prev);
        } while (!compareAndSet(prev, next));
        return prev;
    }
```
