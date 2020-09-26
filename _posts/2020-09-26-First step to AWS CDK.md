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

here the ouput
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
                  Ref: HelloawsTopic418BCE5E
            Effect: Allow
            Principal:
              Service: sns.amazonaws.com
            Resource:
              Fn::GetAtt:
                - HelloawsQueue99542750
                - Arn
        Version: "2012-10-17"
      Queues:
        - Ref: HelloawsQueue99542750
    Metadata:
      aws:cdk:path: helloaws/HelloawsQueue/Policy/Resource
  HelloawsQueuehelloawsHelloawsTopic05A4499A13C4E1C5:
    Type: AWS::SNS::Subscription
    Properties:
      Protocol: sqs
      TopicArn:
        Ref: HelloawsTopic418BCE5E
      Endpoint:
        Fn::GetAtt:
          - HelloawsQueue99542750
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
      Modules: aws-cdk=1.64.1,@aws-cdk/assets=1.64.1,@aws-cdk/aws-applicationautoscaling=1.64.1,@aws-cdk/aws-autoscaling-common=1.64.1,@aws-cdk/aws-cloudwatch=1.64.1,@aws-cdk/aws-codeguruprofiler=1.64.1,@aws-cdk/aws-ec2=1.64.1,@aws-cdk/aws-efs=1.64.1,@aws-cdk/aws-events=1.64.1,@aws-cdk/aws-iam=1.64.1,@aws-cdk/aws-kms=1.64.1,@aws-cdk/aws-lambda=1.64.1,@aws-cdk/aws-logs=1.64.1,@aws-cdk/aws-s3=1.64.1,@aws-cdk/aws-s3-assets=1.64.1,@aws-cdk/aws-sns=1.64.1,@aws-cdk/aws-sns-subscriptions=1.64.1,@aws-cdk/aws-sqs=1.64.1,@aws-cdk/aws-ssm=1.64.1,@aws-cdk/cloud-assembly-schema=1.64.1,@aws-cdk/core=1.64.1,@aws-cdk/cx-api=1.64.1,@aws-cdk/region-info=1.64.1,jsii-runtime=Python/3.8.0


```




> Written with [StackEdit](https://stackedit.io/).
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTI1NjY2OTc3NywtMTY2NTYxNTM3LDk5Mj
cwMjI4LC03MzQ5NDA1MTgsMTc0MjIxNzE0MiwxMDUxOTczMTYw
LDE1NDMwNDgxMDYsLTE0MTczMjM2OTQsMTAzOTUwNzQwMywtOD
E5MjQxMTcwLC01Njk0Njk4MTBdfQ==
-->