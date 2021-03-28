---
layout: post
title:  Understand JPMS
date:   2021-03-27
categories: [Java]
---

Java Platform Module System (JPMS) has been introduced since Java 9. This is simple example created using IntelliJ IDEA.

![module-info](/assets/module-info.jpg)

As shown in the above diagram, there are three modules, Application, Service and Provider 

<!--more-->

> NOTE: Sorry about violation of module naming convention to simplify this example.



------

* TOC
{:toc}
------



## Create in IntelliJ IDEA

In the IntelliJ IDEA, 

1. createa Empty project 

    ![Project Structure](/assets/image-20210328122652901.png)

2. Add the three IntelliJ IDEA Java modules: Application, Service and Provider.

    ![IntelliJ IDEA Modules](/assets/image-20210328122340513.png)

3. In the Each Java Module, you have to create, `module-info.java` files which has already shown in the first screenshot.

    ![Three module-info.java files](/assets/image-20210328122554069.png)

    

As shown in the above screenshot, there is one module-info.java file for each IntelliJ IDEA Java module. Module name should be unique although I used simple names for this example. To get the idea of naming, run the following command in the CLI to find the modules availabe with the Java runtime:

```bash
java --list-modules
```

Module descriptor module-info.class should be stored in the module root folder. 

## Module Dependencies

Here the three module descriptors source files (under src folder):

```java
// Application
module Application {
    requires Service;
    uses com.github.ojitha.service.a.OjService;
}

// Provider
module Provider {
    requires Service;
    requires java.logging;
    provides com.github.ojitha.service.a.OjService
            with com.github.ojitha.provider.b.M;
}

//Service
module Service {
    exports com.github.ojitha.service.a;
}
```

This is all about module dependencies such as 

- `requires`: This module required other external module: `requires <module>` 
    - The use of `requires transitive <module-a>` implies that the `module-a` is needed by this module as well as external modules which uses this module.
    - The use of `requires static <module-b>` implies that `module-b` is only required in the compile time for this module.
    - The directive `requires java.base` is implicit dependency in all the descriptors.
- `exports`: The directive `export <package>` defines that this module packages are allowed to access by other modules
    - Access is limited only to public classes by the modules which `requires` this module.
    - Using `exports <packages> to <module-e>` restrict the access of public classes of this `packages` only by the `module-e` which `requires` this module. 
- `open`: In the directive, `opens <pacakges>`, entire package is allowed to access runtime only via Java reflection
    - Other module don't need to specify `reuqires` explcitly to access package contents.
    - This can be restricted by `opens <packages> to <module-d>` allowing only to access runtime by `module-d`.
    - Using `opens module <module-o> {}`, all the packages of the `module-o` is accessible to any other modules.  
- `uses`: The directive  `uses <service interface>` uses services provided by other modules
- `provide`: In the service consumer module, the directive `provides <service interface> with <classes>`: 
    - specifies **interface or abstract class** of the service module.
    - The service consumer **dynamically discover** (discussed in the next section) the provider implementation. 
    - The consumer modules **don't need to specifies** `requires` for provider module.
- `verion`: version of the module which is required for version control of modules.

> NOTE: Circular module dependencies are not allowed.

## Dynammic Discovery of implementation

1. The Service Java module contains only the interface which is the contract:

    ```java
    package com.github.ojitha.service.a;
    
    public interface OjService {
        void printHello();
    }
    ```

    

2. The above interface has been implemented in the Provider

    ```java
    package com.github.ojitha.provider.b;
    
    import com.github.ojitha.service.a.OjService;
    import java.util.logging.*;
    
    public class M implements OjService {
        private static final Logger log = Logger.getLogger(M.class.getName());
        @Override
        public void printHello() {
            log.info("Hello");
        }
    }
    ```

    Here you can have number of implemetation for the same service (for example `OjService`).

3. The client is available in the Application module which is the consumer

    ```java
    package com.github.ojitha.application.a;
    import com.github.ojitha.service.a.OjService;
    
    import java.util.ServiceLoader;
    
    public class HelloWorld {
        public static void main(String[] args) {
    
            ServiceLoader<OjService> sl = ServiceLoader.load(OjService.class);
            OjService l = sl.findFirst().get();
            l.printHello();
        }
    }
    ```

    In the above code, the Provider implementation is dynamically selected which is one of the greate advantage of Module services.

4. Entry point is consumer, and you can run the `HelloWorld` main method.

It is easy to compile and run the application in the IntelliJ IDEA. Let's see how to do this in the CLI.

## Command Line

If you need to compile all the modules in CLI level, run the following command from the parent directory:

```bash
javac  -d ./build  --module-source-path "./*/src" $(find . -name "*.java")
```

Here the complete source and target after the compilation:

![image-20210328192452235](/assets/image-20210328192452235.png)

To run:

```bash
java -p build -m Application/com.github.ojitha.application.a.HelloWorld
```

One of the great beneifit of modularised application is that, the distribution footprint is very small. 

Create a JIMAGE:

```bash
jlink --module-path build --add-modules Application,Service,Provider --bind-services --launcher Hello=Application/com.github.ojitha.application.a.HelloWorld --output Hello
```

You don't need to install Java runtime to run this JIMAGE because Java runtime is already include in the Hello distribution.

To run this in another machine:

```bash
Hello/bin/Hello 
```

Application load is quicker even because the dependecies between modules, missing modules and other errors can be verified before start the application.

> NOTE: Modules are load from the module-path instead of the class-path. 

