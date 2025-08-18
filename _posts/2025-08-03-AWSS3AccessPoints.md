---
layout: post
title:  AWS S3 Access Points
date:   2025-08-03
categories: [AWS, AI]
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---


<style>
/* Styles for the two-column layout */
.image-text-container {
    display: flex; /* Enables flexbox */
    flex-wrap: wrap; /* Allows columns to stack on small screens */
    gap: 20px; /* Space between the image and text */
    align-items: center; /* Vertically centers content in columns */
    margin-bottom: 20px; /* Space below this section */
}

.image-column {
    flex: 1; /* Allows this column to grow */
    min-width: 250px; /* Minimum width for the image column before stacking */
    max-width: 40%; /* Maximum width for the image column to not take up too much space initially */
    box-sizing: border-box; /* Include padding/border in element's total width/height */
}

.text-column {
    flex: 2; /* Allows this column to grow more (e.g., twice as much as image-column) */
    min-width: 300px; /* Minimum width for the text column before stacking */
    box-sizing: border-box;
}

</style>

<div class="image-text-container">
    <div class="image-column">
<a target="_blank" href="/assets/images/about/S3Access_VPCEndPoint.pdf">
        <object data="/assets/images/about/S3Access_VPCEndPoint.pdf" type="application/pdf" width="200" height="150">
</object>
        Show</a>
    </div>
    <div class="text-column">
<p>This post delves into AWS S3 Access Points, highlighting how they simplify managing data access at scale by providing dedicated access policies per application. Learn how Access Points streamline S3 permissions, enhance security with granular controls, and support services like AWS PrivateLink for secure connectivity. Discover best practices for implementing and leveraging S3 Access Points for efficient and secure data lake management on AWS, crucial for modern cloud architectures.</p>
    </div>
</div>




<!--more-->

------

* TOC
{:toc}


------

## S3 Access Point

AWS Access Points are a feature for Amazon S3 that simplifies managing data access for shared datasets. 

They act as network endpoints attached to an S3 bucket, allowing you to create unique access control policies for specific applications, teams, or individuals.

Here's a breakdown of what that means and why it's useful:

- **Simplifying Access Management:** Before Access Points, if you had a large S3 bucket with data used by multiple applications or teams, you would have to manage a single, often complex, bucket policy. Every time you needed to grant or change access for a specific use case, you had to modify this one large policy. Access Points let you *decompose that single policy into separate, discrete policies, one for each access point*. This makes it much easier to manage and audit permissions.

- **Application-Specific Policies:** With Access Points, you can create a *dedicated endpoint with a tailored policy for a specific application*. For example, one application might have read-only access to a particular folder in the bucket. At the same time, another might have read/write permissions to a different part of the same bucket. You can configure each Access Point with its policy to meet those specific needs.

- **Network Controls:** Access Points allow you to restrict access to a specific Virtual Private Cloud (VPC). This is a powerful security feature that ensures all S3 storage access through that *access point happens from within your private network*, adding an extra layer of security and helping to firewall your data.

- **Cross-Account Access:** You can *create an Access Point in a different AWS account than the one that owns the S3 bucket*. This enables secure cross-account data sharing, allowing the bucket owner to delegate permission management to another trusted account.

In essence, AWS Access Points provide a more scalable and granular way to manage access to S3 buckets, especially for large, shared datasets, by moving permissions closer to the application that is using the data. An *S3 Access Point is a named network endpoint attached to an S3 bucket*. Each access point can have up to 10,000 access points per bucket, with distinct permissions and network controls. 

A VPC endpoint is a feature of Amazon Virtual Private Cloud (VPC) that allows you to privately connect your VPC to supported AWS services, as well as services hosted by other AWS customers (via AWS PrivateLink). The key benefit is that traffic between your VPC and the AWS service does not leave the Amazon network, which offers enhanced security, compliance, and performance.



## The Problem VPC Endpoints Solve

