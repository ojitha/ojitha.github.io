---
layout: post
title:  Spark Streaming Basics 
date:   2023-06-09
categories: [Apache Spark]
---



This is a very basic example created to explain Spark streaming. Spark run on the AWS Glue container locally.

<!--more-->

There is plenty of information on Spark streaming. My objective is to provide a running example with a very simple approach.

As a first step, create the following docker-compose.yml

```yaml
version: '3.3'
services:
  aws_glue:
    container_name: notebook
    build: .
    volumes:
      - .:/home/glue_user/workspace/jupyter_workspace
    privileged: true
    # network_mode : host
    ports:
      - 8888:8888
      - 4040:4040
    environment:
      JUPYTER_ENABLE_LAB: "yes"
      DISABLE_SSL: "true"

networks: 
  default: 
    external: 
      name: ojnw-1
```

To generate text, I use the Netcat application, which is well-known in Unix. As shown in line #9, if you uncomment the line, you should have Netcat in your local machine and comment the lines 17 to 20.

To install Netcat in the Docker container:



```bash
docker exec -it --user root notebook bash
# run the following to install Netcat
yum install netcat
```

Now login as the Glue user:

```bash
docker exec -it notebook bash
# start the Netcat
nc -lk 9999
```

Create a Scala Jupyter notebook in the Glue container.

First, create the Spark session in the notebook:

```scala
import org.apache.spark.sql.SparkSession

val spark = SparkSession.builder().
    master("local[3]").
    appName("Kafka Test").
    config ("spark.streaming.stopGracefullyOnShutdown", "true").
    config ("spark.sql.shuffle.partitions",3).
    getOrCreate()
```

Create the stream block:

```scala
import org.apache.spark.sql.functions._
val lineDF = spark.readStream.
    format("socket").
    option("host", "localhost").
    option("port", "9999").
    load()

val outDF = lineDF.
    writeStream.
    format("text").
    option("path","/home/glue_user/workspace/jupyter_workspace/test/mytest.txt").
    outputMode("append").
    option("checkpointLocation", "chk-point-dir").
    queryName("out_query").
    start()

outDF.awaitTermination()
```

When you type the text into the Netcat, the text will be saved in the file in the folder given in line #11.

![Save the stream to text file](/assets/images/2023-06-09-Spark-Streaming-part-1/save_stream2file.jpg)

You have to interrupt the notebook to stop forcefully.