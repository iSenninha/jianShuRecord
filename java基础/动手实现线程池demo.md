动手实现线程池demo
```

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 
 * @author senninha
 *	线程池demo
 */
public class ThreadPollTest {
	private LinkedList<Job> jobs;
	private List<Worker> workers;
	private final int THREAD_NUMS = 10;
	private AtomicInteger threadName = new AtomicInteger(0);

	public ThreadPollTest(LinkedList<Job> jobs, List<Worker> worker) {
		super();
		this.jobs = jobs;
		this.workers = worker;
		initThreadPools();
	}



	private void initThreadPools() {
		for (int i = 0; i < THREAD_NUMS; i++) {
			Worker worker = new Worker(jobs);
			Thread t = new Thread(worker, "线程" + threadName.getAndIncrement());
			workers.add(worker);
			t.start();
		}
	}

	public void submit(Job job) {
		synchronized (jobs) {
			jobs.addLast(job);
			jobs.notifyAll();
			System.out.println("通知线程苏醒");
		}
	}

	public void shutdown() {
		for(int i = 0 ; i < THREAD_NUMS ; i++){
			workers.get(i).shutdown();
		}
		synchronized (jobs) {
			jobs.notifyAll();
			System.out.println("唤醒所有线程,让他们停止");
		}
	}
	
	//程序入口
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		LinkedList<Job> jobs = new LinkedList<>();
		List<Worker> worker = new ArrayList<Worker>();
		ThreadPollTest tpt = new ThreadPollTest(jobs, worker);
		
		Job0 job0 = new Job0();
		Job1 job1 = new Job1();
		
		tpt.submit(job0);
		
		try {
			Thread.sleep(10000);
			System.out.println("休眠10s后提交job1");
			tpt.submit(job1);
			Thread.sleep(10000);
			System.out.println("休眠10s后停止线程池");
			tpt.shutdown();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
	}
}

/**
 * 
 * @author senninha
 *  工作线程
 */
class Worker implements Runnable {
	private LinkedList<Job> jobs;
	private AtomicBoolean run = new AtomicBoolean(true);

	public Worker(LinkedList<Job> jobs) {
		this.jobs = jobs;
	}

	@Override
	public void run() {
		// TODO Auto-generated method stub
		while (run.get()) {
			synchronized (jobs) {
				if (jobs.size() == 0) {
					try {
						System.out.println("线程:" + Thread.currentThread().getName() + "在等待");
						jobs.wait();
					} catch (InterruptedException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
						return;
					}
				} else {
					jobs.removeFirst().run();
				}
			}
		}
		System.out.println("线程" + Thread.currentThread().getName() + " 结束");
	}

	public void shutdown() {
		run.set(false);
	}





}

/**
 * 提交任务
 * @author senninha
 *
 */
interface Job {
	public void run();
}

/**
 * 继承Job实现线程任务
 * @author senninha
 *
 */
class Job0 implements Job{
	@Override
	public void run(){
		// TODO Auto-generated method stub
		System.out.println(Thread.currentThread().getName() + "完成了job0");
	}
}

class Job1 implements Job{
	@Override
	public void run(){
		// TODO Auto-generated method stub
		System.out.println(Thread.currentThread().getName() + "完成了job1");

	}
}

```
