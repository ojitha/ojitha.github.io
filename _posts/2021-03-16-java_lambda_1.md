---
layout: post
title:  Use of default and static methods
date:   2021-03-16
categories: [Java]
---

For example, in this blog two interfaces are compared:

- java.util.Comparator
- java.util.function.Predicate

<!--more-->

------

* TOC
{:toc}
------

## Introduction to Lambda

For example functional interface can be define as follows

```java
@FunctionalInterface
interface F<T, R> {
    R doIt(T t);
}
```

- only `default`, `static` and `private` methods are allowed 
- exactly one single abstract method available
- `@FunctionalInterface` is optional annotation to verify functional interface.

To use this functional interface:

```java
public class LambdaTest {
    public static void main(String[] args) {
       F<Integer, Double> f = x -> x * 2.0; 
       System.out.println(f.doIt(10));
    }
}
```

There are predefined functional interfaces to use:

| #    | Lambda Interface | Abstract Method   |
| ---- | ---------------- | ----------------- |
| 1    | Function<T,R>    | R apply(T t)      |
| 2    | UnaryOperator<T> | T apply(T t)      |
| 3    | Predicate<T>     | boolean test(T t) |
| 4    | Consumer<T>      | void accept(T t)  |
| 5    | Supplier<T>      | T get()           |

There are number of other slightly variations you can find in the `java.util.function.*` pacakge. 

For example, for the `Consumer<T>` interface: `DoubleConsumer` to pass `double`, `IntConsumer` to pass `int`, `LongConsumer` pass `long` primitive types and `BiConsumer<T,U>`.

```java
BiConsumer<Integer, Double> f = (x,y) -> System.out.println(x*y);
f.accept(3,2.0); // 6.0
```

The functional interface `DoubleFunction` example as follows:

```java
// similar to Function<Double, String>
DoubleFunction<String> f = x -> Double.valueOf(x).toString();
f.apply(4.5); // "4.5"
```

```java
// Double apply(String x, Integer y)
BiFunction<String, Integer, Double> f = (x,y) -> Double.parseDouble(x) * y;
f.apply("2.5",3); // 7.5
```

Variation of `Predicate`:

```java
DoublePredicate f = x -> x > 2.0;
f.test(2.1); // true
f.test(1.1); // false
```

This intro will help you to go through the next sections.

## Comparator Interface

Examples of default methods provided by the `java.util.Comparator` interface:

- `thenComparing` adds additional comparators 
- `reversed` reverses sorting order

static methods provided by the Comparator interface:

- `nullsFirst` and `nullsLast` return comparators that enable sorting collections with null values.

```java
// create a simple string list
l1 = new ArrayList<>(){ {add("first");add("second");add("third");add("fourth");add("fifth");add("sixth");} };

Comparator<String> sortbyStr =(x, y) -> x.compareTo(y); // compare by string
Comparator<String> sortbyStrLength =(x, y) -> x.length() - y.length(); // compare by length of the string

// first sort by string then by length of the string and reversed the result
Collections.sort(l1, sortbyStr.thenComparing(sortbyStrLength).reversed())
  
// output is as fllows
// l1 ==> [third, sixth, second, fourth, first, fifth]  
```

Notice line #7 where `thenComparing` default method has been used.

## Predicate Interface

Default methods provided by the java.util.function.Predicate interface:

- `and` combines predicate
- `or` combines predicate operator
- `negate` returns a predicate that represents the logical negation of this predicate

Static methods provided by the Predicate interface:

- `not` returns a predicate that is the negation of the supplied predicate
- `isEqual` returns a predicate that compares the supplied object with the contents of the collection

```java
// create a simple string list
l1 = new ArrayList<>(){ {add("first");add("second");add("third");add("fourth");add("fifth");add("sixth");} };

// predicate to validate the instance type
Predicate<String> f1 = x -> x instanceof String
  
// predicate to filter out words length less than 5
Predicate<String> f2 = x -> x.length() > 5;

// use of default methods
l1.removeIf(f1.negate().or(f2));

// output is 
// l1 ==> [first, third, fifth, sixth]
```

As shown in the line number #11, the words whose lengths are less than 5 will be remains in the list after apply.



