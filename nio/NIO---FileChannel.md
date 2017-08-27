### NIO---FileChannel

- FileChannel.transferXXX()

```
	fromChannel = new RandomAccessFile(from, "r").getChannel();
	toChannel = new RandomAccessFile(to, "rw").getChannel();
	fromChannel.transferTo(0, fromChannel.size(), toChannel);
```

> 这种使用transfer的方式相比于传统的io有巨大的性能上的优势。
>
> 因为传统的io复制的时候，是这样的：
>
> **硬盘**--->**内核空间**--->**用户空间**--->**执行复制**--->**内核空间**--->**磁盘**
>
> 而channel的方式：
>
> **磁盘**--->**内核空间**--->**磁盘**
>
> 节省了从内核到用户空间复制的时间，下面附录1附带了一个简单的测试demo。



- FileChannel.map

  > map方法是直接映射一部分磁盘文件到内存(**MappedByteBuffer**)中，用户访问这部分数据的时候，省去了从内核空间向用户空间复制的损耗。可以用于大文件的**MD5**校验。

  ```
  raf = new RandomAccessFile(file, "r");
  FileChannel channel = raf.getChannel();
  MappedByteBuffer buffer = null;
  buffer = channel.map(FileChannel.MapMode.READ_ONLY, 10, 1024);
  ```



##### 总结

> 对比于传统io的优势：
>
> 1. 基于channel，可以直接读写
> 2. 通过transferXX，map，可以在复制文件，读取文件的时候提高性能
> 3. 如果直接使用native内存的Buffer，可以减少从内核到用户空间的复制



- 附录1

```
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.nio.channels.FileChannel;

import org.eclipse.jdt.internal.compiler.ast.SynchronizedStatement;

public class FileChannelTest {

	public static void main(String[] args) {
		File from = new File("/home/senninha/Downloads/esmp1.0.war");
		File to = new File("/home/senninha/Downloads/esmp1.0.copy.war");
		File to1 = new File("/home/senninha/Downloads/esmp1.0.copy1.war");
		
		System.out.println(transfer(from, to));
		System.out.println(copyTo(from, to1));
	}

	/**
	 * channel的方式
	 * 
	 * @param from
	 * @param to
	 * @return
	 */
	public static long transfer(File from, File to) {
		long time = System.currentTimeMillis();
		if (from == null || !from.exists() || to == null) {
			throw new IllegalArgumentException();
		} else {
			FileChannel fromChannel = null;
			FileChannel toChannel = null;
			try {
				fromChannel = new RandomAccessFile(from, "r").getChannel();
				toChannel = new RandomAccessFile(to, "rw").getChannel();

				fromChannel.transferTo(0, fromChannel.size(), toChannel);
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} finally {
				try {
					if (fromChannel != null && fromChannel.isOpen()) {
						fromChannel.close();
					}

					if (toChannel != null && toChannel.isOpen()) {
						toChannel.close();
					}
				} catch (Exception e) {
					System.out.println(e.toString());
				}
			}
		}

		return System.currentTimeMillis() - time;
	}

	/**
	 * 传统io的方式
	 * @param from
	 * @param to
	 * @return
	 */
	public static long copyTo(File from, File to) {
		long start = System.currentTimeMillis();
		if (from == null || !from.exists() || to == null) {
			throw new IllegalArgumentException();
		}

		InputStream is = null;
		OutputStream os = null;
		try {
			is = new FileInputStream(from);
			os = new FileOutputStream(to);

			byte[] b = new byte[1024 * 1024];
			int len = is.read(b);

			while (len != -1) {
				os.write(b, 0, len);
				len = is.read(b);
			}
		} catch (Exception e) {
			System.out.println(e.toString());
		} finally {
			try {
				if (is != null) {
					is.close();
				}

				if (os != null) {
					os.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return System.currentTimeMillis() - start;
	}
}

```



> 运行时间如下：
>
> 33
> 738
>
> 差了一个数量级。