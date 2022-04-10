---
layout: post
title:  AWS CFN - Create IGW and NAT
date:   2022-04-08
categories: [AWS]
---



In this post, let's see how to create Internet Gateway (IGW) and NAT Gateway using Cloudformation (CFN). 

[![Fig.1: Architect Diagram](/assets/images/2022-04-08-Create-IGWndNAT-using-AWS/image-20220410104530855.png)](/assets/images/2022-04-08-Create-IGWndNAT-using-AWS/image-20220410104530855.png){:target="_blank"}

This post is a continuation of the [AWS CFN - Create VPC and subnets]({% post_url 2022-04-01-Create VPC and subnets using AWS CFN %}).

<!--more-->

------

* TOC
{:toc}
------

The prerequisite for this post is [AWS Cloudformation to create AWS VPC](https://ojitha.blogspot.com/2021/06/aws-cloudformation-to-create-aws-vpc.html){:target="_blank"}.

There is one parameter to pass that is the VPC created earlier, for example, `ParameterKey=NetworkStack,ParameterValue=oj-test-stack` :

```yaml
AWSTemplateFormatVersion: "2010-09-09"
Description: IGW and RT public trafic

Parameters:
  NetworkStack:
    Type: "String"
    Description: "Apply to the network stack"
```

## IGW

The first resource is IGW:

```yaml
Resources:
  # Create IGW 
  IGW:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
      - Key: Name
        Value: !Ref AWS::StackName

  # Attached to the VPC      
  IGWAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      InternetGatewayId: !Ref IGW
      VpcId:
        Fn::ImportValue:
          !Sub ${NetworkStack}-VpcId 
```

Here `AWS::StackName` is the current stack name, for example `oj-test-igwandnat-stack`. The IGW has to create in the current stack and attached to the VPC, which is provided via `NetworkStack` from the parameter as shown in line# 17. The `VpcId` is derived property.

## Route Tables

```yaml
  # public Route Table
  publicRT:
    Type: AWS::EC2::RouteTable   
    Properties:
      VpcId: 
        Fn::ImportValue:
          !Sub ${NetworkStack}-VpcId
      Tags:
      - Key: Name
        Value: Dmz Routes
      - Key: Scope
        Value: public    

  # Add route to the route table                   
  publicRouteToInternet:
    DependsOn: IGWAttachment
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref publicRT
      GatewayId: !Ref IGW
      DestinationCidrBlock: 0.0.0.0/0

  # RT associate with subnets
  publicRTAssociationA:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref publicRT
      SubnetId: 
        Fn::ImportValue: !Sub ${NetworkStack}-DmzSubnetAId
```

There are 3 steps:

1. create the `publicRT` and attach it to the VPC. 

2. Then add the routes to the routeing table. All the traffic has to flow through the IGW except local route as follows:

    ![publicRT](/assets/images/2022-04-08-Create-IGWndNAT-using-AWS/publicRT.jpg)

3. Associate the routeing table to the subnet. 

For Apps, you need to create a private route table as follows:

```yaml
privateRT:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: 
        Fn::ImportValue:
          !Sub ${NetworkStack}-VpcId
      Tags:
      - Key: Name
        Value: App Routes
      - Key: Scope
        Value: private

  privateRouteToInternet:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: 
        Ref: privateRT
      DestinationCidrBlock: 0.0.0.0/0
      NatGatewayId: !Ref NatGateway     

  # RT associated with subnet
  privateRTAssociationA:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref privateRT
      SubnetId:
        Fn::ImportValue: !Sub ${NetworkStack}-SubnetAppAId 
```

In the AWS console,

![privateRT](/assets/images/2022-04-08-Create-IGWndNAT-using-AWS/privateRT.jpg)

In the second row, notice the nat-... which is created in the following section.

## NAT

As shown in the line# 3 `DependsOn`, NAT instance creation shouldn't start until IGW attachment has been completed.

```yaml
  # NAT
  NatGateway:
    DependsOn: IGWAttachment
    Type: AWS::EC2::NatGateway
    Properties:
      AllocationId: !GetAtt   ElasticIP.AllocationId # Meed EIP
      SubnetId:
         Fn::ImportValue: !Sub ${NetworkStack}-DmzSubnetAId      

  # Elastic IP
  ElasticIP:
    Type: AWS::EC2::EIP
    Properties:
      Domain: vpc    
```

For dedicated route, NAT Gateway need elastic IP.

[![image-20220410142015289](/assets/images/2022-04-08-Create-IGWndNAT-using-AWS/image-20220410142015289.png)](/assets/images/2022-04-08-Create-IGWndNAT-using-AWS/image-20220410142015289.png){:target="_blank"}

## Deploy

Command to validate

```bash
cloudformation validate-template --template-body file://vpc-example-1-1.yaml
```

To create the stack

```bash
aws cloudformation create-stack --template-body file://vpc-example-1-1.yaml --parameters ParameterKey=NetworkStack,ParameterValue=oj-test-stack  --stack-name oj-test-igwandnat-stack
```

If you want to get event information:

```bash
aws cloudformation describe-stack-events --stack-name oj-test-igwandnat-stack --query 'StackEvents[].[{Resource:LogicalResourceId, Status:ResourceStatus, Reason:REsourceStatusReason}]' --output table
```

Output:

```
-------------------------------------------------------------
|                    DescribeStackEvents                    |
+--------+---------------------------+----------------------+
| Reason |         Resource          |       Status         |
+--------+---------------------------+----------------------+
|  None  |  oj-test-igwandnat-stack  |  CREATE_COMPLETE     |
|  None  |  privateRouteToInternet   |  CREATE_COMPLETE     |
|  None  |  privateRouteToInternet   |  CREATE_IN_PROGRESS  |
|  None  |  privateRouteToInternet   |  CREATE_IN_PROGRESS  |
|  None  |  NatGateway               |  CREATE_COMPLETE     |
|  None  |  publicRouteToInternet    |  CREATE_COMPLETE     |
|  None  |  NatGateway               |  CREATE_IN_PROGRESS  |
|  None  |  publicRouteToInternet    |  CREATE_IN_PROGRESS  |
...
+--------+---------------------------+----------------------+
```

Please refer to the reference[^1] used to create this post for more information.

---

[^1]: [Automation in AWS with CloudFormation, CLI, and SDKs](https://learning.oreilly.com/videos/automation-in-aws/9780134818313/), Richard A. Jones

