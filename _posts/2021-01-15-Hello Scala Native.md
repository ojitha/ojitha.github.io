---
layout: post
title:  Hello Scala Native
date:   2021-01-15
categories: [Scala]
---

Scala Native create machine executable code instead of runing on JVM. The result is C complied executable.

<!--more-->

Here the simple hello world. 

First creat `build.sbt` file:

```sbt
name:="hello"
enablePlugins(ScalaNativePlugin)

scalaVersion:="2.11.8"
scalacOptions ++= Seq("-feature")
nativeMode := "debug"
nativeGC := "immix"
```

now the Scala standard source which is hello world. You can have OO and functional programming code in Native applications.

```scala
object main {
    def main(args:Array[String]){
        println("Hello World!")
    }
}
```

now create a file `project/plugins.sbt`

```sbt
addSbtPlugin("org.scala-native" % "sbt-scala-native"  % "0.4.0-M2")
```

Using `scala run` , you can create executable file in the `arget/scala-2.11/hello-out`

![image-20210115105143114](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20210115105143114.png)

You can directly execute withou JVM as shown in the above screenshot.

