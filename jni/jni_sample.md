### JNI Sample
先来一个最简单的JNI调用C代码的HelloWorld

#### 1.Java代码
```
public class Hello{
	static{
		System.loadLibrary("Hello");	//加载之后生成的库
	}

	public native void hello();

	public static void main(String[] args){
		new Hello().hello();
	}
}
```

#### 2.生成对应的头文件
编译Hello.java --> Hello.class
然后生成对应的头文件
```
	javah Hello
```
生成**Hello.h**的头文件

#### 3.编写对应的c代码
复制Hello.h头文件里的方法签名进c里面
Hello.c
```
#include <stdio.h>
#include <jni.h>
#include "Hello.h"

JNIEXPORT void JNICALL Java_Hello_hello
  (JNIEnv *env, jobject obj){
	printf("hello world\n");
}

```

#### 4.编译生成对应的库
```
	gcc -I/usr/lib/jvm/java-8-openjdk-amd64/include/ -I/usr/lib/jvm/java-8-openjdk-amd64/include/linux -o libHello.so -shared Hello.c
```
然后就生成了**libHello.so**库文件
对应开头我们写的:
```
	System.loadLibrary("Hello");
```
并不需要写lib和.so就行

#### 5.运行
```
	java -Djava.library.path=. Hello
```
然后就可以看到**Hello World**了
