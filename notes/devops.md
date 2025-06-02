---
layout: notes 
title: DevOps
mermaid: true
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---
# Notes on DevOps
{:.no_toc}

---

* TOC
{:toc}

---

Here the important commands and information collected while programming. 

## AWS DevOps

### Caller Identity

```bash
echo $(aws sts get-caller-identity --query='Account' --output=text)
```

Command to get the token.

### EC2
#### Dev environment Tools to install
Here the tool to install when you need EC2 instance as Dev

```yaml
      UserData: 
        Fn::Base64: |
          #!/bin/bash -xe
          echo "Update..."
          yum update -y
          echo "Installing tmux..."
          yum -y install tmux
          echo "Installing development libs..."
          yum -y install @development zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel findutils
          echo "Installing git..."
          yum -y install git
          echo "Installing jq..."
          yum -y install jq
          echo "Installing docker..."
          amazon-linux-extras install -y docker
          echo "Add ec2-user to docker..."
          usermod -a -G docker ec2-user
          
          # # curl -LS --connect-timeout 15 \
          # #   --retry 5 \
          # #   --retry-delay 5 \
          # #   --retry-max-time 60 \
          # #   "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
          # # unzip -u awscliv2.zip
          # # ./aws/install
          # # rm awscliv2.zip

          wait
          echo "Installing AWS SAM..."
          curl -LS --connect-timeout 15 \
            --retry 5 \
            --retry-delay 5 \
            --retry-max-time 60 \
            "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip" -o "aws-sam-cli-linux-x86_64.zip" 
          unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
          ./sam-installation/install
          rm aws-sam-cli-linux-x86_64.zip
          
          wait
          sudo -u ec2-user -i <<'EOF'

          echo '--- Install docker-compose for ec2-user ---' 
          echo 'export DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}' >>  ~/.bashrc
          echo 'export PATH="$DOCKER_CONFIG/cli-plugins:$PATH"' >> ~/.bashrc
          source ~/.bashrc
          
          mkdir -p $DOCKER_CONFIG/cli-plugins
          curl -LS --connect-timeout 15 \
            --retry 5 \
            --retry-delay 0 \
            --retry-max-time 60 \
            https://github.com/docker/compose/releases/download/v2.11.0/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
          chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
          

          echo '--- Install pyenv for ec2-user ---'
          source ~/.bashrc

          RETRIES=3; DELAY=10; COUNT=1; while [ $COUNT -lt $RETRIES ]; do git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv; if [ $? -eq 0 ]; then RETRIES=0;  break; fi; let COUNT=$COUNT+1; sleep $DELAY; done
          echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
          echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
          echo 'eval "$(pyenv init -)"' >> ~/.bashrc
          source ~/.bashrc

          RETRIES=3; DELAY=10; COUNT=1; while [ $COUNT -lt $RETRIES ]; do git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv; if [ $? -eq 0 ]; then RETRIES=0;  break; fi; let COUNT=$COUNT+1; sleep $DELAY; done
          echo '--- Install git-remote for ec2-user ---'
          pip3 install git-remote-codecommit

          echo "Insalling python environment for AWS Lambda development..."
          echo 'export TMPDIR="$HOME/tmp"' >>  ~/.bashrc
          source ~/.bashrc
          RETRIES=3; DELAY=10; COUNT=1; while [ $COUNT -lt $RETRIES ]; do pyenv install 3.9.14 ; if [ $? -eq 0 ]; then RETRIES=0;  break; fi; let COUNT=$COUNT+1; sleep $DELAY; done
          pyenv virtualenv 3.9.14 p39

          echo '--- end ---'          
          EOF

```


Execute AWS stepfunction:
```bash
jq -c . <input file>.json | xargs -0 aws stepfunctions start-execution --state-machine-arn <stepfunction arn>--input
```

#### EC2 Role for the vscode
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

### AWS Athena JDBC

Here the the code to connect to the athena using JDBC:

```python
from awsglue.context import GlueContext
# ...

# create Athena JDBC connection
con = (
    glueContext.read.format("jdbc")
    .option("driver", "com.simba.athena.jdbc.Driver")
    .option("AwsCredentialsProviderClass","com.simba.athena.amazonaws.auth.InstanceProfileCredentialsProvider")
    .option("url", "jdbc:awsathena://athena.ap-southeast-2.amazonaws.com:443")
    .option("S3OutputLocation","s3://{}/temp/{}".format(args['<destination bucket>'], datetime.now().strftime("%m%d%y%H%M%S")))
 )
```
Above code has been used in the Glue script.

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

