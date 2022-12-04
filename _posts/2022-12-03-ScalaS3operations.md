---
layout: post
title:  Scala: S3 bucket operations
date:   2022-12-03
categories: [AWS,Scala]
---

How to list S3 bucket contents using Scala.

<!--more-->

------

* TOC
{:toc}
------

## AWS Java SDK

You have to import the AWS Java SDK version 2, S3 package as follows:

```
libraryDependencies += "software.amazon.awssdk" % "s3" % "2.18.27"
```

## List Bucket Contents


```scala
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider
import software.amazon.awssdk.services.s3.S3Client
import software.amazon.awssdk.services.s3.model.ListObjectsRequest
import software.amazon.awssdk.services.s3.model.ListObjectsResponse
import software.amazon.awssdk.services.s3.model.S3Exception
import software.amazon.awssdk.services.s3.model.S3Object

import java.util.List;
```


```scala
    val bucketName = "ojitha"
    val credentialsProvider = ProfileCredentialsProvider.create();
    val region = Region.AP_SOUTHEAST_2;
    val s3 = S3Client.builder()
            .region(region)
            .credentialsProvider(credentialsProvider)
            .build();
    val listObjects = ListObjectsRequest
                .builder()
                .bucket(bucketName)
                .build();
    val res = s3.listObjects(listObjects)
    val objects = res.contents()            
    // listBucketObjects(s3, bucketName);
    s3.close();
```


```scala
objects
```



```
    [S3Object(Key=philip toothbrush.jpeg, LastModified=2022-12-03T22:14:39Z, ETag="e9540d38a9b1f385182030162f5b5adb", Size=1773326, StorageClass=STANDARD, Owner=Owner(DisplayName=ojitha, ID=2e4dff4014bf54544a0e2d65e6712b142be4bfbce098f66b9f242df14372615e))]
```

## Upload file to S3

In the following example, the file `mytest.txt` will be created in the local file system and upload that in to the S3 bucket.

```scala
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider
import software.amazon.awssdk.services.s3.S3Client
import software.amazon.awssdk.services.s3.model.ListObjectsRequest
import software.amazon.awssdk.services.s3.model.ListObjectsResponse
import software.amazon.awssdk.services.s3.model.S3Exception
import software.amazon.awssdk.services.s3.model.S3Object

import software.amazon.awssdk.services.s3.model.PutObjectRequest
import software.amazon.awssdk.core.sync.RequestBody

import java.io.PrintWriter
import java.nio.file.{Files, Paths}
import java.io.File

import java.util.HashMap
import java.util.Map
```

Create S3 client

```scala
val bucketName = "ojitha"
val objectKey = "mytest.txt"
val credentialsProvider = ProfileCredentialsProvider.create()
val region = Region.AP_SOUTHEAST_2

// create S3 client
val s3 = S3Client.builder()
        .region(region)
        .credentialsProvider(credentialsProvider)
        .build();
```

As shown in the first line, the target bucket is `ojitha` and the file to upload is `mytest.txt`.

First will create `mytest.txt` file locally:

```scala
// PrintWriter
val pw = new PrintWriter(new File(objectKey))
pw.write("Hello, Ojitha\n")
pw.write("How are you?\n")
pw.close
```

File as a byte array:

```scala
val byteArray = Files.readAllBytes(Paths.get(objectKey))
```

Above byte array you can upload to the S3 bucket:

```scala
val metadata = new HashMap[String, String]()
metadata.put("x-amz-meta-myVal", "test")
val putOb = PutObjectRequest.builder()
    .bucket(bucketName)
    .key(objectKey)
    .metadata(metadata)
    .build()

val response = s3.putObject(putOb, RequestBody.fromBytes(byteArray));
```

Now you can close the S3 client

```scala
s3.close()
```

