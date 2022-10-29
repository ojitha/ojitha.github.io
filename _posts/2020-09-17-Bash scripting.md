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

## Introduction

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

## Files and Directories

To create multiple directories:

```bash
mkdir {a..c}
```

to create multiple files in that directories:

```bash
touch {a..c}/{1..2}
```

The output is

```
.
├── a
│   ├── 1
│   └── 2
├── b
│   ├── 1
│   └── 2
└── c
    ├── 1
    └── 2
```

## To find the files
To get to 2nd depth to find png files:
```bash
find . -maxdepth 3 -iname '*.png' -type f
```

To find the size

```bash
find . -maxdepth 2 -iname '*.png' -type f | xargs du -hsc
```

## Env variables
For example concat:

```bash
x=2 ; echo $x+1
```

But to add 1:

```bash
echo $((x+1))
```

However, the following shows space for `\n`:
```bash
x=abc$'\n'def ; printf $x
```

using `printf`

```bash
printf "%s\n"  I am 'Ojitha Hewa'
```

Output is

```
I
am
Ojitha Hewa
```

## Seq

Here the simple example for seq

```bash
seq 1 10
```

and

```bash
seq 1 10 | while read line; do  printf '%d\n' $((line)); done
```

use with `sed` regular expressions:

```bash
seq 1 10 |  sed -r 's/^/# /'
```

output is

```
# 1
# 2
# 3
# 4
# 5
# 6
# 7
# 8
# 9
# 10
```










