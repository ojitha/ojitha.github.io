---
layout: post
title:  Spark to consume Kafka Stream
date:   2022-03-20
categories: [Kafka, Apache Spark]
---

A simple PySpark example to show how to consume Kafka stream (given [Kafka tutorial][tut]).

<!--more-->

------

* TOC
{:toc}
------

## Run Kafka

The Kafka application creates the stream created using [Confluent Developer tutorial][tut]{:target="_blank"}. I have slightly changed the docker-compose.yaml to work using an external host instead of localhost.

```yaml
---
version: '3'
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.0.1
    hostname: zookeeper
    container_name: zookeeper
    ports:
      - '2181:2181'
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000

  broker:
    image: confluentinc/cp-kafka:7.0.1
    hostname: broker
    container_name: broker
    ports:
      - "29092:29092"
    depends_on:
      - zookeeper
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: 'zookeeper:2181'
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://broker:9092,PLAINTEXT_HOST://192.168.1.197:29092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS: 0
      KAFKA_TOOLS_LOG4J_LOGLEVEL: ERROR
```

to start Kafka 

```bash
docker-compose up -d
```

## Verify Kafka

Selling to the Kafka

```bash
docker-compose exec Kafka bash
```

Kafka shift with `Kafka-topics` script filee. You can use the `kafka-topics` script to create, list or describe topics. 

### Create topic

```bash
kafka-topics \
    --bootstrap-server localhost:9092 \
    --create \
    --topic mytopic \
    --partitions 4
```

![image-20220312175556852](/assets/images/image-20220312175556852.png)

list the topics

```bash
Kafka-topics --bootstrap-server localhost:9092 --list
```

### Producer

Use the `Kafka-console-producer` script to produce sample data.

```bash
kafka-console-producer \
    --bootstrap-server localhost:9092 \
    --topic mytopic \
    --property 'key.separator=|' \
    --property 'parse.key=true'
```

In the prompt enter the data as follows `key | {...}`:

```bash
1|{"id": 1, "name": "Mike"}
2|{"id": 2, "name": "Rand"}
```

If you want input from the file, you have to add the new property instead of the above two console data: `--property 'key.separator=|' < /path/to/data/inputs.txt`.

### Consumer

Press Ctrl+c to logout from the bootstrap-server, and verify is in Kafka using the following command:

```bash
kafka-console-consumer \
    --bootstrap-server localhost:9092 \
    --topic mytopic \
    --from-beginning \
    --property print.key=true
```

## Configuration

Under the `configuration` folder, you can find the `dev.properties` file:

```properties
application.id=kafka-streams-101
bootstrap.servers=192.168.1.197:29092

input.topic.name=random-strings
output.topic.name=tall-random-strings

key.serializer=org.apache.kafka.common.serialization.StringSerializer
value.serializer=org.apache.kafka.common.serialization.StringSerializer
```

I've modified the second line to have a remote host. After that, as explained in the Kafka tutorial, you can use the same producer:

```bash
java -jar build/libs/creating-first-apache-Kafka-streams-application-*.jar configuration/dev.properties
```

The consumer is written in spark as follows.

```python
from pyspark import SparkContext
from pyspark.sql import SparkSession
from pyspark.streaming import StreamingContext
import findspark

findspark.init()
spark = SparkSession.builder \
        .appName("Spark consume Kafka") \
            .master("local[*]") \
            .config("spark.steaming.stopGracefullyOnShutdown", "true") \
            .config("spark.jars.packages","org.apache.spark:spark-sql-kafka-0-10_2.12:3.0.0")\
                .getOrCreate()

sc = spark.sparkContext
sc.setLogLevel('ERROR') 
```

read the Kafka stream to DataFrame

```python
kafka_df = spark.readStream \
    .format("kafka") \
        .option("kafka.bootstrap.servers","192.168.1.197:29092") \
        .option("subscribe", "random-strings") \
        .option("startingOffsets", "earliest") \
            .load()
```

The DataFrame created from Kafka is always similar to this:

```python
kafka_df.printSchema()
```

```
root
 |-- key: binary (nullable = true)
 |-- value: binary (nullable = true)
 |-- topic: string (nullable = true)
 |-- partition: integer (nullable = true)
 |-- offset: long (nullable = true)
 |-- timestamp: timestamp (nullable = true)
 |-- timestampType: integer (nullable = true)
```

The binary type of the `value` needs to be converted to the string type before printing to the console.

```python
from pyspark.sql.functions import col
from pyspark.sql.types import StringType

value_df = kafka_df.select(col('value').cast("string").alias("mystring"))
```

Write the contents to the console:

```bash
writer_query = value_df.writeStream \
    .format("console") \
        .outputMode("append") \
            .option("checkpointLocation", "chk-point-dir") \
                .trigger(processingTime="10 second") \
                    .start().awaitTermination(1)

```

As shown in the above code, the output mode is `append`, and the trigger time is 10 seconds.

Reference:

[tut]: https://developer.confluent.io/tutorials/creating-first-apache-kafka-streams-application/kstreams.html "How to build your first Apache Kafka Streams application"

