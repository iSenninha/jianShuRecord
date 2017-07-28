####1.不使用乘法,条件比较语句计算等差数列和
```
	//递归的思想
	public static int total(int n){
		int sum = n ;
		//短路性质
		boolean b = (n != 0) && ((sum = sum + total(n - 1)) > 0);
		return sum;
	}
```

####2.使用移位做加法
> 1.相加，但是不计算进位，这样的话**异或**运算满足这个性质
2.然后计算计算进位，**与** 加 **右移** 一位产生进位
3.然后神奇地发现1,2相加就是原来的值，可是不能用加法啊我去
4.所以继续重复上诉的运算法则，直到进位值为0的时候，直接就是xx + **0**了，这个就是结果

```
public static int add(int a , int b){
		int sum = 0;
		int bit = 0;
		do{
			sum = a ^ b;
			bit = (a & b) << 1;
			a = sum;
			b = bit;
		}while(bit != 0);
		
		return sum;
	}
```
