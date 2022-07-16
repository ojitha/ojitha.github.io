---
layout: notes 
title: DevOps
---
**Notes on DevOps**

* TOC
{:toc}

Here the important commands and information collected while programming. 

## AWS

### EC2 Role for the vscode
If your EC2 instance has been created in the private subnet, you have to create a role with the following policies:
NOTE: Trust relationship should be the EC2 and the developer should be with the `PowerUserAccess`.

```yaml
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudformation:*",
                "lambda:*",
                "sns:*",
                "events:*",
                "logs:*",
                "ec2:*",
                "s3:*",
                "dynamodb:*",
                "kms:*",
                "iam:*",
                "states:*",
                "sts:*",
                "sqs:*",
                "elasticfilesystem:*",
                "config:*",
                "cloudwatch:*",
                "apigateway:*",
                "backup:*",
                "firehose:*",
                "backup-storage:*",
                "ssm:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

and 

```yaml
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CloudFormationTemplate",
            "Effect": "Allow",
            "Action": [
                "cloudformation:CreateChangeSet"
            ],
            "Resource": [
                "arn:aws:cloudformation:*:aws:transform/Serverless-2016-10-31"
            ]
        },
        {
            "Sid": "CloudFormationStack",
            "Effect": "Allow",
            "Action": [
                "cloudformation:CreateChangeSet",
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeChangeSet",
                "cloudformation:DescribeStackEvents",
                "cloudformation:DescribeStacks",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:GetTemplateSummary",
                "cloudformation:ListStackResources",
                "cloudformation:UpdateStack"
            ],
            "Resource": [
                "arn:aws:cloudformation:*:<account id>:stack/*"
            ]
        },
        {
            "Sid": "S3",
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::*/*"
            ]
        },
        {
            "Sid": "ECRRepository",
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:CompleteLayerUpload",
                "ecr:CreateRepository",
                "ecr:DeleteRepository",
                "ecr:DescribeImages",
                "ecr:DescribeRepositories",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:InitiateLayerUpload",
                "ecr:ListImages",
                "ecr:PutImage",
                "ecr:SetRepositoryPolicy",
                "ecr:UploadLayerPart"
            ],
            "Resource": [
                "arn:aws:ecr:*:<account id>:repository/*"
            ]
        },
        {
            "Sid": "ECRAuthToken",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "Lambda",
            "Effect": "Allow",
            "Action": [
                "lambda:AddPermission",
                "lambda:CreateFunction",
                "lambda:DeleteFunction",
                "lambda:GetFunction",
                "lambda:GetFunctionConfiguration",
                "lambda:ListTags",
                "lambda:RemovePermission",
                "lambda:TagResource",
                "lambda:UntagResource",
                "lambda:UpdateFunctionCode",
                "lambda:UpdateFunctionConfiguration"
            ],
            "Resource": [
                "arn:aws:lambda:*:<account id>:function:*"
            ]
        },
        {
            "Sid": "IAM",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "iam:DeleteRole",
                "iam:DetachRolePolicy",
                "iam:GetRole",
                "iam:TagRole"
            ],
            "Resource": [
                "arn:aws:iam::<account id>:role/*"
            ]
        },
        {
            "Sid": "IAMPassRole",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "lambda.amazonaws.com"
                }
            }
        },
        {
            "Sid": "APIGateway",
            "Effect": "Allow",
            "Action": [
                "apigateway:DELETE",
                "apigateway:GET",
                "apigateway:PATCH",
                "apigateway:POST",
                "apigateway:PUT"
            ],
            "Resource": [
                "arn:aws:apigateway:*::*"
            ]
        }
    ]
}
```

### AWS KMS

```bash
#encrypt the password: InsightReadWrite
aws kms encrypt --key-id cfc7acf7-4f20-49c3-aa11-8be4cdc3291d --output text --query CiphertextBlob --plaintext InsightReadWrite

#encrypt the password: InsightReadWrite
aws kms encrypt --key-id cfc7acf7-4f20-49c3-aa11-8be4cdc3291d --plaintext fileb://test.txt --output text | base64 --decode > out.txt

#decrypt the password: InsightReadWrite
aws kms decrypt  --ciphertext-blob fileb://out.txt --output text --query Plaintext | base64 --decode
```

### AWS Kinesis

AWS Kinesis shows only example shows only one sequence. This is the record I found from the log with multiple sequences:

```json
{
    u 'Records': [{
        u 'eventVersion': u '1.0',
        u 'eventID': u 'shardId-000000000000:49559921416499955208897145459995453707469374714070171650',
        u 'kinesis': {
            u 'approximateArrivalTimestamp': 1502065218.908,
            u 'partitionKey': u 'TI2I7c',
            u 'data': u '<data1>',
            u 'kinesisSchemaVersion': u '1.0',
            u 'sequenceNumber': u '49559921416499955208897145459995453707469374714070171650'
        },
        u 'invokeIdentityArn': u 'arn:aws:iam::389920326251:role/Lambda-execution-role-Uat',
        u 'eventName': u 'aws:kinesis:record',
        u 'eventSourceARN': u 'arn:aws:kinesis:ap-southeast-2:389920326251:stream/ticketing-uat',
        u 'eventSource': u 'aws:kinesis',
        u 'awsRegion': u 'ap-southeast-2'
    }, {
        u 'eventVersion': u '1.0',
        u 'eventID': u 'shardId-000000000000:49559921416499955208897145459996662633288989343244877826',
        u 'kinesis': {
            u 'approximateArrivalTimestamp': 1502065218.908,
            u 'partitionKey': u 'ihwN32',
            u 'data': u '<data2>',
            u 'kinesisSchemaVersion': u '1.0',
            u 'sequenceNumber': u '49559921416499955208897145459996662633288989343244877826'
        },
        u 'invokeIdentityArn': u 'arn:aws:iam::389920326251:role/Lambda-execution-role-Uat',
        u 'eventName': u 'aws:kinesis:record',
        u 'eventSourceARN': u 'arn:aws:kinesis:ap-southeast-2:389920326251:stream/ticketing-uat',
        u 'eventSource': u 'aws:kinesis',
        u 'awsRegion': u 'ap-southeast-2'
    }, {
        u 'eventVersion': u '1.0',
        u 'eventID': u 'shardId-000000000000:49559921416499955208897145460000289410747833230768996354',
        u 'kinesis': {
            u 'approximateArrivalTimestamp': 1502065218.913,
            u 'partitionKey': u 'PoGyUG',
            u 'data': u 'H4sIAAAAAAAAAzMAACHf2/QBAAAA',
            u 'kinesisSchemaVersion': u '1.0',
            u 'sequenceNumber': u '<data3>'
        },
        u 'invokeIdentityArn': u 'arn:aws:iam::389920326251:role/Lambda-execution-role-Uat',
        u 'eventName': u 'aws:kinesis:record',
        u 'eventSourceARN': u 'arn:aws:kinesis:ap-southeast-2:389920326251:stream/ticketing-uat',
        u 'eventSource': u 'aws:kinesis',
        u 'awsRegion': u 'ap-southeast-2'
    }]
}
```

### AWS Cloudformation

Stack creation with IAM role

Here the role CF:

```yaml
AWSTemplateFormatVersion: "2010-09-09"
Description: create IAM role

Resources:
  IamRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - Sid: AllowAssumeRole
            Effect: Allow
            Principal:
              Service: "cloudformation.amazonaws.com"
            Action: "sts:AssumeRole"
      ManagedPolicyArns:
        - "arn:aws:iam::aws:policy/AdministratorAccess"
Outputs:
  IamRole:
    Value: !GetAtt IamRole.Arn     
```

Then create a stack from the file:

```bash
aws cloudformation create-stack --stack-name cfniamrole --capabilities CAPABILITY_IAM --template-body file://MyIamRole.yaml
```

Get the IAM Role ARN to the following variable `IAM_ROLE_ARN`

```bash
IAM_ROLE_ARN=$(aws cloudformation describe-stacks --stack-name cfniamrole --query "Stacks[0].Outputs[?OutputKey=='IamRole'].OutputValue" --output text)
```

Example, here the stack for a S3 bucket:

```yaml
AWSTemplateFormatVersion: "2010-09-09"
Description: This is my first bucket

Resources:
  ojithadeletebucket:
    Type: AWS::S3::Bucket
```

Create a bucket using `IAM_ROLE_ARN` role and the CF file.

```bash
aws cloudformation create-stack --stack-name mybucket --template-body file://mybucket.yaml --role-arn $IAM_ROLE_ARN
```

Delete the stack as this way:

```bash
for i in mybucket cfniamrole; do aws cloudformation delete-stack --stack-name  $i;done
```



### AWS Chalice

Package first :

```bash
aws cloudformation package --template-file out/sam.json --s3-bucket ojemr --output-template-file pkg.yaml
```

Deploy :

```bash
aws cloudformation deploy --template-file /home/cloudera/dev/hellochalice/pkg.yaml --stack-name hellochalice --capabilities CAPABILITY_IAM
```

SQL Server

Login to the docker:

```bash
docker exec -i -t 8ae7c51a90fe /bin/bash
```

Create a new folder in the /var/opt/mssql

```bash
cd /var/opt/mssql/
mkdir backup
```

Download the AdventureWork from https://msftdbprodsamples.codeplex.com/downloads/get/880661 to your local machine and unzip.

```bash
docker cp AdventureWorks2014.bak 8ae7c51a90fe:/var/opt/mssql/backup
```

In your host machine use the sqlcmd

```bash
sqlcmd -S 127.0.0.1 -U SA -P '<password>'
```

Following the link https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-migrate-restore-database

Restore the backup file:

```bash
RESTORE DATABASE AdventureWorks
FROM DISK = '/var/opt/mssql/backup/AdventureWorks2014.bak'
WITH MOVE 'AdventureWorks2014_Data' TO '/var/opt/mssql/data/AdventureWorks2014_Data.mdf',
MOVE 'AdventureWorks2014_Log' TO '/var/opt/mssql/data/AdventureWorks2014_Log.ldf'
GO
```

How to start docker again

```bash
#find the container id
docker ps -a
#start that container id
docker start <container-id>
```
## Status Codes

- 1nn: informational
- 2nn: success
- 3nn: redirection
- 4nn: client errors
- 5nn: server errors

## 200 common

- 200 ok: everything ok
- 201 created: Returns a location header for new resources
- 202 Accepted: Server has accepted the request, but it is not yet complete.

## 400 common

- 400 Bad Request: Malformed Syntax, retry with change
- 401 Unauthorized: Authentication is required
- 403 Forbidded: Server has understood, but refuses request
- 404 Not Found: Server can't find a resource for URI
- 406 Incompatible: Incompatible Accept headers specified
- 409 Conflict: Resource conflicts with client request

## Dynamodb

List all the tables

```bash
aws dynamodb list-tables
```

describe a table found in the above command:

```bash
aws dynamodb describe-table --table-name <table name> 
```



## Access AWS account from bash

```bash
echo $(aws sts get-caller-identity --query='Account' --output=text)
```





<!--stackedit_data:
eyJoaXN0b3J5IjpbLTEzODU4MjM3NzAsLTU3NDc5MTM5N119
-->
