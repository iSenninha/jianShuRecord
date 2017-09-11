### SuppressWarnings压制编译器警告

> 在使用eclipse的时候，总是会在侧边出现各种黄色的警告框。有些是不需要的，我们可以用**SuppressWarnings**压制

- 压制所有的警告

  ```
  @SuppressWarnnings("all")
  ```

  ​

- 压制泛型未指明与变量(方法)未使用

  ```
  		@SuppressWarnings({"rawtypes","unused"})
  		Collection c = new ArrayList<String>();
  ```

  ​

- 压制序列化id冲突警告

  ```
  @SuppressWarnings("serial")
  ```



其他的暂时没用到，引用自[IBM](https://www.ibm.com/support/knowledgecenter/zh-tw/SSRTLW_9.5.0/org.eclipse.jdt.doc.user/tasks/task-suppress_warnings.htm)。