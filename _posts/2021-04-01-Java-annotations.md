---
layout: post
title:  Java Annotations
date:   2021-04-01
categories: [Java]
---

Annotations are metadata that provide information at the retention level of Java source, class or runtime.

<!-- more -->

Annotations can be applied to the following targets:

1. ANNOTATION_TYPE
2. CONSTRUCTOR of the class
3. FIELD of class or enum
4. LOCAL_VARIABLE
5. METHOD
6. MODULE
7. PACKAGE
8. PARAMETER
9. TYPE such as class, interface (including annotation type), or enum
10. TYPE_PARAMETER of generic
11. TYPE_USE

Here the simple custom annotation:

```java
package ex11;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Repeatable;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.util.stream.IntStream;

@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Repeatable(Annos.class)
@interface Anno {
    String name() default "Anno-n";
    int[] numbers();
}

@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@interface Annos {
    Anno[] value();
}

@Annos({
    @Anno(numbers = 1),
    @Anno(name = "Anno-1", numbers = {1,2})
})
public class AnnoEx1 {
    public static void main(String[] args) {
        Anno[] annos = AnnoEx1.class.getAnnotationsByType(Anno.class);
        for (Anno annotation : annos) {
            System.out.println("name: "+ annotation.name());
            IntStream.of(annotation.numbers())
                .forEach(System.out::println);
        }
    }
    
}
```

As in the above:

- attribute can have a default value (line# 16)
- can have an array of values (line# 17), including other repeatable annotations (line# 24).
- Attributes are applied with name/value pairs
    - Attributes with default values can be omitted (line# 28, the name is omitted).
    - when no attribute, `'( )'` can be omitted.
    - no need to specify the name if there is only one attribute
    - if array has one value omit the `'{ }'` (line# 28).

There are predefined annotations such as `@Override`, `@FunctionalInterface`, `@Deprecated`, `@SuppressWarnings({"unchecked", "deprecation"})` and `@SafeVaragrs`(can be only annotated either **final** or **private** method).

NOTE: Unchecked warning indicates potential heap pollutions. Especially the annotation `@SafeVarargs` suppresses heap pollution warning when using var-args.