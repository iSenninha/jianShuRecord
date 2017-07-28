####判断是否是BST的后序遍历序列

> 1.首先最后一个节点是根节点，根据BST的定义，从左到右查找第一个到大于跟节点的节点;
2.a.查找到那个节点后，首先判断它是不是就是根节点，如果是，说明右子树为空;接下去只需要递归验证左子树即可;
&nbsp;&nbsp;b.若那个节点就是begin节点，说明左子树为空，那么只需要判断右子树即可。
&nbsp;&nbsp;c.若有左右子树，继续验证剩下的节点是否每个都大于根节点，若不符合，直接返回false
3.满足2c条件，递归判断左，右子树是否满足。


```
	public static boolean verify(int[] sequence, int begin, int end) {
		if (sequence == null) {
			return false;
		}

		if (begin <= end) {
			return true;
		}

		int leftEnd = begin;
		boolean flag = false;
		//查找第一个大于根节点的节点
		while (leftEnd < end && sequence[leftEnd] < sequence[end]) {
			leftEnd++;
		}
		//节点不存在，即没有右子树，只需要继续判断左子树，递归判断
		if (leftEnd == end) {
			flag = verify(sequence, begin, leftEnd - 1);
		}//若左子树不存在，只需要递归判断右子树 
		 else if (leftEnd == begin) {
			int tem = leftEnd;
			while (tem < end) {
				if (sequence[tem] <= sequence[end]) {
					return false;
				}
				tem++;
			}
			flag = verify(sequence, leftEnd, end - 1);
		} else {
			//验证右子树是否满足每个节点都大于根节点
			int tem = leftEnd;
			while (tem < end) {
				if (sequence[tem] <= sequence[end]) {
					//不满足直接返回false
					return false;
				}
				tem++;
			}
			//继续递归验证左子树
			flag = verify(sequence, begin, leftEnd - 1);
			//左子树满足，进入右子树递归，否则直接返回false
			if (flag) {
				//验证右子树
				flag = verify(sequence, leftEnd, end - 1);
			} else {
				return false;
			}
		}

		return flag;
	}

```
