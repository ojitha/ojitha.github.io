---
layout: post
title:  Access AWS SSM via AWS Stepfunctions
date:   2022-07-24
categories: [AWS]
---

Configuration will be availble throughout the pipeline, if that can be stored in the AWS Stepfunctions. Generally congiruation should be stored in the SSM parameter store. How to access the SSM parameter store from the AWS Stepfunction?

<!--more-->

For example, using AWS CLI, store the  in the AWS SSM parameter store:

```bash
aws ssm put-parameter --name "/my/config" --type String --overwrite  --value file://configurations/ssm/config.json
```
In the above command, the `configurations` is a immideate sub folder. The config.json contain your json type configuration.

You need to access the above parameter in the ASL code as follows:

```json
{
  "Type": "Task",
  "Parameters": {
    "Names": [
      "/my/config"
    ]
  },
  "Resource": "arn:aws:states:::aws-sdk:ssm:getParameters",
  "ResultSelector": {
    "ssm-parameters.$": "$.Parameters"
  },
  "End": true
}
```
Please refer to the [AWS SDK service integrations](https://docs.aws.amazon.com/step-functions/latest/dg/supported-services-awssdk.html) for more information.

Although it is simple, you have to specify the IAM role policy as follows:

```yml
  Statement:
    - Effect: Allow
      Action:
        - ssm:DescribeParameters
      Resource: '*'
    - Effect: Allow
      Action:
        - ssm:GetParameters
      Resource: 
        - !Sub arn:aws:ssm:${AWS::Region}:${AWS::AccountId}:parameter/my/config
```
please see for [more](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-access.html) information.