### AWS EMR
command to create EMR cluster

```bash
aws emr create-cluster \
 --name "OJCluster" \
 --log-uri "s3n://<provide s3bucket prefix>-oj-temp/emr/logs/" \
 --release-label "emr-6.3.1" \
 --service-role "EMR_DefaultRole" \
 --ec2-attributes '{"InstanceProfile":"EMR_EC2_DefaultRole","EmrManagedMasterSecurityGroup":"sg-<provide Master group id for Elastic MapReduce>","EmrManagedSlaveSecurityGroup":"sg-<provide Slave group id for Elastic MapReduce>","KeyName":"oj-public-key","AdditionalMasterSecurityGroups":[],"AdditionalSlaveSecurityGroups":[],"ServiceAccessSecurityGroup":"sg-<provide Service access group id for Elastic MapReduce>","SubnetId":"subnet-<provide subnet-id>"}' \
 --applications Name=Hadoop Name=JupyterEnterpriseGateway Name=Spark Name=Ganglia Name=Zeppelin Name=Livy \
 --configurations '[{"Classification":"spark-hive-site","Properties":{"hive.metastore.client.factory.class":"com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"}}]' \
 --instance-groups '[{"InstanceCount":1,"InstanceGroupType":"MASTER","Name":"Master - 1","InstanceType":"m5.xlarge","EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"VolumeType":"gp2","SizeInGB":32},"VolumesPerInstance":2}]}},{"InstanceCount":1,"InstanceGroupType":"CORE","Name":"Core - 2","InstanceType":"m5.xlarge","EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"VolumeType":"gp2","SizeInGB":32},"VolumesPerInstance":2}]}}]' \
 --auto-scaling-role "EMR_AutoScaling_DefaultRole" \
 --scale-down-behavior "TERMINATE_AT_TASK_COMPLETION" \
 --ebs-root-volume-size "10" \
 --region "ap-southeast-2"
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
### Dynamodb

List all the tables

```bash
aws dynamodb list-tables
```

describe a table found in the above command:

```bash
aws dynamodb describe-table --table-name <table name> 
```



## HTTP

### Status Codes

- 1nn: informational
- 2nn: success
- 3nn: redirection
- 4nn: client errors
- 5nn: server errors

### 200 common

- 200 ok: everything ok
- 201 created: Returns a location header for new resources
- 202 Accepted: Server has accepted the request, but it is not yet complete.

### 400 common

- 400 Bad Request: Malformed Syntax, retry with change
- 401 Unauthorized: Authentication is required
- 403 Forbidded: Server has understood, but refuses request
- 404 Not Found: Server can't find a resource for URI
- 406 Incompatible: Incompatible Accept headers specified
- 409 Conflict: Resource conflicts with client request



## Azure DevOps

List the regions

```bash
az account list-locations --query "[].{Name: name, DisplayName: displayName}" --output table
```

Set the default region to Sydney

```bash
az configure --defaults location=australiaeast
```

In the cloudeshell created random number generator

```bash
resourceSuffix=$RANDOM
```



### Azure Docker build pipeline

Here the folder structure

```
.
├── Dockerfile
├── README.md
└── azure-pipelines.yml
```



Sample Dockerfile

```dockerfile
FROM bitnami/minideb:latest
CMD ["/bin/bash"]
```

build pipeline:

```yaml
# Docker
# Build a Docker image and save it as a tar file
# https://docs.microsoft.com/azure/devops/pipelines/languages/docker

trigger:
- master

resources:
- repo: self

variables:
  # tag: '$(Build.BuildId)'
  tag: 'latest'
  DOCKER_BUILDKIT: 1
  imageName: 'ojitha/test'
  # Create a simpler output filename without the repository path structure
  imageFileName: 'test-$(tag).tar'

