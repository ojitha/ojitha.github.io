---
layout: post
title:  Glue Development using Jupyter
date:   2022-07-11
categories: [AWS, Glue, Jupyter]
---

Developing and testing the Glue job in the viscose IDE is one of the best development opportunities because Jupyter doesn't support IDE features. 
In this blog, I set up a Glue docker instance in the EC2 and use the vscode Jupyter notebook feature to develop Glue jobs. If you want to create more customized your own Docker image, please see [AWS Glue run locally]({% post_url 2022-08-13-AWS-Glue-run-locally %}).

<!--more-->


## Docker-based environment
First, you have to Docker on Amazon Linux as explained in the [install](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install-linux.html). 

to start the docker service
```bash
sudo service docker start
```

Create a docker instance based on the Glue 3:

```bash
docker run -it -v ~/.aws:/home/glue_user/.aws -v "$(pwd)":/home/glue_user/workspace/jupyter_workspace/ -e AWS_PROFILE=$PROFILE_NAME -e DISABLE_SSL=true --rm -p 4040:4040 -p 8888:8888 --name glue_pyspark amazon/aws-glue-libs:glue_libs_3.0.0_image_01
```
This will take you to the container bash shell.

In the container bash prompt, if you want _optionally_ install any library before using any notebook. For example, pyathena to access AWS Athena:

```bash
pip3 install pyathena
```

It is **required** to start the livy server. Run the following command in the container bash shell prompt:

```bash
livy-server start
```

and run the notebook

```bash
jupyter lab --no-browser --ip=0.0.0.0 --allow-root --ServerApp.root_dir=/home/glue_user/workspace/jupyter_workspace/ --ServerApp.token='pyspark' --ServerApp.password=''
```

## Notebook for JDBC access
You have to specify the JDBC driver file in the Jupyter before access:

```python
%%configure -f
{"conf": {
    "spark.jars": "s3://<s3-bucket>/jdbc/AthenaJDBC42.jar"
    }
}   
```

Create a glue context:

```python
from awsglue.job import Job
from awsglue.context import GlueContext

glueContext = GlueContext(spark)
```

Create a database JDBC connection

```python
from datetime import datetime
con = (
    glueContext.read.format("jdbc")
    .option("driver", "com.simba.athena.jdbc.Driver")
    .option("AwsCredentialsProviderClass","com.simba.athena.amazonaws.auth.InstanceProfileCredentialsProvider")
    .option("url", "jdbc:awsathena://athena.ap-southeast-2.amazonaws.com:443")
    .option("S3OutputLocation","s3://{}/temp/{}".format('<s3 bucket>', datetime.now().strftime("%m%d%y%H%M%S")))
 )
```

Create spark data frame from the JDBC executing SQL specified in the `query` variable:

```python
glue_df = con.option('query', query).load()
glue_df.show(10)
```

## Using pyathena

Create a coursor
```python
from pyathena import connect
cursor = connect(s3_staging_dir="s3://<s3-bucket>/temp/",
                 region_name="ap-southeast-2").cursor()
```

Execute the cursor and get the result set:
```python
cursor.execute(query)
print(cursor.description)
```

Load the data to dataframe
```python
import pandas as pd
from pyathena.pandas.util import as_pandas
df = as_pandas(cursor)
df
```

You can create EC2 based development environment using the following CFN:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: Create Dev environment

Parameters:
  UserName:
    Type: String
    Description: Please provide first name to create the environment
    Default: ojitha

VpcId:
    Type: String
    Description: Vpc id where to launch an EC2

  SubnetId:
    Type: String
    Description: Private Subnet where to launch an EC2

  MyPublicKey:
    Type: String
    Description: Please provide your public key


