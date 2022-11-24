---
layout: post
title:  AWS CI/CD pipeline to Copy files to S3 bucket
date:   2022-11-19
categories: [AWS]
---

Sometime it is necessary to copy files to AWS S3 via CI/CD build pipelines. 

<!--more-->

------

* TOC
{:toc}
------


## Why do CI/CD copy files?
In my experience, use cases where files need to be copied to S3 are:

- Extra python files for Glue jobs
- Copy DAGs to the S3 location where AWS MWAA can pick up

In both the above occations, when the code is committed to the AWS CodeCommit, the build pipeline will pick that delta code changes in the Git to commit and deploy ( in this case, copy python files to the S3 bucket folder). In other words, once the source commits to the CodeCommit will trigger CICD build pipeline each and every time.

## Example Stack

Here is a minimalist example to Create CI/CD pipeline via AWS Cloudformation.

```yaml
Parameters:
  BranchName:
    Description: CodeCommit branch name
    Type: String
    Default: main
  RepositoryName:
    Description: CodeComit repository name
    Type: String
    Default: <Codecommit repository to be filled>
  BucketName:
    Description: Name of the existing Artifact store S3 bucket creation
    Type: String
    Default: <bucket name to be filled>

Resources:
  AmazonCloudWatchEventRole:
    Type: 'AWS::IAM::Role'
    Properties:
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Principal:
              Service:
                - events.amazonaws.com
            Action: 'sts:AssumeRole'
      Path: /
      Policies:
        - PolicyName: cwe-pipeline-execution
          PolicyDocument:
            Version: 2012-10-17
            Statement:
              - Effect: Allow
                Action: 'codepipeline:StartPipelineExecution'
                Resource: !Join 
                  - ''
                  - - 'arn:aws:codepipeline:'
                    - !Ref 'AWS::Region'
                    - ':'
                    - !Ref 'AWS::AccountId'
                    - ':'
                    - !Ref AppPipeline
  AmazonCloudWatchEventRule:
    Type: 'AWS::Events::Rule'
    Properties:
      EventPattern:
        source:
          - aws.codecommit
        detail-type:
          - CodeCommit Repository State Change
        resources:
          - !Join 
            - ''
            - - 'arn:aws:codecommit:'
              - !Ref 'AWS::Region'
              - ':'
              - !Ref 'AWS::AccountId'
              - ':'
              - !Ref RepositoryName
        detail:
          event:
            - referenceCreated
            - referenceUpdated
          referenceType:
            - branch
          referenceName:
            - master
      Targets:
        - Arn: !Join 
            - ''
            - - 'arn:aws:codepipeline:'
              - !Ref 'AWS::Region'
              - ':'
              - !Ref 'AWS::AccountId'
              - ':'
              - !Ref AppPipeline
          RoleArn: !GetAtt 
            - AmazonCloudWatchEventRole
            - Arn
          Id: codepipeline-AppPipeline
  AppPipeline:
    Type: 'AWS::CodePipeline::Pipeline'
    Properties:
      Name: !Sub "${RepositoryName}-deployment-cicd"
      RoleArn: !GetAtt 
        - CodePipelineServiceRole
        - Arn
      Stages:
        - Name: Source
          Actions:
            - Name: SourceAction
              ActionTypeId:
                Category: Source
                Owner: AWS
                Provider: CodeCommit
                Version: 1
              OutputArtifacts:
                - Name: SourceCode
              Configuration:
                RepositoryName: !Ref 'RepositoryName'
                BranchName: !Ref 'BranchName'
                PollForSourceChanges: true
              RunOrder: 1
        - Name: Publish
          Actions:
            - Name: Test_and_Build
              ActionTypeId:
                Category: Build
                Owner: AWS
                Provider: CodeBuild
                Version: '1'
              InputArtifacts:
                - Name: SourceCode
              OutputArtifacts:
                - Name: BuiltCode
              Configuration:
                ProjectName: !Sub '${RepositoryName}-${BranchName}-publish'
              RunOrder: 1           
      ArtifactStore:
        Type: S3
        Location: !Ref BucketName
  CodePipelineServiceRole:
    Type: 'AWS::IAM::Role'
    Properties:
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Principal:
              Service:
                - codepipeline.amazonaws.com
            Action: 'sts:AssumeRole'
      Path: /
      Policies:
        - PolicyName: AWS-CodePipeline-Service-3
          PolicyDocument:
            Version: 2012-10-17
            Statement:
              - Effect: Allow
                Action:
                  - 'codecommit:CancelUploadArchive'
                  - 'codecommit:GetBranch'
                  - 'codecommit:GetCommit'
                  - 'codecommit:GetUploadArchiveStatus'
                  - 'codecommit:UploadArchive'
                Resource: '*'
              - Effect: Allow
                Action:
                  - 'codedeploy:CreateDeployment'
                  - 'codedeploy:GetApplicationRevision'
                  - 'codedeploy:GetDeployment'
                  - 'codedeploy:GetDeploymentConfig'
                  - 'codedeploy:RegisterApplicationRevision'
                Resource: '*'
              - Effect: Allow
                Action:
                  - 'codebuild:BatchGetBuilds'
                  - 'codebuild:StartBuild'
                Resource: '*'
              - Effect: Allow
                Action:
                  - 'devicefarm:ListProjects'
                  - 'devicefarm:ListDevicePools'
                  - 'devicefarm:GetRun'
                  - 'devicefarm:GetUpload'
                  - 'devicefarm:CreateUpload'
                  - 'devicefarm:ScheduleRun'
                Resource: '*'
              - Effect: Allow
                Action:
                  - 'lambda:InvokeFunction'
                  - 'lambda:ListFunctions'
                Resource: '*'
              - Effect: Allow
                Action:
                  - 'iam:PassRole'
                Resource: '*'
              - Effect: Allow
                Action:
                  - 'elasticbeanstalk:*'
                  - 'ec2:*'
                  - 'elasticloadbalancing:*'
                  - 'autoscaling:*'
                  - 'cloudwatch:*'
                  - 's3:*'
                  - 'sns:*'
                  - 'cloudformation:*'
                  - 'rds:*'
                  - 'sqs:*'
                  - 'ecs:*'
                Resource: '*'
  PublishBuild:
    Type: AWS::CodeBuild::Project
    Properties:
      Artifacts:
        Type: CODEPIPELINE
      BadgeEnabled: false
      Environment:
        ComputeType: BUILD_GENERAL1_SMALL
        Image: aws/codebuild/standard:5.0
        ImagePullCredentialsType: CODEBUILD
        PrivilegedMode: false
        Type: LINUX_CONTAINER
      Name: !Sub '${RepositoryName}-${BranchName}-publish'
      ServiceRole: !GetAtt 'CodeBuildRole.Arn'
      Source:
        BuildSpec: !Sub |
          version: 0.2
          env:
            shell: bash
            variables:
              BUCKET_NAME: "${BucketName}"
          phases:
            build:
              commands:
                - echo "copy python files to $BUCKET_NAME"
                - ls -al
                - aws s3 cp . s3://${BucketName}/python/  --recursive --exclude "*" --include "*.py"
        Type: CODEPIPELINE
      TimeoutInMinutes: 15
  CodeBuildRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          Effect: Allow
          Principal:
            Service: codebuild.amazonaws.com
          Action: sts:AssumeRole
      Policies:
        - PolicyName: AWS-CodeBuild-Service-Policy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - s3:GetObject
                  - s3:PutObject
                  - s3:GetObjectVersion
                  - s3:GetBucketAcl
                  - s3:GetBucketLocation
                Resource:
                  - !Sub 'arn:${AWS::Partition}:s3:::${BucketName}'
                  - !Sub 'arn:${AWS::Partition}:s3:::${BucketName}/*'
              - Effect: Allow
                Action:
                  - logs:CreateLogGroup
                  - logs:CreateLogStream
                  - logs:PutLogEvents
                Resource:
                  - !Sub 'arn:${AWS::Partition}:logs:${AWS::Region}:${AWS::AccountId}:log-group:/aws/codebuild/${RepositoryName}-${BranchName}-*'      
```
