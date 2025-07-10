---
layout: post
title:  Scala - AWS EMR Serverless
date:   2022-12-03
categories: [AWS, Scala]
---

AWS EMR Serverless is a cost effective AWS Service to which you can submit Spark Scala jobs.

<!--more-->

------

* TOC
{:toc}
------

## Scala Job

The buid.sbt:

```scala
name := "Deequ-Project"

version := "1.0"

scalaVersion := "2.12.10"



libraryDependencies ++= Seq(
    ("org.apache.spark" %% "spark-sql" % "3.2.0" % "provided")
)    

libraryDependencies ++= Seq(
  ("com.amazon.deequ" % "deequ" % "2.0.1-spark-3.2").
    exclude("commons-logging", "commons-logging").
    exclude("org.apache.spark", "spark-kvstore_2.12").
    exclude("org.apache.spark", "spark-core_2.12").
    exclude("org.apache.spark", "spark-launcher_2.12").
    exclude("org.apache.spark", "spark-network-common_2.12").
    exclude("org.apache.spark", "spark-sql_2.12").
    exclude("org.spark-project.spark", "unused").
    exclude("org.apache.spark", "spark-unsafe_2.12")

)
libraryDependencies += "software.amazon.awssdk" % "s3" % "2.18.27"
libraryDependencies += "software.amazon.awssdk" % "aws-crt-client" % "2.18.28-PREVIEW"

excludeDependencies ++= Seq(
  ExclusionRule("software.amazon.awssdk", "netty-nio-client"),

)
```

In this scala file you are using Deequ to find the suggestions for the data set.

```scala
package com.github.ojitha.emr

import org.apache.spark.sql.SparkSession
import com.amazon.deequ.suggestions.{ConstraintSuggestionRunner, Rules}

import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider
import software.amazon.awssdk.services.s3.S3Client
import software.amazon.awssdk.services.s3.model.ListObjectsRequest
import software.amazon.awssdk.services.s3.model.ListObjectsResponse
import software.amazon.awssdk.services.s3.model.S3Exception
import software.amazon.awssdk.services.s3.model.S3Object

import software.amazon.awssdk.http.SdkHttpClient
import software.amazon.awssdk.http.apache.ApacheHttpClient

import software.amazon.awssdk.services.s3.model.PutObjectRequest
import software.amazon.awssdk.core.sync.RequestBody

import java.io.PrintWriter
import java.nio.file.{Files, Paths}
import java.io.File

import java.util.HashMap
import java.util.Map
import java.time.Duration

object DeequJob {
  def main(args: Array[String]) {

    val spark = SparkSession.builder.appName("EMR Serverless Application").getOrCreate()
    
    // create S3 client
    val region = Region.AP_SOUTHEAST_2
    val apacheHttpClient = ApacheHttpClient.builder()
                    .maxConnections(100)
                    .tcpKeepAlive(true)
                    .build()

    val s3 = S3Client.builder()
            .region(region)
            .httpClient(apacheHttpClient)
            .build();

    val df = spark.read.load("s3a://<source data location in the s3 bucket>/")
    val suggestionResult = ConstraintSuggestionRunner().onData(df).addConstraintRules(Rules.DEFAULT).run()

    // PrintWriter create local file
    val local_file="local.txt"
    val pw = new PrintWriter(new File(local_file)) // open the local file
    suggestionResult.constraintSuggestions.foreach { case (column, suggestions) =>
      suggestions.foreach { suggestion =>
        pw.write(s"Constraint suggestion for '$column':\t${suggestion.description}\n" +
          s"The corresponding scala code is ${suggestion.codeForConstraint}\n")
      }
    }
    pw.close // close the local file


    // load local file to byte array
    val byteArray = Files.readAllBytes(Paths.get(local_file))

    // upload to S3
    val metadata = new HashMap[String, String]()
    metadata.put("x-amz-meta-val", "suggestions")
    val putOb = PutObjectRequest.builder()
        .bucket("<output bucket location in S3>")
        .key("output.txt")
        .metadata(metadata)
        .build()
    val response = s3.putObject(putOb, RequestBody.fromBytes(byteArray));
    s3.close() // close S3 client

    // stop spark
    spark.stop()
  }
}
```

You have to create the assembly using the following command

```bash
sbt clean assembly
```

After that you have to copy this to S3 bucket to be accessed by the EMR Serverless application

```bash
aws s3 cp ./target/scala-2.12/Deequ-Project-assembly-1.0.jar s3://<S3-scala-job-bucket>/emr/jobs/spark/
```

Now your job is ready to submit!

## Create EMR serverless trust role

```bash
aws iam create-role --role-name EMRServerlessS3RuntimeRole --assume-role-policy-document file://emr-serverless-trust-policy.json
```
The policy is 

```json
{
    "Version": "2012-10-17",
    "Statement": [{
        "Sid": "EMRServerlessTrustPolicy",
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
            "Service": "emr-serverless.amazonaws.com"
        }
    }]
}
```

Next you have to create EMR serverless application and submit the job.

## EMR Serverless Application
I've created Boto3 based Python 3 script to create EMR serverless application. Above Scala job can be submitted to this EMR Serverless application.

AWS Client for EMR Serverless service

```python
import boto3
client = boto3.client("emr-serverless")
```

Create EMR Serverless application

```python
response = client.create_application(
    name="table-analysis", releaseLabel="emr-6.6.0", type="SPARK"
)

print(
    "Created application {name} with application id {applicationId}. Arn: {arn}".format_map(
        response
    )
)
app_id="{applicationId}".format_map(response)
```

Start the EMR Serverless application:

```python
client.start_application(applicationId=app_id)
```

Submit the job

```python
# Note that application must be in `STARTED` state.
response = client.start_job_run(
    applicationId=app_id,
    executionRoleArn="< arn of the EMRServerlessS3RuntimeRole role>",
    jobDriver={
        "sparkSubmit": {
            "entryPoint": "s3://<S3-scala-job-bucket>/emr/jobs/spark/Deequ-Project-assembly-1.0.jar",
            "entryPointArguments": [],
            "sparkSubmitParameters": "--class com.github.ojitha.emr.DeequJob --conf spark.executor.cores=1 --conf spark.executor.memory=4g --conf spark.driver.cores=1 --conf spark.driver.memory=4g --conf spark.executor.instances=1",
        }
    }
    , configurationOverrides={
        "monitoringConfiguration": {
            "s3MonitoringConfiguration": {"logUri": "s3://<S3 bucket for log data>/test/logs"}
        }
    },
)
job_id="{jobRunId}".format_map(response)
```

You can submitt any number of jobs to the same application had been created.

You can check the status of the current job

```python
# Get the status of the job
client.get_job_run(applicationId=app_id, jobRunId=job_id)
```

Stop the application

```python
# stop
client.stop_application(applicationId=app_id)
```

Delete the application

```python
client.delete_application(applicationId=app_id)
```

when you delete the application, it will delete all the jobs created for that application.

