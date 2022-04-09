---
layout: post
title:  AWS CFN - Create VPC and subnets
date:   2022-04-01
categories: [AWS]
---

This is very basic example of creating AWS VPC and the subnets using AWS Cloudformation(CFN).

![image-20220409123443526](/assets/images/2022-04-01-Create VPC and subnets using AWS CFN/image-20220409123443526.png)

<!--more-->

Here the CFN yaml to create the above architecture. If you want more information, please visit the reference[^1] I used to create this post. 

```yaml
AWSTemplateFormatVersion: "2010-09-09"
Description: My VPC example
Parameters:
  VpcCidrPrefix:
    Description: prefix for the CIDER
    Type: String
    AllowedPattern: "(\\d{1,3})\\.(\\d{1,3})"

Resources:
  Vpc:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Join [ "", [!Ref VpcCidrPrefix, ".0.0/21"]]
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: !Ref AWS::StackName

  subnetDmzA:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: !Select [0, !GetAZs ""]
      CidrBlock: !Join ["", [!Ref VpcCidrPrefix, ".0.0/24"]]
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: DEV-DMZ A
        - Key: Scope
          Value: public
      VpcId: !Ref Vpc

  subnetDmzB:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: !Select [1, !GetAZs ""]
      CidrBlock: !Join ["", [!Ref VpcCidrPrefix, ".1.0/24"]]
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: DEV-DMZ B
        - Key: Scope
          Value: public
      VpcId: !Ref Vpc    

  subnetDmzC:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: !Select [2, !GetAZs ""]
      CidrBlock: !Join ["", [!Ref VpcCidrPrefix, ".2.0/24"]]
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: DEV-DMZ C
        - Key: Scope
          Value: public
      VpcId: !Ref Vpc

  subnetAppA:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: !Select [0, !GetAZs ""]
      CidrBlock: !Join ["", [!Ref VpcCidrPrefix, ".3.0/24"]]
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: DEV-APP B
        - Key: Scope
          Value: private
      VpcId: !Ref Vpc 

  subnetAppB:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: !Select [1, !GetAZs ""]
      CidrBlock: !Join ["", [!Ref VpcCidrPrefix, ".4.0/24"]]
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: DEV-APP B
        - Key: Scope
          Value: private
      VpcId: !Ref Vpc  

  subnetAppC:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: !Select [2, !GetAZs ""]
      CidrBlock: !Join ["", [!Ref VpcCidrPrefix, ".5.0/24"]]
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: DEV-APP C
        - Key: Scope
          Value: private
      VpcId: !Ref Vpc 

  subnetDbA:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: !Select [0, !GetAZs ""]
      CidrBlock: !Join ["", [!Ref VpcCidrPrefix, ".6.0/28"]]
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: DEV-DB A
        - Key: Scope
          Value: private
      VpcId: !Ref Vpc

  subnetDbB:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: !Select [1, !GetAZs ""]
      CidrBlock: !Join ["", [!Ref VpcCidrPrefix, ".6.16/28"]]
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: DEV-DB B
        - Key: Scope
          Value: private
      VpcId: !Ref Vpc  

  subnetDbC:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: !Select [2, !GetAZs ""]
      CidrBlock: !Join ["", [!Ref VpcCidrPrefix, ".6.32/28"]]
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: DEV-DB C
        - Key: Scope
          Value: private
      VpcId: !Ref Vpc 

Outputs:
  VpcId:
    Description: "VPC ID"
    Value: !Ref Vpc
    Export:
      Name: !Sub ${AWS::StackName}-VpcId

  VpcCidr:
    Description: "VPC ID"
    Value: !GetAtt Vpc.CidrBlock
    Export:
      Name: !Sub  ${AWS::StackName}-VpcCidr

  DmzSubnetAId:
    Description: "DMZ A subnet ID"
    Value: !Ref subnetDmzA
    Export:
      Name: !Sub ${AWS::StackName}-DmzSubnetAId     

  DmzSubnetBId:
    Description: "DMZ B subnet ID"
    Value: !Ref subnetDmzB
    Export:
      Name: !Sub ${AWS::StackName}-DmzSubnetBId  

  DmzSubnetCId:
    Description: "DMZ C subnet ID"
    Value: !Ref subnetDmzC
    Export:
      Name: !Sub ${AWS::StackName}-DmzSubnetCId  

  SubnetAppAId:
    Description: "App A subnet ID"
    Value: !Ref subnetAppA
    Export:
      Name: !Sub ${AWS::StackName}-SubnetAppAId              

  SubnetAppBId:
    Description: "App B subnet ID"
    Value: !Ref subnetAppB
    Export:
      Name: !Sub ${AWS::StackName}-SubnetAppBId      

  SubnetAppCId:
    Description: "App C subnet ID"
    Value: !Ref subnetAppC
    Export:
      Name: !Sub ${AWS::StackName}-SubnetAppCId     

  SubnetDbAId:
    Description: "DB A subnet ID"
    Value: !Ref subnetDbA
    Export:
      Name: !Sub ${AWS::StackName}-SubnetDbAId

  SubnetDbBId:
    Description: "DB B subnet ID"
    Value: !Ref subnetDbB
    Export:
      Name: !Sub ${AWS::StackName}-SubnetDbBId

  SubnetDbCId:
    Description: "DB C subnet ID"
    Value: !Ref subnetDbC
    Export:
      Name: !Sub ${AWS::StackName}-SubnetDbCId    
       
```



