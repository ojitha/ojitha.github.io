---
layout: post
title:  Java Thread interrupt
date:   2021-03-23
categories: [Java]
---

It is important to understand how the Java thread interrupt work.

 ![image-20210326104946921](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20210326104946921.png)

| Source   | Target        | Action                            |
| -------- | ------------- | --------------------------------- |
| New      | Runnable      | thread `start()`.                 |
| Runnable | Blocked       | `synchronized` lock on.           |
| Runnable | waiting       | when object call `Object.wait()`. |
| Runnable | timed-waiting | when `Thread.sleep(...)`.         |
| Runnable | Terminated    | When thread finished.             |

<!--more-->

1. Thread-1 send intrrupt request to the thread-0.
2. if Thread-0 is not in the sleep mode, then terminate based on the `while` condition exit from the while loop.
3. if Thread-0 is in the sleep mode, then terminate when wake at the point of `return` statement.



![thread-interrupt](/assets/thread-interrupt.jpeg)

The `(i > 10) && other.isAlive() && current != other`, second and third conditions are very important. Second condition avoid sending one more interrupts (due to the first condition has been satisfied) and third condition completely avoid the intrrupt to be happned in the Thread-0.

```java
package ...;

public class Test {
    //static Thread t0, t1;
    public static void main(String[] args) {
        MyThread a = new MyThread();

        Thread t0 = new Thread(a);
        Thread t1 = new Thread(a);
        
        a.setThread(t0);
        t0.start();t1.start();
    }
    
}

class MyThread implements Runnable{
    Thread other =null;
    void setThread(Thread thread){this.other = thread;}
    int i=0;
    @Override
    public void run() {
      
        Thread current = Thread.currentThread();
      
        while (!current.isInterrupted()){
            System.out.println(current.getName()+":"+i++);
            try {
              
                if ((i > 10)  && current != other){
                    other.interrupt();
                    System.out.println("interrupted by "+current.getName());
                } 
              
                Thread.sleep(300);
            } catch (InterruptedException e) {
              
                // interrputed when sleeping
                System.out.println("terminating..."+current.getName());
                return;
                
            }
        } // exit, thread was not in sleep or not within the while loop.
        
    }

}

```

In the above code, the instance of MyThread has been shared by the t0 (Thread-0) and t1 (Thread-1) threads.

