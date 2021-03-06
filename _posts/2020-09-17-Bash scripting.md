---
layout: post
title: "Bash Introdcution"
date:   2020-09-17 13:01:30 +1000
category: Bash
---
Understand the bash scripting to use in the day-to-day life of the developer.

<!--more-->

* TOC
{:toc}

I
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
To redirect both to the same file
```bash
ls -l t1.json not.available &> sout
or
ls -l t1.json not.available > sout 2>&1
```
The second line says to redirect the error to the same as file descriptor 1.


> Written with [StackEdit](https://stackedit.io/).
<!--stackedit_data:
eyJoaXN0b3J5IjpbMjEzODg1NzczLDExMTY4NzEzMDAsNzgzMj
Y3OTgsMTI3NDY1MjUwXX0=
-->
