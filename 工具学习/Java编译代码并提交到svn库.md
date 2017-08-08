### Java编译代码并提交到svn库

> 上了两星期班终于开始写代码了，虽然是个小工具，这个工具是前端上传几个.java文件，然后编译发布到svn库



- 上传代码的问题

  > 用的框架是JFinal，感觉挺好上手，什么好像都封装好了，还有获取多个文件的api，然鹅上传多个文件的时候有bug，同名的文件只能获取到一个，最后用了commons-fileuploadd.jar解决

  ```java
  @WebServlet("/uploadServlet")
  public class UploadServlet extends HttpServlet {
  	
      // 上传文件存储目录
      private static final String UPLOAD_DIRECTORY = "upload";
   
      // 上传配置
      private static final int MEMORY_THRESHOLD   = 1024 * 1024 * 3;  // 3MB
      private static final int MAX_FILE_SIZE      = 1024 * 1024 * 40; // 40MB
      private static final int MAX_REQUEST_SIZE   = 1024 * 1024 * 50; // 50MB
      
  	@Override
  	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
  		// TODO Auto-generated method stub
  			// 检测是否为多媒体上传
  			if (!ServletFileUpload.isMultipartContent(request)) {
  			    // 如果不是则停止
  			    PrintWriter writer = response.getWriter();
  			    writer.println("Error: 表单必须包含 enctype=multipart/form-data");
  			    writer.flush();
  			    return;
  			}
  	 
  	        // 配置上传参数
  	        DiskFileItemFactory factory = new DiskFileItemFactory();
  	        // 设置内存临界值 - 超过后将产生临时文件并存储于临时目录中
  	        factory.setSizeThreshold(MEMORY_THRESHOLD);
  	        // 设置临时存储目录
  	        factory.setRepository(new File(System.getProperty("java.io.tmpdir")));
  	 
  	        ServletFileUpload upload = new ServletFileUpload(factory);
  	         
  	        // 设置最大文件上传值
  	        upload.setFileSizeMax(MAX_FILE_SIZE);
  	         
  	        // 设置最大请求值 (包含文件和表单数据)
  	        upload.setSizeMax(MAX_REQUEST_SIZE);
  	        
  	        // 中文处理
  	        upload.setHeaderEncoding("UTF-8"); 

  	        // 构造临时路径来存储上传的文件
  	        // 这个路径相对当前应用的目录
  	        String uploadPath = "/tmp" + File.separator + UPLOAD_DIRECTORY;
  	       
  	         
  	        // 如果目录不存在则创建
  	        File uploadDir = new File(uploadPath);
  	        if (!uploadDir.exists()) {
  	            uploadDir.mkdir();
  	        }
  	 
  	        try {
  	            // 解析请求的内容提取文件数据
  	            @SuppressWarnings("unchecked")
  	            List<FileItem> formItems = upload.parseRequest(request);
  	 
  	            if (formItems != null && formItems.size() > 0) {
  	                // 迭代表单数据
  	                for (FileItem item : formItems) {
  	                    // 处理不在表单中的字段
  	                    if (!item.isFormField()) {
  	                        String fileName = new File(item.getName()).getName();
  	                        String filePath = uploadPath + File.separator + fileName;
  	                        File storeFile = new File(filePath);
  	                        // 在控制台输出文件的上传路径
  	                        System.out.println(filePath);
  	                        // 保存文件到硬盘
  	                        item.write(storeFile);
  	                        request.setAttribute("message",
  	                            "文件上传成功!");
  	                    }
  	                }
  	            }
  	        } catch (Exception ex) {
  	            request.setAttribute("message",
  	                    "错误信息: " + ex.getMessage());
  	        }
  	        // 跳转到 message.jsp
  	        getServletContext().getRequestDispatcher("/message.jsp").forward(
  	                request, response);
  	    }	
  }
  ```

  还有一个问题就是表单设置了multipart后无法再通过req.getParameter()去获取表单里的普通参数了，可以在这里进行处理:

  ```java
   for (FileItem item : formItems) {
  	                    // 处理文件
  	                    if (!item.isFormField()) {
  	                       	}else{
                              //处理普通的参数,还要做一下iso-8859-1的编码转换
  	                        }
  	                }
  ```



- 编译java文件

  ```
  JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
  int result = compiler.run(null, null, null, "java文件路径");
  //编译成功的话result为0
  //编译后将会在原路经输出.class文件，需要注意的是，如果原路径以及存在该java文件的话
  //并不会覆盖，而是在后编译的文件末尾加1
  ```



- java代码操作cmd

  > 这点是第一次接触，还有这种操作。。

```java
	
	/**
	 * java执行命令行
	 * @param command 命令
	 * @return 返回执行后的输出,异常返回null
	 */
	public static String command(String[] command){
		if(command == null || command.length == 0) {
			throw new NullPointerException();
		}
		String os = System.getProperty("os.name");//System.out.println(Charset.defaultCharset());可以获取系统默认编码
		InputStream is = null;		
		StringBuilder sb = new StringBuilder();
		if(os.contains("Windows")) {//如果是windows，添加windows的命令
			List<String> list = new ArrayList<String>();
			list.add("cmd.exe");
			list.add("/c");
			list.addAll(Arrays.asList(command));
			command = (String[]) list.toArray();
		}
		
		try {
			Process pro = Runtime.getRuntime().exec(command);//处理输出流即可
			is = pro.getInputStream();   
			byte[] b = new byte[1024 * 1024];
			int len = 0;
			while((len = is.read(b)) != -1) {
				sb.append(new String(b, 0, len, "utf-8"));
			}
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}	finally {
			if(is != null) {
				try {
					is.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return sb.toString();
	}

//测试,输出了maven的版本
public static void main(String[] args) {
		// TODO Auto-generated method stub
		String[] command = new String[2];
		command[0] = "mvn";
		command[1] = "-version";
		System.out.println(command(command));
	}
```

> Apache Maven 3.5.0 (ff8f5e7444045639af65f6095c62210b5713f426; 2017-04-04T03:39:06+08:00)
> Maven home: /home/senninha/soft/apache-maven-3.5.0
> Java version: 1.8.0_144, vendor: Oracle Corporation
> Java home: /home/senninha/soft/jdk/jdk1.8.0_144/jre
> Default locale: zh_CN, platform encoding: UTF-8
> OS name: "linux", version: "4.9.0-3-amd64", arch: "amd64", family: "unix"
>
> 好玩，shell脚本不会写可以搞这个啊，不过这个要io输出，效率肯定。。。
>
> 扯远了，svn的add好蛋疼，不能直接在根目录add ./这样，如果在当前目录有其他的文件已经加入了版本库，这个操作会报错，只能一个一个增加。。略蛋疼。