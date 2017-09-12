### Fork/Join学习

> 不是很理解这个实现算法，直接给出demo吧
>
> Pool本身是继承AbstractExecutorService的，然后如果提交普通的Runnable任务就是普通的线程池，如果提交的是继承自ForkJoinTask的任务，那么就是一个ForkJoin模式的任务了。
>
> 分解任务，直到任务够小了，就执行，Arrays里的parallelSort也使用了ForkJoinPool的思想。

```
package com.senninha.concurrent;

import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.RecursiveTask;

/**
 * 
 * @author senninha on 2017年9月12日
 *
 */
public class ForkJoinTest {
	private static ForkJoinPool fjp = new ForkJoinPool(Runtime.getRuntime().availableProcessors());

	public static void main(String[] args) {
		int[] array = new int[16];
		for (int i = 0; i < 16; i++) {
			array[i] = i + 1;
		}
		CaculateTask task = new CaculateTask(array, 0, array.length);
		fjp.execute(task);
		System.out.println(task.join());
	}

	static class CaculateTask extends RecursiveTask<Integer> {
		private static final long serialVersionUID = 5691085403031441861L;
		private int[] array;
		private int from;
		private int to;

		public CaculateTask(int[] array, int from, int to) {
			super();
			this.array = array;
			this.from = from;
			this.to = to;
		}

		/**
		*重写的方法，如果不再分割了，就直接执行运算，否则继续分割，提交到pool里
		**/
		@Override
		protected Integer compute() {
			int result = 0;
			if (to - from >= 4) {
				int middle = (to + from) / 2;
				CaculateTask left = new CaculateTask(array, from, middle);
				CaculateTask right = new CaculateTask(array, middle, to);
				fjp.execute(left);
				fjp.execute(right);
				result = result + left.join();
				result = result + right.join();
			} else {
				for (int i = from; i < to; i++) {
					result = array[i] + result;
				}
			}
			return result;
		}
	}

}

```

