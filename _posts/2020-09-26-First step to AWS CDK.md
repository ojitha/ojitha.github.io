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
4. In case, I can use the following command to set the global version of the python  to version 3:

```bash
pyenv global 3.8.0
```

## Initialse the project
Create a directory as you want, in my case
```bash
mkdir helloaws
```

Use `cdk init` to create the project
```bash
cdk  init sample-app --language python
```

As given in the output of the above command, you have to activate the Virtualenv
```bash
source  .env/bin/activate
```

Now install the requirments:
```bash
pip  install -r requirements.txt
```
The default application entry point is app.py which impor the helloaws_stack.py. According to the helloaws_stack.py, following will be created default:

- sqs queue
- sns topic

## Synthesize a Cloudformation template
To list the availble stacks
```bash
cdk ls
```
In my case I get the result `helloaws`. To synthesize:
```bash
cdk synth
```






> Written with [StackEdit](https://stackedit.io/).
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTc5MDg3NDkzMiwtMTY2NTYxNTM3LDk5Mj
cwMjI4LC03MzQ5NDA1MTgsMTc0MjIxNzE0MiwxMDUxOTczMTYw
LDE1NDMwNDgxMDYsLTE0MTczMjM2OTQsMTAzOTUwNzQwMywtOD
E5MjQxMTcwLC01Njk0Njk4MTBdfQ==
-->