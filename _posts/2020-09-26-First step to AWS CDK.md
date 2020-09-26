---
layout: post
title: "First step to AWS CDK"
date:   2020-09-26 13:01:30 +1000
categories: [blog]
excerpt_separator: <!--more-->
---

This is my first step of using AWS CDK in macOS.  I am using Pyenv tool to create python enviroment  as explained in the [Python my workflow](https://ojitha.blogspot.com/2020/05/python-my-workflow.html).
 
 <!--more-->

* TOC
{:toc}

## Prepare the development env
First, you have to verify that, you have installed the AWS CDK.
1. in the macOS, install AWS CLI using Homebrew
2. install NodeJS
3. install AWS CDK using NodeJS

If all the above is good, now install the python enviroment to use with the AWS SDK:
1. install Python version 3 
2. create virtual enviroment `p3` using pyenv tool 
3. You can use any directory to creat your scripts, I use Visual Studio Code as my editor
4. In case, I can use the following command to set the shell to python version 3:

```bash
pyenv shell p3
```

## Frist step
Create a directory as you want, in my case
```bash
mkdir helloaws
```

Use `cdk init` to create the project
```bash
cdk  init sample-app --language python
```



> Written with [StackEdit](https://stackedit.io/).
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTc0MjIxNzE0MiwxMDUxOTczMTYwLDE1ND
MwNDgxMDYsLTE0MTczMjM2OTQsMTAzOTUwNzQwMywtODE5MjQx
MTcwLC01Njk0Njk4MTBdfQ==
-->