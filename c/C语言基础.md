### C语言基础

- 安装一个ide

  ```
  apt-get install anjuta
  apt-get install libtool-bin
  ```

- 头文件

  ```c
  #include <stdio.h>
  //引入头文件，相当于java的import语句，引入的是standard io库，这个库是编译器本身提供的
  ```

- 输入输出

  - 输入scanf

    ```c
    int a;
    scanf("%d%d", &a &a);
    //&a表示变量a在内存中的位置
    ```
    ```c
    char ch;
    ch = getchar();
    //getchar函数
    ```

    ​

  - 输出printf

    ```c
    int a = 10;
    printf("%d", a);
    ```

    ```c
    putchar('a');
    //putchar函数
    ```

    ​

    其他占位符：

    |   占位符   | 含义                            |
    | :-----: | ----------------------------- |
    |   %d    | int型的占位符                      |
    |   %ld   | long型                         |
    |   %f    | float，7.2f表示保留两位小数，输出的数据总共占7列 |
    | %-10.2f | 表示输出数位不足的时候，往左边靠，右边用空格不足      |
    |   %lf   | double float                  |
    |   %c    | char型                         |
    |   %o    | 八进制                           |
    |   %x    | 十六进制(以上适用于int或者long)          |


  ​

- 字符串与char数组

  > 字符串在c中是以char数组表示的。

  ```c
  char[] ch = {'s', 'e', 'n', 'n', 'i', 'n', 'h', 'a', '\0'};
  //等价于
  char[] ch = "senninha"; 
  //\0表示的是结束标志，默认的上面的后者在写入内存的时候会默认添加\0结束符。
  ```

  一些标准的字符串处理函数

  ```c
  puts();//输出一个字符串
  gets();
  strcat(char[], char[]);//把参数二的字符串拼接到参数一上去,字符串1的数组必须足够大
  strcpy(char[], char[]);//复制字符串2到字符串1，字符串1必须足够大
  strncpy(char[], char[], int);//把第二个字符串的前n个字符复制到第一个字符去
  strcmp(char[], char[]);//字符串比较 ，大于返回大于1
  strlen(char[]);//返回字符串的长度。
  strlwr(char[]);//返回小写字母
  strupr(char[]);//返回大些字母，upper
  ```




- 结构体

  ```c
  struct structName{
    int a;
    int b;
    char[] ch;
  }
  ```

  结构体类似java里的封装，结构体的**sizeof**会自动补齐为字节4的倍数。还有需要注意的是，结构体里的字符串赋值不能直接用指针的方式：

  ```c
  structName.ch = "xx";//不可以
  strcpy(structName.ch, "xx");//可以
  ```

  另外，一个结构体如果是指针的话，访问结构体内的数据需要用**->**符号：

  ```
  struct sturctName *s;
  char ch[] = s->ch;
  ```

  ​

- 共用结构体

  ```c
  union unionName{
  	int a;
  	int b;
  	char ch[10];
  };
  ```

  节约内存空间，如果先存了a，然后存ch，会占掉a的存值。

- 位域

  ```c
  struct bs{
    int a:1;
    int b:2;
  }

  void bstest(){
  	struct bs bbs;
  	bbs.a = 0;
  	bbs.b = 2;
  	printf("a:%d,b:%d", bbs.a, bbs.b);
  }
  ```

  以上表示用一位表示a的变量，节省空间