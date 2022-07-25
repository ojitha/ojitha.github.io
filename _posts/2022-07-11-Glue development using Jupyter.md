---
layout: post
title:  Glue Development using Jupyter
date:   2022-04-08
categories: [AWS, Glue, Jupyter]
---

If you want to create Glue job using vscode, you can create glue job using jupyter. In addition to that vscode support of Jupyter notebook will help to do more rapid development.

<!--more-->


## Docker based environment
First you have to Docker on Amazon Linux to as explained in the [install](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install-linux.html). 

to start the docker service
```bash
sudo service docker start
```

Create a docker instance based on the Glue 3:

```bash
docker run -it -v ~/.aws:/home/glue_user/.aws -v "$(pwd)":/home/glue_user/workspace/jupyter_workspace/ -e AWS_PROFILE=$PROFILE_NAME -e DISABLE_SSL=true --rm -p 4040:4040 -p 8888:8888 --name glue_pyspark amazon/aws-glue-libs:glue_libs_3.0.0_image_01
```
This will take you to the container bash shell.

In the container bash prompt, if you want _optionally_ install any library before use any notebook. For eample, pyathena to access AWS Athena:

```bash
pip3 install pyathena
```

It is **requred** to start the livy server. Run the following command in the container bash shell prompt:

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

Create spark datataframe from the JDBC executing SQL specified in the `query` variable:

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

Execute the coursor and get the result set:
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

NOTE:
You have to have proper IAM policies configure with your EC2 IAM Role. With the **PowerUserAccess**, you may need:

Trust releationship:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

Policy for the vscode development:

```json
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
                "arn:aws:cloudformation:*:<account-id>:stack/*"
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
                "arn:aws:ecr:*:<account-id>:repository/*"
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
                "arn:aws:lambda:*:<account-id>:function:*"
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
                "arn:aws:iam::<account-id>:role/*"
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

Policy for the Athena

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "athena:ListEngineVersions",
                "athena:ListWorkGroups",
                "athena:ListDataCatalogs",
                "athena:ListDatabases",
                "athena:GetDatabase",
                "athena:ListTableMetadata",
                "athena:GetTableMetadata"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "athenaglobal"
        },
        {
            "Action": [
                "athena:GetQueryResultsStream",
                "athena:GetWorkGroup",
                "athena:GetQueryExecution",
                "athena:CreatePreparedStatement",
                "athena:GetPreparedStatement",
                "athena:ListPreparedStatements",
                "athena:UpdatePreparedStatement",
                "athena:DeletePreparedStatement",
                "athena:StartQueryExecution",
                "athena:StopQueryExecution",
                "athena:GetQueryResults"
            ],
            "Resource": [
                "arn:aws:athena:ap-southeast-2:<account-id>:workgroup/primary"
            ],
            "Effect": "Allow",
            "Sid": "athenaWorkgroup"
        }
    ]
}
```

S3 policy

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::<account-id>-<s3-athena-data>*",
                "arn:aws:s3:::<account-id>-<s3-athena-data>*/*"
            ],
            "Effect": "Allow",
            "Sid": "S3Polices"
        },
        {
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::<account-id>-<s3-bucket>",
                "arn:aws:s3:::<account-id>-<s3-bucket>/*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::<account-id>-other",
                "arn:aws:s3:::<account-id>-other/*"
            ],
            "Effect": "Allow"
        }
    ]
}
```
