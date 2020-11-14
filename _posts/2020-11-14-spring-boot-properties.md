---
layout: post
title:  Spring boot properties
date:   2020-11-14
categories: [Spring Framework]
---

Spring property and profile manangement is explained.

<!--more-->

* TOC
{:toc}

## Precedency

Here the precedency of loading properties

1. commandline arguments
2. JNDI attributes from `java:comp/env`
3. `System.getProperties()`
4. OS envs
5. External property files on file system (application.yml/properties).
6. Internal property file in the `main/resource` location (application.yml/properties).
7. `@PropertySource` on configuration classes.
8. Default properties from `SpringApplication.getDefaultProperties()`.

## Examples of property configuration

Here the way to access enviroment properties mentioned at point 4. 

```java
@Autowired
void setHost(Environment env){
  env.getProperty("configuration.host")
}
```



The annotation `@ConfigurationProperties` is a way to map properties to POJOs. For example:

```java
@Component
@ConfigurationProperties("configuration")
class ConfigurationProp...{
  private String prop1;
  public String getProp1...
  public void setProp1(String prop1) ..  
}
```

In the above, you can use JSR303 validations as well. 

Now you can configurat the above POJO as follows

```java
@Autowirted
void setConfigurationProp(ConfigurationProp prop){
  prop.getProp1();
}
```

This way you can inject properties in the methods.

This will validate at the initilization time as well as type safe. In the level of the class declaration of the POJO, you have to add the `@EnableConfigurationProperties` annotation 

```java
@EnableConfigurationProperties
public class App...{
  
  @Value("${configuration.host}")
  void setPort(String host){
    ...
  }
}
```

You can override the application.yml properties by passing the command line argument when you run the boot application command line.

```bash
java -Dconfiguration.host=myhost -jar app.jar
```

you can create a external application.yml which should be the root whee you run the java -jar command.

or you can create a enviroment variable

```bash
export CONFIGURATION_HOST=myhost
java -jar app.jar
```

To debug all the available properties, you have to add the `actuator` and `web` (if not a web app). Then use the browser url http://..../configprops. 

## Spring profiles

If you use properties extension, then for each profile, you have to have separate properties file, for example, `application.dev.properties`, `application.prod.properties` and so on. 

If you use yml, then you can have `dev` and `prod` sections instead of number of files.

To run the profile

```bash
java -Dspring.profile.active=dev ...
```

You can use the following confituration mechanism

```java
@Configuration
public class DSConfig {
  
  @Bean @Profile("dev")
  DataSource dev() {return ...''}
  
    
  @Bean @Profile("prod")
  DataSource dev() {return ...''}
  
}
```

You can activate multiple profiles a the same time.

