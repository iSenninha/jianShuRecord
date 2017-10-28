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

> 其实就是计算某个字符串前缀表达式和后缀表达式的最长相等串，前缀表达式指一个字符串一个字符前面的所有字符，后缀反过来，比如，abcd：
>
> 前缀为：a,ab,abc;	后缀为：d,cd,bcd,相似为0,所以abcd在d点的相等串为0，即next的值。
>
> 有这个定义，来看看：
>
> | a    | b    | c    | d    | a    | b    | d    |      |
> | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
> | 0    | 0    | 0    | 0    | 1    | 2    | 0    |      |

有了这个next算法，怎么在匹配的时候使用？

> 其实就是正常匹配，当匹配一个字符失败的时候，BF的算法是目标串回跳到上一次开始的下一个，模式串回复到下标0，KMP算法则不然，目标串不用回复，模式串根据next对应的值回复到对应的下标点。

下面给出next算法实现：

```
	/**
	 * 未改进的next算法
	 * 
	 * @param pattern
	 *            模式串
	 * @return
	 */
	private static int[] next(String pattern) {
		int[] next = new int[pattern.length()];
		int count = 0;
		int lastIndex = 0;
		for (int i = 1; i < pattern.length(); i++) {
			if (pattern.charAt(i) == pattern.charAt(lastIndex)) {
				next[i] = ++count;
				lastIndex++;
			} else {
				next[i] = count = lastIndex = 0;
			}
		}
		return next;
	}
```

对应的使用next的匹配算法：

```
	/**
	 * KMP匹配字符串
	 * 
	 * @param pattern
	 * @param target
	 * @return
	 */
	private static int match(String pattern, String target) {
		int patternLen = pattern.length();
		int[] next = improveNext(pattern);
		// 目标串的下标，模式串的下标
		int i = 0, j = 0;
		while (i < target.length()) {
			if (target.charAt(i) == pattern.charAt(j)) {
				i++;
				j++;
			} else {//匹配串失败
				if (j == 0) {如果模式串匹配了0个，直接目标串向前走
					i++;
				} else {
					j = next[j - 1];//这个时候实际上匹配了j个字符，但是对应的next下标是j - 1,回复模式串的下标到next[j - 1]
				}
			}

			if (j == patternLen) {
				return i - j;
			}
		}
		return -1;
	}
```



其实可以next算法是可以改进的，先来看这个

> 模式串：a b a b a b
>
> next值： 0 0 1 2 3 4
>
> 目标串：a b a b a c a b a b a b
>
> 当匹配到：ababac的**c**点的时候，根据next算法，模式串是回复到**3**的下标，然鹅，发现回复到发现仍然不匹配，继续回复到**1**的下标，然鹅，依然不匹配，回复到**0**。这一连串的**无功匹配**是必然的。
>
> 因为根据next的算法，如果未到一次next算法的归零处，返回的上一个next的地方和当前的值是一样的。这个有点拗口。
>
> 这么说吧，a  b  c  d  a  b  d    0  0  0  0  1  2  0，这个是一开始举出来的栗子，如果我们在b的时候不匹配，我们的模式串是要回复到下标为**1**的地方，依然是**b**，这种情况是直接回复到下标0就可以的。
>
> 再来看看如果在最后一个d的时候不匹配，回复到模式串下标2的地方，这个时候目标串是非D，下标2的地方并不是D，所以才有回复的必要。。

根据这个思想，改进后的next，匹配串那里直接写成improveNext()即可：

```
	/**
	 * 改进的next算法
	 * 
	 * @param pattern
	 *            模式串
	 * @return
	 */
	private static int[] improveNext(String pattern) {
		int[] next = new int[pattern.length()];
		int count = 0;
		int lastIndex = 0;
		for (int i = 1; i < pattern.length(); i++) {
			if (pattern.charAt(i) == pattern.charAt(lastIndex)) {
				next[i] = 0;//改进的地方
				count++;
				lastIndex++;
			} else {
				if (i != 0 && count != 0) {//改进的地方
					next[i - 1] = lastIndex;
				}
				next[i] = count = lastIndex = 0;
			}
		}
		return next;
	}
```



> 1.KMP算法的核心是next算法，在匹配的时候，遇到不匹配的，根据当前**已经匹配的模式串的数量* - 1**作为下标去next里找对应的值，将这个值作为**模式串要回复的下标位置**，然后继续比较。已经匹配为0的情况，直接目标串+1;
>
> 2.next算法是根据最大共同前缀后缀导出来的。
>
> 3.next算法可能会导致多次的**无功回复模式串**，改进的next算法，只在开始不匹配的串前一个相同的点写值，其他都为0
>
> 改进前的next和改进后的next比较：
>
> [a, b, a, b, a, b, c, d, a, b, c]
>
> [0, 0, 1, 2, 3, 4, 0, 0, 1, 2, 0]
>
> [0, 0, 0, 0, 0, 4, 0, 0, 0, 2, 0]





源码：

```
package cn.senninha.kmp;

public class KMPTest {

	public static void main(String[] args) {
		String pattern = "abcdabd";
		String target = "abcdabcdabd";
		int index = match(pattern, target);
		System.out.println(index);
	}

	/**
	 * 未改进的next算法
	 * 
	 * @param pattern
	 *            模式串
	 * @return
	 */
	private static int[] next(String pattern) {
		int[] next = new int[pattern.length()];
		int count = 0;
		int lastIndex = 0;
		for (int i = 1; i < pattern.length(); i++) {
			if (pattern.charAt(i) == pattern.charAt(lastIndex)) {
				next[i] = ++count;
				lastIndex++;
			} else {
				next[i] = count = lastIndex = 0;
			}
		}
		return next;
	}

	/**
	 * 未改进的next算法
	 * 
	 * @param pattern
	 *            模式串
	 * @return
	 */
	private static int[] improveNext(String pattern) {
		int[] next = new int[pattern.length()];
		int count = 0;
		int lastIndex = 0;
		for (int i = 1; i < pattern.length(); i++) {
			if (pattern.charAt(i) == pattern.charAt(lastIndex)) {
				next[i] = 0;//改进的地方
				count++;
				lastIndex++;
			} else {
				if (i != 0 && count != 0) {//改进的地方
					next[i - 1] = lastIndex;
				}
				next[i] = count = lastIndex = 0;
			}
		}
		return next;
	}

	/**
	 * KMP匹配字符串
	 * 
	 * @param pattern
	 * @param target
	 * @return
	 */
	private static int match(String pattern, String target) {
		int patternLen = pattern.length();
		int[] next = improveNext(pattern);
		// 目标串的下标，匹配串的下标
		int i = 0, j = 0;
		while (i < target.length()) {
			if (target.charAt(i) == pattern.charAt(j)) {
				i++;
				j++;
			} else {
				if (j == 0) {// 这个时候实际上匹配了j个字符，但是对应的next下标是j - 1
					i++;
				} else {
					j = next[j - 1];
				}
			}

			if (j == patternLen) {
				return i - j;
			}
		}
		return -1;
	}

}

```

