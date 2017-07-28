    springmvc下的文件上传比在struts2下简单多了，只需要几行代码就可以解决，但是在我的项目里却一直报：
>HTTP Status 400 - Required request part 'uploadFile' is not present

仔细核对了上传参数名发现一直没错，最后发现是因为是没有xml的配置，在javaconfig里的配置没有根据容器要求的名字去命名bean。狗血。

####错误的地方：
```
    /*
     * resolve the multipart file upload.
     */
	@Bean
	public MultipartResolver getResolver(){
                //就是这里，我一开始用resolver命名，导致容易无法识别。
		CommonsMultipartResolver resolver = new CommonsMultipartResolver();
		multipartResolver.setDefaultEncoding("utf-8");
		System.out.println("init resolver...");
		return multipartResolver;
	}
```

###更正：
```
    /*
     * resolve the multipart file upload.
     */
	@Bean
	public MultipartResolver getResolver(){
                //更改为multipartResolver即可。
		CommonsMultipartResolver multipartResolver = new CommonsMultipartResolver();
		multipartResolver.setDefaultEncoding("utf-8");
		System.out.println("init resolver...");
		return multipartResolver;
	}
```
###附上控制器的代码：
```

@Controller
public class UploadController {

	@RequestMapping(value = "/testUpload", method = RequestMethod.POST)
	public @ResponseBody Map<String, Object> uploadFile(
			@RequestPart(name = "uploadFile") MultipartFile file) {
		Map<String, Object> map = new HashMap<String, Object>();

		File dir = new File(File.separator + "home" + File.separator + "senninha");
		if (!dir.exists()) {
			dir.mkdirs();
		}

		File saveFile = new File(dir + File.separator + file.getOriginalFilename());
		BufferedOutputStream os = null;
		try {
			os = new BufferedOutputStream(new FileOutputStream(saveFile));
			InputStream is = file.getInputStream();
			byte[] b = new byte[1024];
			int i = -1;
			while((i = is.read(b)) != -1){
				os.write(b,0,i);
			}
			map.put("code", 0);
			map.put("info", "upload success!");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			try {
				if (os != null) {
					os.close();
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		return map;
	}
}
```
###简单jsp页面：
```
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<html>
<head>
<title>Upload File Request Page</title>
</head>
<body>
	<form method="POST" action="testUpload" enctype="multipart/form-data">
		File to upload: <input type="file" name="uploadFile" id = "uploadFile" class = "uploadFile">
		<input type="submit" value="Upload"> Press here to upload the file!
	</form>	
</body>
</html>
```

ok可以上传啦。
