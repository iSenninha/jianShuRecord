### C文件读取

- 结构体FILE

  标准库中封装了**FILE**这个结构体代表文件，通过**fopen()**函数可以打开：

  ```c
  FILE *file;
  fopen(file, *char)
  //第二个参数代表读写模式，"w+”表示读写，如果文件不存在，直接新建，a表示向文件末尾追加
  ```



- 写入数据

  获取结构体FILE的指针后，按以下方式写入文件

  ```c
  FILE *file;
  fopen(file, "w+");
  fputs(file, "内容");
  fclose(file);//关闭文件,同时指针变为NULL
  ```



- 读取数据

  获取FILE指针后，读取数据：

  ```c
  FILE *file;
  char buf[10];//用来储存数据的缓冲区
  char *flag;//flag变量，标识是否读取到了文件末尾
  while((flag = fgets(ch, 10, file)) != NULL){
    printf("%s", ch);
  }
  fclose(file);
  ```

  fgets()会返回一个char型的指针变量，这个指针变量如果在文件未到末尾的时候，指向的就是缓冲区ch的地址，如果到了文件末尾，返回NULL。