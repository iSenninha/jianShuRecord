### BitSet位记录工具

> BitSet是一个位记录工具，什么是位记录呢？比如：
>
> 有1kw个用户，需要记录这1kw个用户是是否需要推送某个类型的新闻，可以使用BitSet记录这些状态。

### 数据结构

核心数据结构是一个**Long数组**。那么一个long实际上就可以储存64位的数据。

### 核心算法

##### 1.set()

```
  public void set(int bitIndex) {
        if (bitIndex < 0)
            throw new IndexOutOfBoundsException("bitIndex < 0: " + bitIndex);

        int wordIndex = wordIndex(bitIndex);//（1）其实这里就是 / 64 ，计算出应该处于数组的哪个index下
        expandTo(wordIndex);//动态扩容数组。（2）
        

        words[wordIndex] |= (1L << bitIndex); //设置那个值，左移是有循环的功能的，右移没有

        checkInvariants();
    }
    
    （1）return bitIndex >> ADDRESS_BITS_PER_WORD; //除以64
    
    （2）int request = Math.max(2 * words.length, wordsRequired);扩容算法。比较wordsRequired和两倍原words的较大值

```



> 其实到这里，已经描绘了这个工具的实现了。。