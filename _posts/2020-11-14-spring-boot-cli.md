---
layout: post
title:  Spring boot CLI
date:   2020-11-14
categories: [Java, Spring Framework]
---

This is a short explanation of how to use Spring boot CLI to create project and run in the macOS.

<!--more-->

Install spring boot using homebrew in the macOS:

```bash
brew tap pivotal/tap && brew install springboot
```

The simple application 

```groovy
@RestController
public class Application {
    @RequestMapping("/")
    public String hello(){
        return "Hello Ojtiha!"
    }
}
```

Run the application using spring

```bash
spring run app.groovy
```

Now in the browser, navigate to the http://localhost:80808.

If you want to create standard alone jar application

```bash
spring jar hello.jar app.groovy
```

to run the jar

```bash
java -jar hello.jar
```



To create spring boot java project:

```bash
spring init -d=web web-app.zip
```

Here all the projects where you can create applications directly

```bash
spring init --list
```

You can use curl to directly create

```bash
curl http://start.spring.io/starter.zip -o app.zip
```



