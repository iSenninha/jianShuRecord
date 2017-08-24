### ThreadLocal学习

> One possible (and common) use is when you have some object that is not thread-safe, but you want to avoid [synchronizing](https://docs.oracle.com/javase/tutorial/essential/concurrency/sync.html) access to that object (I'm looking at you, [SimpleDateFormat](https://docs.oracle.com/javase/8/docs/api/java/text/SimpleDateFormat.html)). Instead, give each thread its own instance of the object.([from StackOverflow](https://stackoverflow.com/questions/817856/when-and-how-should-i-use-a-threadlocal-variable))
>
> 以上道出了ThreadLocal的使用场景，另外，尽管ThreadLocal不是JUC包下的，但是作为并发类的api，就暂且放在这个目录下。 
>
> 先来猜测一下，这个线程私有变量是如何实现的，是ThreadLocal里维护一个Map，然后根据不同的thread-id作为key来维护吗？

- 典型使用

```
public class Foo
{
    // SimpleDateFormat is not thread-safe, so give one to each thread
    private static final ThreadLocal<SimpleDateFormat> formatter = new ThreadLocal<SimpleDateFormat>(){
        @Override
        protected SimpleDateFormat initialValue()
        {
            return new SimpleDateFormat("yyyyMMdd HHmm");
        }
    };//设置初始化值

    public String formatIt(Date date)
    {
        return formatter.get().format(date);
    }
}
```



- get方法

```
    public T get() {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);//**1**从当前thread对象里获取ThreadLocalMap？？？
        if (map != null) {
            ThreadLocalMap.Entry e = map.getEntry(this);
            if (e != null) {//如果没有初始化值，跳入这里进行初始化
                @SuppressWarnings("unchecked")
                T result = (T)e.value;
                return result;
            }
        }
        return setInitialValue();//就是这里，重写的initalValue()方法就是在这里执行。
    }
```

**1.** ThreadLocalMap是从**Thread**里获取的，就是说，维护**Map**的并不是**ThreadLocal**，开头的猜测是**错**的。不同线程的示例是维护在对应线程的**Thread**实例里，然后通过**ThreadLocal**实例作为**key**从对应Thread里维护的map获取到对应的实例。为什么要在Thread里维护一个Map，而不是在ThreadLocal里维护呢？我的理解是，一旦在ThreadLocal里维护一个Map，就会导致并发操作这个Map。。。



那么问题来了，Thread维护的这个map是在何时初始化的呢？

- Thread初始化ThreadLocalMap

```
    public void set(T value) {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null)
            map.set(this, value);
        else
            createMap(t, value);
    }
```

ThreadLocal设置或者获取value的时候如果这个map没有被初始化，那么将执行初始化，但是，如果是主线程的话，是直接在这个私有的init方法里初始化的

而且这个ThreadLocalMap并不是简单聚合一个HashMap去实现的，而是使用一个继承**WeakReference<ThreadLocal>**Entry去实现的:

```
 static class Entry extends WeakReference<ThreadLocal<?>> {
            /** The value associated with this ThreadLocal. */
            Object value;

            Entry(ThreadLocal<?> k, Object v) {
                super(k);
                value = v;
            }
        }
```

为什么是用一个弱引用去实现呢？弱引用是一旦其他强引用消失，在垃圾回收的时候就会被回收回去。

就是说，一旦ThreadLocal失去强引用，就会在下次辣鸡回收的时候被回收回去，然后通过下面的清除算法，把entry给清除掉。

其实，如果不采用弱引用的话，只有在一个线程Thread挂掉的时候才会释放掉ThreadLocalMap里的所有数据，但是大部分线程都是run到停止的，如果不用弱引用，可能会导致大量的辣鸡无法回收。

同时，ThreadLocalMap会去清理掉一些失效的ThreadLocalMap，这是在set()的时候调用的代码，如下：

```
  private boolean cleanSomeSlots(int i, int n) {
            boolean removed = false;
            Entry[] tab = table;
            int len = tab.length;
            do {
                i = nextIndex(i, len);
                Entry e = tab[i];
                if (e != null && e.get() == null) {
                    n = len;
                    removed = true;
                    i = expungeStaleEntry(i);
                }
            } while ( (n >>>= 1) != 0);
            return removed;
        }
   //启发式算法
```



- InheritableThreadLocal

  另外，其实Thread里包含着一个另外ThreadLocalMap实例，它叫inheritableThreadLocalMap，在Thread初始化的时候，就已经偷偷从初始化Thread的当前线程里加载它的ThreadLocalMap数据了，并且从父Thread复制数据的方法是在ThreadLocal里：

  ```
   private void init(ThreadGroup g, Runnable target, String name,
                        long stackSize) {
          init(g, target, name, stackSize, null, true);
      }
      
   static ThreadLocalMap createInheritedMap(ThreadLocalMap parentMap) {
          return new ThreadLocalMap(parentMap);
      }
      
       /**
           * Construct a new map including all Inheritable ThreadLocals
           * from given parent map. Called only by createInheritedMap.
           *
           * @param parentMap the map associated with parent thread.
           */
          private ThreadLocalMap(ThreadLocalMap parentMap) {
              Entry[] parentTable = parentMap.table;
              int len = parentTable.length;
              setThreshold(len);
              table = new Entry[len];

              for (int j = 0; j < len; j++) {
                  Entry e = parentTable[j];
                  if (e != null) {
                      @SuppressWarnings("unchecked")
                      ThreadLocal<Object> key = (ThreadLocal<Object>) e.get();
                      if (key != null) {
                          Object value = key.childValue(e.value);
                          Entry c = new Entry(key, value);
                          int h = key.threadLocalHashCode & (len - 1);
                          while (table[h] != null)
                              h = nextIndex(h, len);
                          table[h] = c;
                          size++;
                      }
                  }
              }
          }
  ```

  ​

  然后搞一个类继承ThreadLocal，叫InheritableThreadLocal，重写getMap，成功偷梁换柱：

  ```
      ThreadLocalMap getMap(Thread t) {
         return t.inheritableThreadLocals;
      }
  ```

  需要注意的是，主线程没有父线程可以去继承，所以它的初始化的时候，inheritableThreadLocalMap是空的。非主线程的话，是默认从初始化它的线程里就初始化inheritableThreadLocalMap的



- 总结

> Thread示例里维护一个ThreadLocalMap实例，以ThreadLocal为key，线程自己的变量作为value。这里是用弱引用储存**ThreadLocal**，防止在线程未死的情况下产生大量辣鸡。
>
> 同时Thread里还藏着一个继承自父类线程的ThreadLocalMap变量。