By default, instances in a <u>private subnet</u> need a route to the internet to access public AWS services like Amazon S3, typically through a *NAT Gateway* and an *Internet Gateway*. This means the **traffic leaves your private network and travels over the public internet**{:rtxt}, which can introduce <span>security risks and latency</span>{:rtxt}.

A <u>VPC endpoint</u> provides a **direct, private connection, eliminating the need for an Internet Gateway, NAT device, or VPN connection**{:gtxt}. 

## Types of VPC Endpoints

There are two main types of VPC endpoints:

1. **Interface Endpoints:**

    - **How they work:** *Interface endpoints are powered by AWS <u>PrivateLink</u>.* When you create one, it provisions an <u>Elastic Network Interface</u> (ENI) with a private IP address from your VPC's subnet. This ENI acts as a secure, private entry point for traffic to the AWS service.

    - **Supported services:** They are the most common type and support a wide range of AWS services, including 

        - **Amazon EC2**, 

        - **AWS Lambda**, 

        - **Amazon SNS**, 

        - **Amazon SQS**, 

        - and **many others**.

    - **Cost:** You are charged for interface endpoints by the hour and for the amount of data processed 

      ​    

2. **Gateway Endpoints:**

    - **How they work:** A gateway endpoint is a gateway that you specify as a target for a route in your route table. When traffic from your VPC is destined for a supported AWS service, it gets routed through this gateway endpoint instead of an internet gateway.

    - **Supported services:** This type is currently only supported for two specific AWS services: 

        - **Amazon S3** and 

        - **Amazon DynamoDB**.
    
    - **Cost:** There is no additional charge for using a gateway endpoint.6
    
      

This is a good example[^1] of accessing AWS BedRock using AWS PrivateLink via VPC access point:

![VPC Point to AWS BedRock](/assets/images/2025-08-03-AWSS3AccessPoints/vpcpoint2bedrock.png)    

You have to configure ENI for the above configuration to Lambda to communicate with the Database:

![ENI Configuration for VPC Endpoint](/assets/images/2025-08-03-AWSS3AccessPoints/ENI_Configuration_for_VPC_Endpoint.jpg)

In addition to update the Subnet to private and the security group (Enable IP4 traffic for all the Ports). Same subent and security group combination will use the same ENI.

> For each subnet, Lambda creates an ENI for unique set of security groups.

You have to configure the Lambda to communicate with ELB, otherwise, connection will fail after the 60 seconds.

### Create Interface Endpoint

You can create endpoint under the VPC -> Endpoints in the AWS console. VPC doesn't need public IP address to communicate with **AWS service** because communication is via AWS PrivateLink.

![Connect to AWS service via VPC Endpoint](/assets/images/2025-08-03-AWSS3AccessPoints/Connect_to_AWS_service_via_VPC_Endpoint.jpg)

You have to specify the private subnet which is in service provider (BedRock).

![Select the Service provider subnet](/assets/images/2025-08-03-AWSS3AccessPoints/Select_the_Service_provider_subnet.jpg)

You have to select the private subnet.

You have to specify the <u>custom resource-based endpoint policy</u>:

```json 
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": [
				"bedrock:InvokeModel"
			],
			"Resource": [
				"arn:aws:bedrock:us-east-1::foundation-model/amazon.nova-micro-v1:0"
			],
			"Effect": "Allow",
			"Principal": "*"
		}
	]
}
```

In the lambda function you can test the LLM:

```python
import boto3
import json
from datetime import datetime
import os

model_id = os.environ.get('BEDROCK_MODEL_ID')

def test_bedrock():
    model_id = os.environ.get('BEDROCK_MODEL_ID')
    prompt = "What is the LLM?"
    r = call_bedrock(model_id, prompt)
    
    return("""
    \n 
    Response:\n
    %s
    \n
    """ % (r['response'])
    )
    
def call_bedrock(model_id, prompt_data):
    
    bedrock_runtime = boto3.client("bedrock-runtime")
    body = json.dumps({
        "inferenceConfig": {"max_new_tokens": 1000},
        "messages": [{"role": "user", "content": [{"text": prompt_data}]}],
    })
    print("bedrock-input:", body)

    accept = "application/json"
    content_type = "application/json"

    response = bedrock_runtime.invoke_model(
        body=body, modelId=model_id, accept=accept, contentType=content_type
    )

    response_body = json.loads(response.get("body").read())
    response = response_body.get('output').get('message').get('content')[0].get('text')

    return {"response": response}    
```



