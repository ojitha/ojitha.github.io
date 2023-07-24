---
layout: post
title:  Kafka PySpark streaming example
date:   2023-07-18
categories: [Kafka, Apache Spark]
---

The diagram shows that the Kafka producer reads from Wikimedia and writes to the Kafka topic. Then Kafka Spark consumer pulls the data from the Kafka topic and writes the steam batches to disk.

![arcitecture of the streaming application](/assets/images/2023-07-18-Conducktor-configuration/arcitecture of the streaming application.png)

<!--more-->

------

* TOC
{:toc}
------



I previously explained Spark Streaming Basics[^2] and Spark Kafka Docker Configuration[^3].  

## Install


How to start Zookeeper

```bash
zookeeper-server-start.sh ~/dev/kafka_2.13-3.1.0/config/zookeeper.properties
```

Start Kafka

```bash
kafka-server-start.sh ~/dev/kafka_2.13-3.1.0/config/server.properties
```

To list the Kafka topics:

```bash
kafka-topics.sh --list --bootstrap-server 127.0.0.1:9092
```

To create a topic

```bash
kafka-topics.sh --create --bootstrap-server 127.0.0.1:9092 --topic <topic-name>
```

You can install Apache Spark 3.0.0 using SDKMAN on MacOS.

## Kafka Producer

Kafka consumer[^1] reads the clickstream from https://stream.wikimedia.org/v2/stream/recentchange and writes to the Kafka topic via port 9092.  

```java
package au.com.blogspot.ojitha.kafka.examples.wikimedia;

import com.launchdarkly.eventsource.EventHandler;
import com.launchdarkly.eventsource.EventSource;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;

import java.net.URI;
import java.util.Properties;
import java.util.concurrent.TimeUnit;


class WikimediaChangesProducer {
  public static void main(String[] args) throws InterruptedException {
      
      // create Producer Properties
      Properties properties = new Properties();
      properties.setProperty(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "127.0.0.1:9092");
      properties.setProperty(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
      properties.setProperty(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

      //set high throuput producer configs
      properties.setProperty(ProducerConfig.LINGER_MS_CONFIG, "20");
      properties.setProperty(ProducerConfig.BATCH_SIZE_CONFIG, Integer.toString(32 * 1024));
      properties.setProperty(ProducerConfig.COMPRESSION_TYPE_CONFIG, "snappy");

      // create the Producer
      KafkaProducer<String, String> producer = new KafkaProducer<>(properties);
      String topic = <topic-name>;

      EventHandler eventHandler = new WikimediaChangeHandler(producer, topic);

      String url = "https://stream.wikimedia.org/v2/stream/recentchange";
      EventSource.Builder builder = new EventSource.Builder(eventHandler, URI.create(url));
      EventSource eventSource = builder.build();


      // start the producer in another thread
      eventSource.start();

      // we produce for 10 minutes and block the program until then
      TimeUnit.MINUTES.sleep(10);
```

The gradle file:

```groovy
plugins {
    id 'java'
}

group 'au.com.blogspot.ojitha.kafka.examples'
version '1.0-SNAPSHOT'

repositories {
    mavenCentral()
}

dependencies {
    // https://mvnrepository.com/artifact/org.apache.kafka/kafka-clients
    implementation 'org.apache.kafka:kafka-clients:3.3.1'

    // https://mvnrepository.com/artifact/org.slf4j/slf4j-api
    implementation 'org.slf4j:slf4j-api:2.0.5'

    // https://mvnrepository.com/artifact/org.slf4j/slf4j-simple
    implementation 'org.slf4j:slf4j-simple:2.0.5'

    // https://mvnrepository.com/artifact/com.squareup.okhttp3/okhttp
    implementation 'com.squareup.okhttp3:okhttp:4.9.3'

    // https://mvnrepository.com/artifact/com.launchdarkly/okhttp-eventsource
    implementation 'com.launchdarkly:okhttp-eventsource:2.5.0'

}
```



## Kafka Spark Consumer

Here the simple Kafka Spark consumer reads from the Kafa topic and writes the stream to disk. This consumer is written in PySpark for simplicity.



```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("Kafka Stream Test") \
    .config ("spark.streaming.stopGracefullyOnShutdown", "true") \
    .config ("spark.sql.shuffle.partitions",3) \
    .getOrCreate()

line_df = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092")  \
    .option("subscribe", "<topic-name>") \
    .option("startingOffsets", "earliest") \
    .load()

df = line_df.selectExpr("CAST(value AS STRING)")

outDF = df.writeStream \
    .format("text") \
    .option("path","/Users/<user-name>/.../container/test/mytest.txt") \
    .outputMode("append") \
    .option("checkpointLocation", "chk-point-dir-1") \
    .start()

outDF.awaitTermination()
```

Suffle partitions were reduced to 3 in line# 5, and configured the graceful shutdown when you interrupt the process.

## Submit the Job

You need the package `org.apache.spark:spark-sql-kafka-0-10_2.12:3.0.0` to submit the job. Therefore, download the `spark-sql-kafka-0-10_2.12-3.0.0.jar`:

```bash
wget https://repo1.maven.org/maven2/org/apache/spark/spark-sql-kafka-0-10_2.12/3.0.0/spark-sql-kafka-0-10_2.12-3.0.0.jar
```

Submit the job as follows:

```bash
container>spark-submit --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.0.0 <file-name>.py
```

![Result of saved stream batches](/assets/images/2023-07-18-Conducktor-configuration/CleanShot 2023-07-24 at 12.29.11@2x.jpg)

 You can check the output as above.



[^1]: Apache Kafka Series - Learn Apache Kafka for Beginners v3, Stéphane Maarek
[^2]: [Spark Streaming Basics](https://ojitha.github.io/apache spark/2023/06/09/Spark-Streaming-part-1.html){:target="_blank"} 
[^3]: [Spark Kafka Docker Configuration](https://ojitha.github.io/kafka/apache spark/2023/06/09/Spark-Streaming-part-2.html){:target="_blank"}
