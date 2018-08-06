### 使用第三方类库
> c语言中如何使用第三方类库。

#### 1.install对应的依赖
在debian系下，直接apt就行，不了解的库建议谷歌一下，比如我需要**libcurl**，直接安装libcurl，然后一直找不到**curl/curl.h**头文件，其实是要apt **libcurl3-gnutls/stable,stable,now**

#### 2.编译时加入依赖库
加头文件这个不用说了吧，然后编译的时候需要加一下
```
gcc -llibName
```

如果是用cmake的话，需要在对应的编译下加:
```
	add_executable(curlTest http/Curl.c)
	TARGET_LINK_LIBRARIES(curlTest curl)
```

总的来说就是这样咯。
