---
layout: post
title:  Java Future
date:   2020-11-21
categories: [Java]
---

Java `Futures` are the way to support asynchronuous operations. Learn the basics of [Java 9 Parallelism](https://ojitha.blogspot.com/2020/11/java-9-parallelism.html) before read this post. 

<!--more-->

* TOC
{:toc}
## Future

This has been created after went through a O'Reilly Katacoda[^1]. 

A `Future` is either one of two states

- process 
- complete

`Future` can be cancelled before it competed.

The new `java.util.concurrent` API includes `Future`, `CompleteableFuture`, `Task` and `Executors`.

## Hello World

Here the `Callable` where the work is happening:

```java
Callable<Integer> callable = () -> {
  system.out.println("Hello World...");
  return 2;
};
```

In the main thread you can continue your work until, `Callable` finished the work.

```java
Future<Integer> future = executorService.submit(callable);

//see Guava section to avoid this loop
while (!future.isDone()) {
  System.out.println("wating in the thread: "+
                     Thread.currentThread().getName());
}
```

When the `future` does, show the result of `Callable`:

```java
System.out.println("result = " + future.get());
executorService.shutdown();
executorService.awaitTermination(5, TimeUnit.SECONDS);
```

## Guava

The Guava `ListenableExecutorService` is a wrapper around a standard Java `ExecutorSerivce`. This will submit `Callable` in place of the thread pool and will return a `ListenableFuture` which is a wrapper around the standard `Future` which provide callback functionality.

The `Futures.addCallback` is the important, because we can avoid above while loop using `onSuccess` and `onFailure` methods of that.

First create `ListenableExecutorService`:

```java
ExecutorService executorService = Executors.newCachedThreadPool();

ListeningExecutorService listeningExecutorService = MoreExecutors.listeningDecorator(executorService);
```

For example your future task is as:

```java
ListenableFuture<Integer> listenableFuture = listeningExecutorService.submit(
  () -> {
    Thread.sleep(5000);
    return 2;
  });
```

Now the important part to avoid `while` loop and add callback methods:

```java
Futures.addCallback(listenableFuture,
        new FutureCallback<>() {
          
          @Override
          public void onSuccess(Integer result) {
             System.out.println("suucess result is " + result);
          }            

          @Override
          public void onFailure(Throwable t) {
             System.out.println("failure happned" + t.getMessage());
          }
        }, executorService);
```



## Parameterizing

The signature for `Future` doesn't have the possibility to provide a parameter:

1. Create a method that accepts parameter
2. Create a `Fiture` clousure to capture the paramter of the method

```java
private static Future<Stream<String>> method(final String str) {
  return executorService.submit(() -> {
    ...
    ...  
    return ...
}

public static void main(String[] args)
    throws InterruptedException, ExecutionException {

    executorService = Executors.newCachedThreadPool();

    Future<Stream<String>> future =method(...);

    while (!future.isDone()) {
        Thread.sleep(1000);
        System.out.println("Doing in main thread");
    }
      
    Stream<String> str = future.get();
    executorService.shutdown();
    executorService.awaitTermination(5, TimeUnit.SECONDS);
}
```



**RFERENCE**

[^1]: [Java Concurrent Programming: Basics and Thread Pools](https://learning.oreilly.com/scenarios/java-concurrent-programming/9781492093503/)