stages:
- stage: Build
  displayName: Build image
  jobs:
  - job: Build
    displayName: Build
    pool:
      name: Ubuntu 
      demands: 
      - agent.name -equals ojitha
    steps:
    - task: Docker@2
      displayName: Build an image
      inputs:
        repository: $(imageName)
        command: build
        dockerfile: '$(Build.SourcesDirectory)/Dockerfile'
        tags: |
          $(tag)
    
    - script: |
        # Create the directory if it doesn't exist
        mkdir -p $(Build.ArtifactStagingDirectory)
        
        # Save the Docker image to a tar file with a simpler name
        docker save $(imageName):$(tag) -o $(Build.ArtifactStagingDirectory)/$(imageFileName)
        
        # Display saved file for verification
        ls -la $(Build.ArtifactStagingDirectory)
      displayName: 'Save Docker image to tar file'
    
    - task: PublishBuildArtifacts@1
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)'
        artifactName: 'docker-image'
      displayName: 'Publish Docker image tar file as artifact'
```

## Azure pipeline to save the docker images to pipeline artifacts

You can save the docker generated artifacts as follows:

![img000304@2x](./assets/images/devops/img000304@2x.jpg)

Here the azure-pipelines.yml:

```yaml
trigger:
 - main

pool:
   vmImage: 'ubuntu-latest' 

variables:
  # Docker image configuration
  imageName: 'myapp'
  imageTag: '$(Build.BuildNumber)'
  dockerfilePath: '$(Build.SourcesDirectory)/app/Dockerfile'
  
  # Artifact configuration
  artifactName: 'docker-images'
  dockerTarFileName: '$(imageName)-$(imageTag).tar'

stages:
- stage: BuildDockerImage
  displayName: 'Build Docker Image'
  jobs:
  - job: BuildAndSaveImage
    displayName: 'Build and Save Docker Image'
    steps:
    
    # Checkout source code
    - checkout: self
      displayName: 'Checkout source code'
    
    # Display environment info
    - script: |
        echo "Pipeline: $(Build.DefinitionName)"
        echo "Build Number: $(Build.BuildNumber)"
        echo "Source Branch: $(Build.SourceBranchName)"
        echo "Docker Image: $(imageName):$(imageTag)"
        echo "Dockerfile Path: $(dockerfilePath)"
        docker --version
        df -h
      displayName: 'Display build information'
    
    # Build Docker image
    - script: |
        echo "Building Docker image: $(imageName):$(imageTag)"
        docker build -t $(imageName):$(imageTag) -f $(dockerfilePath) .
        
        # Also tag as latest for convenience
        docker tag $(imageName):$(imageTag) $(imageName):latest
        
        # Display images
        docker images | grep $(imageName)
      displayName: 'Build Docker image'
      workingDirectory: '$(Build.SourcesDirectory)'
    
    # Optional: Test the Docker image
    - script: |
        echo "Testing Docker image..."
        # Run basic container test
        docker run --rm $(imageName):$(imageTag) --version || true
        
        # Check image size
        docker images $(imageName):$(imageTag) --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
      displayName: 'Test Docker image'
      condition: succeeded()
    
    # Save Docker image to tar file
    - script: |
        echo "Saving Docker image to tar file..."
        mkdir -p $(Agent.TempDirectory)/docker-artifacts
        
        # Save both tagged version and latest
        docker save $(imageName):$(imageTag) $(imageName):latest -o $(Agent.TempDirectory)/docker-artifacts/$(dockerTarFileName)
        
        # Display file info
        ls -lh $(Agent.TempDirectory)/docker-artifacts/
        echo "Docker image saved as: $(dockerTarFileName)"
        echo "File size: $(du -h $(Agent.TempDirectory)/docker-artifacts/$(dockerTarFileName) | cut -f1)"
      displayName: 'Save Docker image to tar file'
    
    # Create metadata file
    - script: |
        echo "Creating metadata file..."
        cat > $(Agent.TempDirectory)/docker-artifacts/image-info.txt << EOF
        Docker Image Information
        ========================
        Image Name: $(imageName)
        Image Tag: $(imageTag)
        Build Number: $(Build.BuildNumber)
        Build Date: $(date)
        Source Branch: $(Build.SourceBranchName)
        Commit ID: $(Build.SourceVersion)
        Pipeline: $(Build.DefinitionName)
        
        Tar File: $(dockerTarFileName)
        
        Import Instructions:
        ===================
        1. Download the artifact from Azure DevOps
        2. Extract the tar file
        3. Load into Docker: docker load -i $(dockerTarFileName)
        4. Verify: docker images | grep $(imageName)
        5. Run: docker run --rm $(imageName):$(imageTag)
        EOF
        
        cat $(Agent.TempDirectory)/docker-artifacts/image-info.txt
      displayName: 'Create metadata file'
    
    # Optional: Create compressed version to save space
    - script: |
        echo "Creating compressed version..."
        cd $(Agent.TempDirectory)/docker-artifacts
        
        # Compress the tar file
        gzip -c $(dockerTarFileName) > $(dockerTarFileName).gz
        
        # Display sizes
        echo "Original size: $(du -h $(dockerTarFileName) | cut -f1)"
        echo "Compressed size: $(du -h $(dockerTarFileName).gz | cut -f1)"
        
        # Keep both versions
        ls -lh
      displayName: 'Create compressed version'
      condition: succeeded()
    
    # Publish Docker image as pipeline artifact
    - task: PublishPipelineArtifact@1
      inputs:
        targetPath: '$(Agent.TempDirectory)/docker-artifacts'
        artifactName: '$(artifactName)'
        publishLocation: 'pipeline'
      displayName: 'Publish Docker image artifact'
    
    # Clean up local Docker images to save space
    - script: |
        echo "Cleaning up local Docker images..."
        docker rmi $(imageName):$(imageTag) $(imageName):latest || true
        docker system prune -f
        df -h
      displayName: 'Clean up Docker images'
      condition: always()

