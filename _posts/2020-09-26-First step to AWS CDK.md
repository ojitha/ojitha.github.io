---
layout: post
title: "First step to AWS CDK"
date:   2020-09-26 13:01:30 +1000
categories: [AWS]
excerpt_separator: <!--more-->
---

This is my first step of using AWS CDK in macOS.  I am using Pyenv tool to create python enviroment  as explained in the [Python my workflow](https://ojitha.blogspot.com/2020/05/python-my-workflow.html).

Here the simple example created using AWS CDK.

[![helloaws](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/helloaws.png)](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/helloaws.png)

Followed [AWS CDK Python workshop](https://cdkworkshop.com/30-python.html).

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

Here the ouput
```yaml
Resources:
  HelloawsQueue99542750:
    Type: AWS::SQS::Queue
    Properties:
      VisibilityTimeout: 300
    Metadata:
      aws:cdk:path: helloaws/HelloawsQueue/Resource
  HelloawsQueuePolicy3ED87862:
    Type: AWS::SQS::QueuePolicy
    Properties:
      PolicyDocument:
        Statement:
          - Action: sqs:SendMessage
            Condition:
              ArnEquals:
                aws:SourceArn:
                  Ref: HelloawsTopic419BCE5E
            Effect: Allow
            Principal:
              Service: sns.amazonaws.com
            Resource:
              Fn::GetAtt:
                - HelloawsQueueN95NNN50
                - Arn
        Version: "2012-10-17"
      Queues:
        - Ref: HelloawsQueueN95NNN50
    Metadata:
      aws:cdk:path: helloaws/HelloawsQueue/Policy/Resource
  HelloawsQueuehelloawsHelloawsTopic05A44NNA13C4E1C5:
    Type: AWS::SNS::Subscription
    Properties:
      Protocol: sqs
      TopicArn:
        Ref: HelloawsTopic419BCE5E
      Endpoint:
        Fn::GetAtt:
          - HelloawsQueue9N95NNN50
          - Arn
    Metadata:
      aws:cdk:path: helloaws/HelloawsQueue/helloawsHelloawsTopic05A4499A/Resource
  HelloawsTopic418BCE5E:
    Type: AWS::SNS::Topic
    Metadata:
      aws:cdk:path: helloaws/HelloawsTopic/Resource
  CDKMetadata:
    Type: AWS::CDK::Metadata
    Properties:
      Modules: ...
```

## Bootstrapping and deployment
First titme you have have to install the bootstrap stack which is necessary for the toolkit.

```bash
cdk bootstrap
```
Now time to deply as follows:
```bash
cdk  deploy helloaws
```
Now you are ready to create your own application

## Create a real application
You have to clean up the sample-app SNS and the SQS form the helloaws_stack.py. It is better to use the following command to see the impact when you deploy new stack compared to existing:

```bash
cdk diff
```
if you are starisfied,  run the following command to update the stack:

```bash
cdk deploy
```

I have followed the [AWS CDK Python workshop](https://cdkworkshop.com/30-python.html) form this point onwards.

To delete the stack

```bash
cdk destroy
```

<!--stackedit_data:
eyJoaXN0b3J5IjpbMTI2NjA5OTc0OCwxNDA3ODQ4MjIwXX0=
-->
