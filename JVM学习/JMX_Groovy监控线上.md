### JMX_Groovy进行线上代码调试监控
JMX即Java Management Extensions,可以在运行时提供监控接口。而Groovy则是JVM上的一门语言。
实际上这篇文章分两部分，一部分是JMX暴露MBean接口;另外一部分是使用Groovy动态脚本加载执行监控逻辑。

#### 1 Maven依赖
```
        <dependency>
            <groupId>org.codehaus.groovy</groupId>
            <artifactId>groovy-jsr223</artifactId>
            <version>2.4.13</version>
        </dependency>
```
这里的依赖主要是为了使用Groovy脚本引擎。

#### 2 JMX部分
暴露MBean，注册MBean
- 接口
```
/**
 * Coded by senninha on 18-12-21
 */
public interface SenninhaRuntimeBean {
    String runCode(String pwd, String code);
}
```

- 实现上述接口
```
package cn.senninha.web.jmx;

import groovy.util.GroovyScriptEngine;
import org.codehaus.groovy.jsr223.GroovyScriptEngineImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineFactory;
import javax.script.ScriptEngineManager;
import java.io.IOException;

/**
 * Coded by senninha on 18-12-21
 */
public class SenninhaRuntime implements SenninhaRuntimeBean {
    private Logger logger = LoggerFactory.getLogger(SenninhaRuntime.class);
    private GroovyScriptEngineImpl engine = new GroovyScriptEngineImpl(new groovy.lang.GroovyClassLoader());

    public SenninhaRuntime(){
	    try{
		Class.forName(org.codehaus.groovy.jsr223.GroovyScriptEngineImpl.class.getName());
	    } catch(Exception e){
		logger.error("加载groovy脚本引擎失败");
	    }

    }

    @Override
    public String runCode(String pwd, String code) {
	// Code
	}
```

- 注册
```
            MBeanServer mBeanServer = ManagementFactory.getPlatformMBeanServer();
            try {
                SenninhaRuntime object = new SenninhaRuntime();
                StandardMBean standardMBean = new StandardMBean(object, SenninhaRuntimeBean.class);
                mBeanServer.registerMBean(standardMBean, new ObjectName("cn.senninha.mbean:type=SenninhaRuntime"));
            } catch (Exception e) {
                LoggerFactory.getLogger(WebApplication.class).error("注册mbean失败" + e.getMessage());
            }
```

- 配置启动参数
```
java -Dcom.sun.management.jmxremote.port=6666 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false
```
主要是配置启动的端口,可以让远程客户端也能连接。


#### 3 Groovy部分
使用groovy的引擎动态跑想要跑代码查询内存数据
```
    @Override
    public String runCode(String pwd, String code) {
        try {
            GroovyScriptEngine groovyScriptEngine = new GroovyScriptEngine(new String[]{"."});
        } catch (IOException e) {
            logger.error(e.getMessage(), e);
        }
        if(pwd == null || !pwd.equals("跑得比西方记者还快")){
            return "图样图神破";
        }
        ScriptEngineManager scriptEngineManager = new ScriptEngineManager();
        for (ScriptEngineFactory scriptEngineFactory : scriptEngineManager.getEngineFactories()) {
            logger.error(scriptEngineFactory.getEngineName());
        }
        ScriptEngine groovy = scriptEngineManager.getEngineByName("Groovy"); if (groovy == null) {
            groovy = engine;
        }
        try {
            logger.error("传入:" + code);
            if(groovy == null){
                logger.error("groovy is null");
                return "";
            }
            Object eval = groovy.eval(code);
            String s = String.valueOf(eval);
            logger.error(s);
            return s;
        } catch (Throwable e) {
            logger.error("执行:" + code + "出错:" + e.getMessage(), e);
        }
        return null;
    }
 }
```

springboot下脚本引擎管理器找不到Groovy，所以这里显式去加载脚本引擎。


#### 4 客户端连接JMX
##### 4.1 JConsole连接
直接使用**JDK**自带的工具**JConsole**连接暴露出来的JMX服务即可。然后在暴露出来的MBean接口上操作**runCode()**。
这个方法有个很大的问题是，你得写好代码复制过来，有点傻。。


##### 4.2 代码直连JMX
通过代码直接连接JMX
```
package cn.senninha.web.jmx;

import javax.management.MBeanServerConnection;
import javax.management.ObjectName;
import javax.management.remote.JMXConnector;
import javax.management.remote.JMXConnectorFactory;
import javax.management.remote.JMXServiceURL;
import java.io.File;
import java.io.FileInputStream;

/**
 * Coded by senninha on 18-12-24
 */
public class JMXClient {
    public static void main(String[] args) {
        executeCode(getJMXServiceUrl("localhost", 6666), getCode("/tmp/groovy.groovy"), "跑得比西方记者还快");
    }

    /**
     * 获取jmx服务地址
     * @param host * @param port
     * @return
     */
    private static String getJMXServiceUrl(String host, int port){
            String url = "service:jmx:rmi:///jndi/rmi://" + host + ":" + port + "/jmxrmi";
            return url;
    }

    /**
     * 执行代码
     * @param url
     * @param code
     * @param password
     * @return
     */
    private static String executeCode(String url, String code, String password){

        try {
            JMXServiceURL serviceUrl = new JMXServiceURL(url);
            JMXConnector jmxConnector = JMXConnectorFactory.connect(serviceUrl, null);
            MBeanServerConnection mbeanConn = jmxConnector.getMBeanServerConnection();
            ObjectName name = new ObjectName("cn.senninha.mbean:type=SenninhaRuntime");
            String result = (String) mbeanConn.invoke(name, "runCode", new Object[]{password, code}, new String[]
                    {String.class.getName(), String.class.getName()});
            System.err.println("--->" + code);
            System.err.println("<---" + result);
            return result;
        } catch (Exception e){
            e.printStackTrace();
            return null;
        }
    }

    /**
     * 获取代码
     * @param file
     * @return
     */
    public static String getCode(String file){
        try {
            File f = new File(file);
            FileInputStream fileInputStream = new FileInputStream(f);
            byte[] b = new byte[fileInputStream.available()];
            fileInputStream.read(b);
            return new String(b);
        } catch (Exception e){
            e.printStackTrace();
            return null;
        }
    }
}

```

通过编写groovy脚本，即可远程执行对应的代码。当然，也可以直接用Java代码直接编写，groovy的编译引擎是兼容java的，但是用groovy爽得很多啊。。