# Optional: Additional stage for multi-architecture builds
- stage: BuildMultiArch
  displayName: 'Build Multi-Architecture Images'
  condition: and(succeeded(), eq(variables['Build.SourceBranchName'], 'main'))
  dependsOn: []
  jobs:
  - job: BuildMultiArchImage
    displayName: 'Build Multi-Arch Docker Image'
    steps:
    - checkout: self
    
    # Set up Docker Buildx for multi-platform builds
    - script: |
        # Enable experimental features
        echo '{"experimental": true}' | sudo tee /etc/docker/daemon.json
        sudo systemctl restart docker
        
        # Set up buildx
        docker buildx create --name multiarch --use
        docker buildx inspect --bootstrap
      displayName: 'Setup Docker Buildx'
    
    # Build multi-architecture images
    - script: |
        echo "Building multi-architecture Docker images..."
        
        # Build for multiple platforms
        docker buildx build \
          --platform linux/amd64,linux/arm64 \
          --tag $(imageName):$(imageTag)-multiarch \
          --file $(dockerfilePath) \
          --output type=docker,dest=$(Agent.TempDirectory)/$(imageName)-$(imageTag)-multiarch.tar \
          .
        
        ls -lh $(Agent.TempDirectory)/$(imageName)-$(imageTag)-multiarch.tar
      displayName: 'Build multi-architecture image'
      workingDirectory: '$(Build.SourcesDirectory)'
    
    # Publish multi-arch artifact
    - task: PublishPipelineArtifact@1
      inputs:
        targetPath: '$(Agent.TempDirectory)/$(imageName)-$(imageTag)-multiarch.tar'
        artifactName: 'docker-images-multiarch'
        publishLocation: 'pipeline'
      displayName: 'Publish multi-arch Docker artifact'
```



## Maven

Configure proxy with `settings.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">

  <profiles>
    <!-- Single default profile with proxy and SSL insecure settings -->
    <profile>
      <id>corporate-proxy</id>
      <activation>
        <!-- Activate this profile by default -->
        <activeByDefault>true</activeByDefault>
      </activation>
      <properties>
        <!-- Disable SSL certificate checks for HTTP repositories -->
        <maven.wagon.http.ssl.insecure>true</maven.wagon.http.ssl.insecure>
      </properties>
      <proxies>
        <proxy>
          <id>default-proxy</id>
          <active>true</active>
          <protocol>http</protocol>
          <host>corporate-proxy.example.com</host>
          <port>8080</port>
          <username>proxyuser</username>
          <password>proxypass</password>
          <nonProxyHosts>localhost|*.internal.example.com</nonProxyHosts>
        </proxy>
      </proxies>
    </profile>
  </profiles>

</settings>
```

## Install Node on Amazon Linux 2

```dockerfile

```