## Key Benefits of Using VPC Endpoints

- **Enhanced Security:** All traffic to the AWS service stays within the Amazon network, reducing exposure to the public internet and potential cyber threats. This helps meet compliance requirements for many industries.

- **Improved Performance:** Bypassing the public internet often leads to lower latency and higher, more consistent bandwidth for your applications.

- **Cost Savings:** By avoiding a NAT Gateway, you can reduce or eliminate the data processing charges associated with it, especially for services like S3 with high data transfer volumes.

- **Simplified Network Architecture:** It removes the need for complex network configurations, such as managing a NAT Gateway or an Internet Gateway, for resources that only need to communicate with AWS services.

The applications running within the VPC access shared datasets by connecting to the designated S3 access points. The VPC endpoint policy enforces restrictions, allowing access only to the specific S3 access points authorised for those applications. 

![VPC Endpoint via S3 Access Point](/assets/images/2025-05-01-AWSS3AccessPoints/VPC_Endpoint_via_S3_Access_Point.png)

Additionally, the bucket policy associated with each underlying S3 bucket defines the precise permissions for data access through the corresponding access point.

1. Data access process for applications by using S3 access points, in combination with VPC endpoint policies, to control access to shared datasets in an S3 bucket. 
2. S3 access points are *unique hostnames* that can be created to enforce distinct permissions and network controls for any request made through the access points.
3. An access point that's accessible only from a specified VPC has a network origin of VPC. Amazon S3 rejects any request made to the access point that doesn't originate from that VPC. 
4. A VPC-only access point is created and associated with the S3 bucket, ensuring that it can only be accessed by resources within the specified VPC.
5. A gateway VPC endpoint with a VPC endpoint policy is created to connect the VPC with Amazon S3. This VPC endpoint policy has a statement that allows Amazon S3 access only through the access point.
6. When applications in an Amazon Elastic Compute Cloud (Amazon EC2) instance try to access datasets in Amazon S3 through the access point, a route table is used to route traffic destined for the access point to the VPC endpoint. 

An endpoint policy is a resource-based policy that you attach to a VPC endpoint to control which AWS principals can use the endpoint to access an AWS service. Example VPC endpoint policy:

```json
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AllowUseOfS3",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": "*"
        },
        {
            "Sid": "OnlyIfAccessedViaAccessPoints",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": "*",
            "Condition": {
                "ArnNotLikeIfExists": {
                    "s3:DataAccessPointArn": "ACCESS_POINT_ARN"
                }
            }
        }
    ]
}
```

A bucket policy is a resource-based policy that you can use to grant access permissions to your S3 bucket and the objects in it. Only the bucket owner can associate a policy with a bucket.

```json
{
    "Version": "2012-10-17",
    "Id": "S3BukcetPolicyVPCAccessOnly",
    "Statement": [
        {
            "Sid": "DenyIfNotFromAllowedVPC",
            "Effect": "Deny",
            "Principal": "*",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::DATA_BUCKET_NAME",
                "arn:aws:s3:::DATA_BUCKET_NAME/*"
            ],
            "Condition": {
                "StringNotEquals": {
                    "aws:SourceVpc": "VPC_ID"
                }
            }
        }
    ]
}
```

For example, to copy a file from an S3, 

```bash
aws s3 cp s3://arn:aws:s3:us-east-1:60...:accesspoint/vpconly-access-point/Policies.txt .
```

{:gtxt: .message color="green"}
{:ytxt: .message color="yellow"}
{:rtxt: .message color="red"}

[^1]: AWS Cloud Quest: Fine-Tuning an LLM on Amazon SageMaker,**Generative AI Architect**