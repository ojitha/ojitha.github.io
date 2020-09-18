---
layout: post
title: "Bash Introdcution"
date:   2020-09-17 13:01:30 +1000
categories: [blog]
excerpt_separator: <!--more-->
---
To  find the bash version:
```bash
bash --version
```
There are three I/Os to consider

 - standard input
 - standard output
 - standard error

Using I/O redirect, redirect output to a file :
```bash
ls -l t1.json > out
```
The error message has to be redirect as follows:
```bash
ls -l not.available 2> err
```
To send standard output to the `sout` and standard error to the `serror`:
```bash
ls -l t1.json not.available > sout 2> serror
```



> Written with [StackEdit](https://stackedit.io/).
<!--stackedit_data:
eyJoaXN0b3J5IjpbNzgzMjY3OTgsMTI3NDY1MjUwXX0=
-->