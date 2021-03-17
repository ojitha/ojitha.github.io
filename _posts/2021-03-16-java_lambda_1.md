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





