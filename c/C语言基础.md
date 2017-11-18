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



- 动态分配内存

  为某个指针动态分配内存大小

  ```c
  void malloctest(){
  	char *ch;
  	ch = malloc(200 * sizeof(char));
  	if(ch == NULL){
  		printf("unbale to malloc memory");
  	}else{
  		printf("malloc success");
  		*ch = 's';
  		printf("memory:%s",ch);
  	}
  }
  //分配内存还可用用calloc函数，与上述函数的区别是，这个函数可以为所分配的内存写0，而malloc不可以。
  ```

  ​

  重新分配内存

  ```c
  void realloctest(){
  	char *ch;
  	ch = calloc(10, 10);
  	printf("ch's address %d\n", &ch);

  	ch = realloc(ch, 110);

  	printf("after realloc ,address is %d", &ch);
  }
  ```

  如果重新分配到大小为0,那么等价于使用**free()**函数，如果小于原来的内存，那么重分配后在原来的那部分数据不变，如果大于原来的内存，那么新增加的内存不会被初始化。

  释放内存

  ```c
  free(*pointer);
  //在内存不需要的时候释放掉内存
  ```

  ​

- 命令行传递参数

  ```c
  void command(char argc, char *argv[]){
  	printf("program's name is %s\n", argv[0]);
  	if(argc == 1){
  		printf("need a argument\n");
  	}else{
  		printf("argument is %s\n", argv[1]);
  	}
  }


  int main(char argc, char *argv[])
  {
  	command (argc, argv);
  }
  ```

  **argc**默认为1,如果有参数的话，就会往上加1，**argv**是一个数组指针，**argv[0]**存放的是程序名，接下去存放的就是具体的命令行传入参数了。



- 指针

  指针简单来说指的是获取某个数据才内存里的位置。

  ```c
  void pointertest(int *i){
  	*i = 3;
  	printf("pointertest已更改值大小");
  }

  void changetest(int i){
  	i = 3;
  	printf("形式参数在内存中的位置:%d\n", &i);
  }


  int main(char argc, char *argv[])
  {
  	int i = 4;
  	printf("更改前参数的大小：%d\n", i);
  	pointertest(&i);
  	printf("更改完毕后参数的大小：%d\n", i);

  	i = 4;
  	printf("调用前：%d\n", i);
  	changetest(i);
  	printf("调用后：%d\n", i);
  	printf("传入参数在内存中的位置:%d\n", &i);
  	
  }

  输出：
  ----------------------------------------------
  更改前参数的大小：4
  pointertest已更改值大小更改完毕后参数的大小：3
  调用前：4
  形式参数在内存中的位置:-875611700
  调用后：4
  传入参数在内存中的位置:-875611652
  ```

  上述**pointertest()**就获取了**i**的指针，然后在给函数传入参数的时候，可以传入指针，然后直接更改指针对应的内存位置的值。然后传入值的地方也同时被改变，因为直接改的是**内存值**。而**test()**是用形式传参的形式，进入**test()**后的i在内存中的位置实际上已经不是传入的时候在内存中的位置了。

  数组指针

  ```c
  void pointerarray(){
  	int array[] = {1, 3, 5};
  	printf("array:%d,%d,%d\n", *array, *(array + 1), *(array + 2));
  	printf("我其实是一个指针，地址是%d,%d", array, array + 1);
    	//这里的+1,会自动往指针上增加该指针数据类型应该加的字节数，比如这里是int，所以是+4,见下面的输出
  }

  输出：
  ----------------------------------------------
  array:1,3,5
  我其实是一个指针，地址是-443877180,-443877176
  ----------------------------------------------

  ```

  初始化一个数组其实就是返回一个数组里第一个位置的**指针**，以指针为原始操作的话，可以把array[0]这种方式当成一种语法糖。上述的方式，可以打印出这个数组的所有值。

  指针数组

  ```c
  void pointerarray(){
  	int array[] = {1, 3, 5};
  	int *parray[] ={array, array + 1, array + 2};

  	printf("%d,%d,%d", *(*parray), *(parray[1]), *(*(parray + 2)));
    	//看一下这个风骚的写法，就能明白这里面存的就是指针。。
  }
  输出：
  ----------------------------------------------
  1,3,5
  ----------------------------------------------
  ```

  所谓指针数组，就是一个储存指针的数组。。

  再来捋一下：

  ```
  int *pa[];//这个是指针数组，先是(pa[])，后才运算到指针，指针数组，储存指针的数组
  int ap[];//这个是数组指针，表示的是数组的指针;
  int (*pa1)[] = &pa; //这是个指针，类型是数组
  //访问数据变成这样：*(*pa1)就能访问到pa[0]的数据啦。
  ```



- 函数指针

  函数名也是一个指针，那么可以用一个指针来表示一个函数

  ```c
  void (*f)(int) = function_name;
  //void表示返回值的类型，(*f)可以自定义，然后(int)表示参数，等号右边是函数名。

  //调用
  f(1);
  //有个奇怪的点，必须函数写在指针函数前才能正常使用，如下：

  #include <stdio.h>
  #include <stdlib.h>

  void pointer1(int i){
  	puts("这里是指针函数1");
  }

  int main(void) {
  	void (*e)(int) = pointer1;
  	e(1);
  }
  ```

  ​

