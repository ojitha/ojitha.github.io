---
layout: post
title:  Java Concurrent CompletableFuture
date:   2020-11-21
categories: [Java]
toc: true
---

The `CompletableFuture` has been introduced since JDK 8 (2014). This is a abstraction over the `java.util.concurrent. Learn the basics of [Java 9 Parallelism](https://ojitha.blogspot.com/2020/11/java-9-parallelism.html) before read this post.

<!--more-->

* TOC
{:toc}
This post is based on a O'Reilly Katacoda[^1]. Future` which is explain in the [Java Futures]({% post_url 2020-11-21-java-futures %}).

## CompleteableFuture

The Copy method available in the CompleteableFuture since JDK 9. There are few advantages:

- Composable: compose as chain
- Composiblity with functional programming
- choose whether each function link is synchronous or asynchronous

Using `supplyAsync` factory method:

```java
ExecutorService executorService = Executors.newCachedThreadPool();

CompletableFuture<Integer> f = CompletableFuture
    .supplyAsync(() -> {
        try {
            System.out.println("I will take 3000 ms...");
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        return 1;
    }, executorService);

f.thenAccept(System.out::println);
```

## Parameterizing

The signature for `CompletableFuture` doesn't have the ability to provide a parameter. As we did in the [Java Futures]({% post_url 2020-11-21-java-futures %}), we do the same here:

Create method that accepts the paramters and `CompatibleFuture` closure to capture that parameter of the method.

```java
public static CompletableFuture<Integer> method(final String param) {
    return CompletableFuture.supplyAsync(() -> {
        System.out.println(param+" is in a method to do the work...");
        return 20;
    }, executorService);
}
```

Now return that `CompatibleFuture` as a thrid step:

```java
public static void main(String[] args)
    throws InterruptedException {

    CompletableFuture<Integer> f =
        getTemperatureInFahrenheit("Ojitha");

    f.thenAccept(System.out::println);

    executorService.shutdown();
    executorService.awaitTermination(4, TimeUnit.SECONDS);
}
```

## Handle success and failure

The `BiFunction` interface can be used to handle the success and the failure. 

```java
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

class Scratch {
    static final ExecutorService executorService = Executors.newFixedThreadPool(4);

    public static CompletableFuture<Integer> calTask(final Integer param) {
        return CompletableFuture.supplyAsync(() -> {
            final int val = param+1;
            System.out.println(val+" is the calculated value.");
            return val;
        }, executorService);
    }
    public static void main(String[] args)
            throws InterruptedException {

        CompletableFuture<Integer> handle =
                calTask(-1).handle((i, e) -> {
                    if (i != null) {
                        return 100 / i;
                    } else {
                        return 0;
                    }
                });

        handle.thenAccept(System.out::println);

        executorService.shutdown();
        executorService.awaitTermination(4, TimeUnit.SECONDS);
    }
}
```

REFERENCE:

[^1]: [Java Concurrent Programming: Creating a CompletableFuture](https://learning.oreilly.com/scenarios/java-concurrent-programming/9781492093510)