[![Fig.1: Stack](/assets/images/2022-04-01-Create VPC and subnets using AWS CFN/image-20220403233513054.png)](/assets/images/2022-04-01-Create VPC and subnets using AWS CFN/image-20220403233513054.png){:target="_blank"}

Validate the template:

```bash
aws cloudformation validate-template --template-body file://vpc-example-1.yaml
```

If there is no errors create the stack

```bash
aws cloudformation create-stack --template-body file://vpc-example-1.yaml --parameters ParameterKey=VpcCidrPrefix,ParameterValue=10.0  --stack-name oj-test-stack
```

To list all the exports

```bash
aws cloudformation list-exports --query 'Exports[].[Name,Value]' --output table
```

The output will be

```
------------------------------------------------------------
|                        ListExports                       |
+-----------------------------+----------------------------+
|  oj-test-stack-DmzSubnetAId |  subnet-0fb6a12ac99d3b1e6  |
|  oj-test-stack-DmzSubnetBId |  subnet-03882aa1d2eadbd78  |
|  oj-test-stack-DmzSubnetCId |  subnet-01e4c2fa5bbb158b4  |
|	 ...                        |  ...                       |
|  oj-test-stack-VpcCidr      |  10.0.0.0/21               |
|  oj-test-stack-VpcId        |  vpc-055a7ad17ccfa1fb7     |
+-----------------------------+----------------------------+
```

if you want information about the above VPC created as `oj-test-stack`:

```bash
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=oj-test-stack"
```

to get only the VpcId:

```bash
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=oj-test-stack" --query 'Vpcs[0].VpcId' --output text
```

if you wants to use the above VpcId , then assign that to a variable

```bash
VPC_ID=$(aws ec2...above command)
```

For example to list all the subnets and its cidr block:

```bash
aws ec2 describe-subnets --filters "Name=vpc-id,Values=${VPC_ID}" --query 'Subnets[].[SubnetId,CidrBlock,Tags[?Key==`Scope`]|[0].Value]' --output table
```

the output will be

```
---------------------------------------------------------
|                    DescribeSubnets                    |
+---------------------------+----------------+----------+
|  subnet-01355rt561041ec99 |  10.0.6.16/28  |  private |
|  subnet-...               |  10.0.3.0/24   |  private |
|  subnet-...               |  10.0.6.32/28  |  private |
|  ...                      |  10.0.1.0/24   |  public  |
|  subnet-...               |  10.0.0.0/24   |  public  |
|  subnet-...               |  10.0.2.0/24   |  public  |
+---------------------------+----------------+----------+
```

More information such as AZ and number of availble IPs, you can get as follows:

```bash
aws ec2 describe-subnets --filters "Name=vpc-id,Values=${VPC_ID}" --query 'Subnets[].[Tags[?Key==`Name`]|[0].Value,SubnetId,CidrBlock,Tags[?Key==`Scope`]|[0].Value,AvailableIpAddressCount,AvailabilityZone]' --output table
```

[^1]: [Automation in AWS with CloudFormation, CLI, and SDKs](https://learning.oreilly.com/videos/automation-in-aws/9780134818313/),[Richard A. Jones](https://learning.oreilly.com/search/?query=author%3A%22Richard%20A.%20Jones%22&sort=relevance&highlight=true)

