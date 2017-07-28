atomic包下几个类的用法

#####1.原子更新引用类型
> 以原子的方式更新某个引用对象,可以使用如下的类去实现
AtomicReference
使用过程中,更新的时候要避免错误使用

```
/**
 * 原子更新整个引用类型
 * @author senninha
 *
 */
public class AtomicReferenceTest {
	public AtomicReference<User>  user = new AtomicReference<User>(null);
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		AtomicReferenceTest t = new AtomicReferenceTest();
		t.user.set(new User("senninha","21"));
		User user = t.user.get();
		//错误的更新方法
		user.setAge("10");
		//正确的更新方法
		user = new User("senninha","22");
		t.user.set(user);
	}

}

class User{
	private String username;
	public User(String username, String age) {
		super();
		this.username = username;
		this.age = age;
	}
	public String getUsername() {
		return username;
	}
	public String getAge() {
		return age;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public void setAge(String age) {
		this.age = age;
	}
	private String age;
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("User [username=");
		builder.append(username);
		builder.append(", age=");
		builder.append(age);
		builder.append("]");
		return builder.toString();
	}
	
}
```

#####2.带时间戳的原子更新
> 避免更新时候出现ABA这样的错误,使用带时间戳的原子更新方式

```
/**
*
*
**/
public class AtomicStampReferenceTest {
	public AtomicStampedReference<User> user = null;
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		User u = new User("senninha","21");
		AtomicStampReferenceTest aft = new AtomicStampReferenceTest();
		//这里可以用时间戳来表示0
		aft.user = new AtomicStampedReference<User>(u, 0);
		u = new User("senninha","22");
		//aft.user.set(u,System.currentTimeMillis());
		aft.user.set(u, aft.user.getStamp() + 1);
		System.out.println(aft.user.getStamp() + " " + aft.user.getReference());
	}

}

```
#####3.原子更新类中某个字段
> 如1那里,其实要更新的只是age字段,就可以使用原子更新某个字段的方法
AtomicIntegerFieldUpdater
AtomicLongFieldUpdater
AtomicReferenceFieldUpdater
需要把他们声明为public volatile类型

```
	/**
	 * 只更新类中的某个字段的时候
	 * 只需要把要更新的那个字段设置为public volatile,利用反射来实现CAS操作
	 */
	public static void atomicReferenceFieldUpdater(){
	//User类中的age字段需要进行原子操作,类型是String,字段名是age
		AtomicReferenceFieldUpdater arfu = AtomicReferenceFieldUpdater.newUpdater(User.class, String.class, "age");
		User u = new User("senninha","12");
		arfu.compareAndSet(u, u.age, "13");
		System.out.println(u.getAge());
	}
}

class User{
	public String username;
	public volatile String age;
	
	public User(String username, String age) {
		super();
		this.username = username;
		this.age = age;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("User [username=");
		builder.append(username);
		builder.append(", age=");
		builder.append(age);
		builder.append("]");
		return builder.toString();
	}
	
}
```

#####4.原子更新数组
> 传入后的会重新复制一份数组的拷贝,所以可以用原数组的值作为compare的比较对象.
```
	/**
	 * 原子更新数组
	 */
	public static void atomicArrayUpdater(){
		User[] user = new User[2];
		user[0] = new User("senninha", "1");
		user[1] = new User("senninha", "2");
		AtomicReferenceArray<User> ara = new AtomicReferenceArray<User>(user);
		//index,更新前的expect对象,如果expect传入新的对象
		ara.weakCompareAndSet(0, user[0], new User("senninha","3"));
		System.out.println(user[0]);
		System.out.println(ara.get(0));
	}
```
