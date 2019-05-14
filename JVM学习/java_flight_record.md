#### Java flight record
> 本文主要是翻译一下如何录制JFR

##### 1.加启动参数
直接在启动参数中增加，这种方式可能局限比较多。
```
 java -XX:+UnlockCommercialFeatures -XX:+FlightRecorder -XX:StartFlightRecording=duration=60s,filename=myrecording.jfr MyApp
```


#### 2.jcmd
> jcmd是发送诊断命令给运行中的JVM的工具

- 录制命令
```
jcmd 5368 JFR.start duration=60s filename=myrecording.jfr
```

如果没有打开商业特性的话，也可以用jcmd打开商业特性(support in jdk8)

- 打开商业特性
```
// 检查是否打开
jcmd pid VM.check_commercial_features
// 打开
jcmd pid VM.unlock_commerical_features
```

- 检查是否有jfr在录制中
```
jcmd pid JFR.check
```

- 停止录制
```
jcmd pid JFR.stop name(jfr文件名就可以)
```
