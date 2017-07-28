###串的模式匹配

####1.朴素的模式匹配（Brute-Force）算法
    假设待匹配的目标串是adbcade，而模式串是ade，那么匹配的时候是按:
```
	a--d--b-->不匹配;
	d-->不匹配;   //注意这里在上一个发现不匹配时，是从上一个匹配开始的下一个位置开始重新匹配的。
```

Brute-Force算法的实现：
```
public int indexOf(String target,String pattern){
		//判断目标串，匹配串是否满足条件。
		if(pattern != null && target != null && target.length() >= pattern.length()){
			//start指开始匹配的字符起始位置
			int start = 0;
			//count指匹配到的字符数目
			int count = 0;
			//当目标串剩余未匹配的长度大于或等于匹配串串长度，循环继续
			while(target.length() - start >= pattern.length()){
				//满足条件
				if(target.charAt(count + start) == pattern.charAt(count)){				
					//匹配一个字符后加一。
					count ++;
				}else{
				        //不满足匹配，count置零，起始匹配位置加一。
					count = 0;
					start ++;
				}
				//若count==pattern，说明已经完成了一次匹配。
				if(count == pattern.length()){
					return start;
				}
			}
		}
		//匹配失败返回-1
		return -1;
	}
```

测试程序以及运行结果：
```
public static void main(String[] args) {
		// TODO Auto-generated method stub
		String target = "adbcade";
		String pattern = "ade";
		BruteForceStringPattern sfsp = new BruteForceStringPattern();
		System.out.println(sfsp.indexOf(target, pattern));
	}
	
	4
```

    Brute-Force算法易于理解，但是时间效率不高。它是一种带回溯的模式匹配算法，将目标串中所有长度为匹配串长度的字串依次与匹配串比较。
虽然没有任何丢失可能匹配字符的可能，但是每次的匹配没有用到前一次匹配的比较结果，比较多次重复，降低了算法效率。
时间复杂度：
	m = pattern.length();
	n = target.length();
	最好的情况：O(m) (一次比较成功)
	最坏的情况：O(n(n-m+1)*m) 一般n>>m，所以O(n*m) (比较到最后一次才成功）


####2.无回溯的模式匹配（KMP）算法
先来一波kmp算法的[百科](http://baike.baidu.com/item/kmp%E7%AE%97%E6%B3%95)介绍：
```
KMP算法是一种改进的字符串匹配算法，由D.E.Knuth，J.H.Morris和V.R.Pratt同时发现
，因此人们称它为克努特——莫里斯——普拉特操作（简称KMP算法）。
KMP算法的关键是利用匹配失败后的信息，尽量减少模式串与主串的匹配次数以达到快速匹配的目的。
具体实现就是实现一个next()函数，函数本身包含了模式串的局部匹配信息。
```
无回溯的模式匹配算法首先目标串的祛除了目标串的回溯，其次，通过getNext()算法，匹配串也做到了部分不回溯。

无回溯算法的核心是如何实现这个*next（）*算法：
```
	public int[] next(String pattern){
		int i = -1;
		int j = 0;
		int[] next = new int[pattern.length()];
		next[0] = -1;
		while(j < pattern.length() - 1){
			if(i == -1 || pattern.charAt(i) == pattern.charAt(j)){
				i++;
				j++;
				next[j] = i;
			}else{
				i = -1;
			}
		}
		return next;
	}
```
实际上next()算法就是来 判断pattern的子字符串与当pattern的0位置开始的字符串是否相同，第一个next[0]默认为1，接下来的如果不相同next[i]为0，如果第一个相同，为0,若连续开始相同，则依次++1
如:
```
aaaaaaa的next():
[-1,0,1,2,3,4,5]

abab的next():
[-1,0,0,1]
```
如果pattern的首字符在pattern剩余的字符串里没有再出现过，那么getNext()获取的next[]必然是[-1,0,...,0]这样的。



匹配方法如下：
```
public int kmp(String target,String pattern){
		if(target != null && pattern != null && target.length() > pattern.length()){
			int start = 0;
			int[] next = next(pattern);
			int count = next[start];
			while(target.length() - start + count >= pattern.length()){
				if(count == -1 || target.charAt(start) == pattern.charAt(count)){
					count ++;
					start ++;
				}else{
					//这里就是核心了，如果next[count] <= 0 目标字符串直接从当前的下一个开始比较。
					//因为等于-1的话说明是在匹配第一个字符串，当前匹配失败，不可能再与pattern第一个字符匹配了，当然是要继续匹配下一个，如果是0的话，说明是在匹配第一个与pattern头相同的串或者匹配与pattern头无关的字符，匹配失败，当然也是继续匹配下一个字符串。
					count = next[count];
				}
				
				if(count == pattern.length()){
					return start - count;
				}
			}
		}
		return -1;
	}
```

kmp算法的最坏的比较次数是m+n，next算法的时间复杂度是0(m),kmp比较是O(n)，与BF算法相比，已经大大缩小了比较的时间。