Resources:
  SGForDevEC2:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Open SSH port 22 for the EC2 development environment
      GroupName: dev-security-group
      VpcId: !Ref VpcId
      SecurityGroupIngress:
        - IpProtocol: tcp
          CidrIp: <cider ip range>
          FromPort: 22
          ToPort: 22
        - IpProtocol: tcp
          CidrIp: <cider ip range>
          FromPort: 22
          ToPort: 22
      SecurityGroupEgress:
        - IpProtocol: -1
          CidrIp: 0.0.0.0/0
          FromPort: -1
          ToPort: -1
      Tags:
        - Key: Name
          Value: 
            !Join 
              - "-"
              - - !Sub ${UserName}
                - 'dev'
                - 'sg'  
  UserPublicKey:
    Type: AWS::EC2::KeyPair
    Properties:
      KeyName: 
        !Join 
          - "-"
          - - !Sub ${UserName}
            - 'dev'
            - 'key'
      PublicKeyMaterial: !Ref MyPublicKey
  
  EC2ForDev:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-07620139298af599e
      InstanceType: t2.large
      SubnetId: !Ref SubnetId
      KeyName: !Ref UserPublicKey
      SecurityGroupIds:
        - !GetAtt  SGForDevEC2.GroupId
      IamInstanceProfile: !Ref RootInstanceProfile
      BlockDeviceMappings:
        - DeviceName: /dev/xvda
          Ebs:
            VolumeSize: 30
            Encrypted: true
            VolumeType: gp2
            DeleteOnTermination: true
      UserData: 
        Fn::Base64: |
          #!/bin/bash
          yum update -y
          yum -y install tmux
          yum -y install @development zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel findutils
          curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
          unzip -u awscliv2.zip
          ./aws/install
          wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
          unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
          ./sam-installation/install
          amazon-linux-extras install -y docker
          usermod -a -G docker ec2-user
          chmod 666 /var/run/docker.sock

      Tags:
        - Key: Name
          Value:
            !Join 
              - "-"
              - - !Sub ${UserName}
                - 'dev'
                - 'ec2' 
  CPUAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmDescription: CPU alarm to stop Dev instance
      AlarmName: 
        !Join 
          - "-"
          - - !Sub ${UserName}
            - 'dev'
            - 'alarm'
            - 'stop'      
      ActionsEnabled: true
      AlarmActions: [ !Sub "arn:aws:automate:${AWS::Region}:ec2:stop" ]
      MetricName: CPUUtilization
      Namespace: AWS/EC2
      Statistic: Average
      Period: '900'
      EvaluationPeriods: '3'
      Threshold: '0.3'
      ComparisonOperator: LessThanOrEqualToThreshold
      Dimensions:
      - Name: InstanceId
        Value:
          Ref: EC2ForDev

  RootRole: 
    Type: "AWS::IAM::Role"
    Properties: 
      RoleName: 
        !Join 
          - "-"
          - - !Sub ${UserName}
            - 'dev'
            - 'ROOT'
            - 'role'
      AssumeRolePolicyDocument: 
        Version: "2012-10-17"
        Statement: 
          - 
            Effect: "Allow"
            Principal: 
              Service: 
                - "ec2.amazonaws.com"
            Action: 
              - "sts:AssumeRole"
      Path: "/"
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/PowerUserAccess
  
  CFNPolicies: 
    Type: "AWS::IAM::Policy"
    Properties: 
      PolicyName: "CFNPolicy"
      PolicyDocument: 
        Version: "2012-10-17"
        Statement:
        - Action:
            - cloudformation:*
            - lambda:*
            - sns:*
            - events:*
            - logs:*
            - ec2:*
            - s3:*
            - dynamodb:*
            - kms:*
            - iam:*
            - states:*
            - sts:*
            - sqs:*
            - elasticfilesystem:*
            - config:*
            - cloudwatch:*
            - apigateway:*
            - backup:*
            - firehose:*
            - backup-storage:*
            - ssm:*
          Resource: '*'
          Effect: Allow
      Roles: 
        - Ref: "RootRole" 
  VSCodePolicies: 
    Type: "AWS::IAM::Policy"
    Properties: 
      PolicyName: "VSCode"
      PolicyDocument: 
        Version: "2012-10-17"
        Statement:
        - Sid: CloudFormationTemplate
          Effect: Allow
          Action:
            - cloudformation:CreateChangeSet
          Resource:
            - arn:aws:cloudformation:*:aws:transform/Serverless-2016-10-31
        - Sid: CloudFormationStack
          Effect: Allow
          Action:
            - cloudformation:CreateChangeSet
            - cloudformation:CreateStack
            - cloudformation:DeleteStack
            - cloudformation:DescribeChangeSet
            - cloudformation:DescribeStackEvents
            - cloudformation:DescribeStacks
            - cloudformation:ExecuteChangeSet
            - cloudformation:GetTemplateSummary
            - cloudformation:ListStackResources
            - cloudformation:UpdateStack
          Resource:
            - arn:aws:cloudformation:*:111111111111:stack/*
        - Sid: S3
          Effect: Allow
          Action:
            - s3:CreateBucket
            - s3:GetObject
            - s3:PutObject
          Resource:
            - arn:aws:s3:::*/*
        - Sid: ECRRepository
          Effect: Allow
          Action:
            - ecr:BatchCheckLayerAvailability
            - ecr:BatchGetImage
            - ecr:CompleteLayerUpload
            - ecr:CreateRepository
            - ecr:DeleteRepository
            - ecr:DescribeImages
            - ecr:DescribeRepositories
            - ecr:GetDownloadUrlForLayer
            - ecr:GetRepositoryPolicy
            - ecr:InitiateLayerUpload
            - ecr:ListImages
            - ecr:PutImage
            - ecr:SetRepositoryPolicy
            - ecr:UploadLayerPart
          Resource:
            - arn:aws:ecr:*:111111111111:repository/*
        - Sid: ECRAuthToken
          Effect: Allow
          Action:
            - ecr:GetAuthorizationToken
          Resource:
            - '*'
        - Sid: Lambda
          Effect: Allow
          Action:
            - lambda:AddPermission
            - lambda:CreateFunction
            - lambda:DeleteFunction
            - lambda:GetFunction
            - lambda:GetFunctionConfiguration
            - lambda:ListTags
            - lambda:RemovePermission
            - lambda:TagResource
            - lambda:UntagResource
            - lambda:UpdateFunctionCode
            - lambda:UpdateFunctionConfiguration
          Resource:
            - arn:aws:lambda:*:111111111111:function:*
        - Sid: IAM
          Effect: Allow
          Action:
            - iam:CreateRole
            - iam:AttachRolePolicy
            - iam:DeleteRole
            - iam:DetachRolePolicy
            - iam:GetRole
            - iam:TagRole
          Resource:
            - arn:aws:iam::111111111111:role/*
        - Sid: IAMPassRole
          Effect: Allow
          Action: iam:PassRole
          Resource: '*'
          Condition:
            StringEquals:
              iam:PassedToService: lambda.amazonaws.com
        - Sid: APIGateway
          Effect: Allow
          Action:
            - apigateway:DELETE
            - apigateway:GET
            - apigateway:PATCH
            - apigateway:POST
            - apigateway:PUT
          Resource:
            - arn:aws:apigateway:*::*
      Roles: 
        - Ref: "RootRole"

  AthenaPolicies: 
    Type: "AWS::IAM::Policy"
    Properties: 
      PolicyName: "Athena"
      PolicyDocument: 
        Version: "2012-10-17"
        Statement: 
        - Action:
            - athena:ListEngineVersions
            - athena:ListWorkGroups
            - athena:ListDataCatalogs
            - athena:ListDatabases
            - athena:GetDatabase
            - athena:ListTableMetadata
            - athena:GetTableMetadata
          Resource: '*'
          Effect: Allow
          Sid: athenaglobal
        - Action:
            - athena:GetQueryResultsStream
            - athena:GetWorkGroup
            - athena:GetQueryExecution
            - athena:CreatePreparedStatement
            - athena:GetPreparedStatement
            - athena:ListPreparedStatements
            - athena:UpdatePreparedStatement
            - athena:DeletePreparedStatement
            - athena:StartQueryExecution
            - athena:StopQueryExecution
            - athena:GetQueryResults
          Resource:
            - arn:aws:athena:ap-southeast-2:111111111111:workgroup/primary
          Effect: Allow
          Sid: athenaWorkgroup
      Roles: 
        - Ref: "RootRole"

  S3Policies: 
    Type: "AWS::IAM::Policy"
    Properties: 
      PolicyName: "S3Policies"
      PolicyDocument: 
        Version: "2012-10-17"
        Statement: 
        - Action:
            - s3:GetObject
            - s3:ListBucket
          Resource:
            - arn:aws:s3:::111111111111-<...athena...>-prod*
            - arn:aws:s3:::111111111111-<...athena...>-prod*/*
          Effect: Allow
          Sid: S3Polices
        - Action:
            - s3:*
          Resource:
            - arn:aws:s3:::111111111111-oj-temp
            - arn:aws:s3:::111111111111-oj-temp/*
          Effect: Allow
        - Action:
            - s3:GetObject
            - s3:PutObject
            - s3:ListBucket
            - s3:DeleteObject
          Resource:
            - arn:aws:s3:::111111111111-oj-glue
            - arn:aws:s3:::111111111111-oj-glue/*
          Effect: Allow
      Roles: 
        - Ref: "RootRole"

  # # use this template if you need to add access 
  # RolePolicies: 
  #   Type: "AWS::IAM::Policy"
  #   Properties: 
  #     PolicyName: "root"
  #     PolicyDocument: 
  #       Version: "2012-10-17"
  #       Statement: 
  #         - Effect: "Allow"
  #           Action: "*"
  #           Resource: "*"
  #     Roles: 
  #       - Ref: "RootRole"

  RootInstanceProfile: 
    Type: "AWS::IAM::InstanceProfile"
    Properties: 
      Path: "/"
      Roles: 
        - Ref: "RootRole"
```
