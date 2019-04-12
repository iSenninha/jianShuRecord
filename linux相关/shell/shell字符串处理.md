### 字符串处理
#### 字符长度

```
${#var}
```

#### 字符串截取
- 根据位置截取,截取10个字符
```
${var:0,10}
```
- 从左开始匹配
```
var=aaabbbaaaa

${var#*aa}=bbbaaaa
${var##*bb}=''
```
上面两个都是删除掉匹配的字符串，#是最短匹配，##是最长匹配。
注意，这玩意左边必须先匹配，如果不知道开始是什么的话，那么就用*

- 从右开始匹配
```
var=aaabbbaaaa
${var%bb*}=aaab
${var$$bb*}=aaa
```

#### 字符串替换
- 替换第一个
```
${var/origin/replace}
```

- 替换所有
```
${var//origin/replace}
```

- 从左匹配
```
${var/#origin/replace}
```

- 从右匹配
```
${var/%origin/replace}
```
