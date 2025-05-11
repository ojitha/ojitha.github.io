---
layout: post
title:  Tika Tesseract OCR in Spark cluster
date:   2025-02-03
categories: [ELK]
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

This post explains how to extract text from binary files of large data sets. Spark is the best solution to handle a large dataset. Apache Tika plays the role of getting text from searchable PDF files. However, you have to have a Tesseract to do the OCR. The output will be written into the Elasticsearch.

<!--more-->

------

* TOC
{:toc}
------

## Install Elasticsearch

To run Elasticsearch 8, create a cert (CRT) file. In this blog, I want to avoid that requirement completely to simplify my development workflow. Here the docker-compose.yaml:



```yaml
version: '3'

volumes:
 esdata01:
   driver: local
 esdata02:
   driver: local
 kibanadata:
   driver: local

services:
  es01:
    # container_name: es01
    image: docker.elastic.co/elasticsearch/elasticsearch:${STACK_VERSION}
    environment: 
      # - ES_JAVA_OPTS=-Xms2g -Xmx2g
      - node.name=es01
      - cluster.name=${CLUSTER_NAME}
      # 
      - cluster.initial_master_nodes=es01,es02
      - discovery.seed_hosts=es02
      # - discovery.type=single-node
      # 
      - bootstrap.memory_lock=true
      
      - xpack.security.enabled=false
      - xpack.security.enrollment.enabled=false
      - xpack.license.self_generated.type=${LICENSE}
      - xpack.ml.max_machine_memory_percent=50
    mem_limit: ${ES_MEM_LIMIT}  
    labels:
      co.elastic.logs/module: elasticsearch
    volumes:
      - esdata01:/usr/share/elasticsearch/data
    ports:
      - ${ES_PORT}:9200
    ulimits:
      memlock:
        soft: -1
        hard: -1
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "curl -s http://localhost:9200",
        ]        
      interval: 10s
      timeout: 10s
      retries: 120
  es02:
    depends_on:
      es01:
        condition: service_healthy
    # container_name: es01
    image: docker.elastic.co/elasticsearch/elasticsearch:${STACK_VERSION}
    environment: 
      # - ES_JAVA_OPTS=-Xms2g -Xmx2g
      - node.name=es02
      - cluster.name=${CLUSTER_NAME}
      # 
      - cluster.initial_master_nodes=es01,es02
      - discovery.seed_hosts=es01
      # - discovery.type=single-node
      # 
      - bootstrap.memory_lock=true
      
      - xpack.security.enabled=false
      - xpack.security.enrollment.enabled=false
      - xpack.license.self_generated.type=${LICENSE}
      - xpack.ml.max_machine_memory_percent=50
    mem_limit: ${ES_MEM_LIMIT}  
    labels:
      co.elastic.logs/module: elasticsearch
    volumes:
      - esdata02:/usr/share/elasticsearch/data
    # ports:
    #   - ${ES_PORT}:9200
    ulimits:
      memlock:
        soft: -1
        hard: -1
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "curl -s http://localhost:9200",
        ]        
      interval: 10s
      timeout: 10s
      retries: 120

  kibana:
    depends_on:
     es01:
       condition: service_healthy
     es02:
       condition: service_healthy
    image: docker.elastic.co/kibana/kibana:${STACK_VERSION}
    labels:
     co.elastic.logs/module: kibana
    volumes:
      - kibanadata:/usr/share/kibana/data     
    environment:
      - SERVERNAME=kibana
      - ELASTICSEARCH_HOSTS=http://es01:9200
      # - ELASTICSEARCH_USERNAME=kibana_system
      # - ELASTICSEARCH_PASSWORD=${KIBANA_PASSWORD}
      - XPACK_SECURITY_ENCRYPTIONKEY=${ENCRYPTION_KEY}
      - XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=${ENCRYPTION_KEY}
      - XPACK_REPORTING_ENCRYPTIONKEY=${ENCRYPTION_KEY}
    mem_limit: ${KB_MEM_LIMIT}
    ports:
      - ${KIBANA_PORT}:5601


networks:
 default:
   name: elastic
   external: false
```



The file .env[^1] is for the environment variables to substitute in the above Elasticsearch two-instance cluster.

> This Elasticsearch cluster is running in the `elastic` network, which will also be used to run the next section of the Spark cluster.



```
# Project namespace (defaults to the current folder name if not set)
#COMPOSE_PROJECT_NAME=myproject


# Password for the 'elastic' user (at least 6 characters)
ELASTIC_PASSWORD=changeme


# Password for the 'kibana_system' user (at least 6 characters)
KIBANA_PASSWORD=changeme


# Version of Elastic products
STACK_VERSION=8.7.1


# Set the cluster name
CLUSTER_NAME=docker-cluster


# Set to 'basic' or 'trial' to automatically start the 30-day trial
# POST /_license/start_trial?acknowledge=true
LICENSE=basic
# LICENSE=trial


# Port to expose Elasticsearch HTTP API to the host
ES_PORT=9200


# Port to expose Kibana to the host
KIBANA_PORT=5601


# Increase or decrease based on the available host memory (in bytes)
ES_MEM_LIMIT= 2147483648 #3221225472 #2GB - 
KB_MEM_LIMIT=1073741824
LS_MEM_LIMIT=1073741824


# SAMPLE Predefined Key only to be used in POC environments
ENCRYPTION_KEY=c34d38b3a14956121ff2170e5030b471551370178f43e5626eec58b04a30fae2
```

Before run the docker compose up, it is important to fix the vm map maximum value as follows:

```bash
docker run -it --rm --privileged --pid=host justincormack/nsenter1
```

In the above containers, bash prompt:

```
sysctl -w vm.max_map_count=262144
exit # from the container
```

Now run the docker compose

```bash
docker compose up -d
```



## Install Spark

I am using an AWS Glue container to run Spark 3.x.

Here is the docker-compose.yaml file:

```bash
version: '3.9'
services:
  aws_glue:
    build: .
    volumes:
      - .:/home/glue_user/workspace/jupyter_workspace
      - ./scala/hello-livy/target:/home/glue_user/workspace/jars
    privileged: true
    ports:
      - 8888:8888
      - 4040:4040
      - 8998:8998
      
networks:
 default:
   name: elastic
   external: false
```

In the above code, the folder `./scala/hello-livy/target` has been mapped to the `home/glue_user/workspace/jars` container folder because this will enable the submission of the spark job after compiling in the host machine. To access the Livy, use port 8998. Companion Dockerfile:



```dockerfile
FROM amazon/aws-glue-libs:glue_libs_4.0.0_image_01 as base
USER root
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y update
RUN yum -y install tesseract
RUN echo -e "\n# === Ojitha added file locations ===" >> /etc/livy/conf/livy.conf
RUN echo "livy.file.local-dir-whitelist = /home/glue_user/.livy-sessions,/home/glue_user/workspace/jars" >> /etc/livy/conf/livy.conf
RUN echo -e "\n# === END of file locations ===" >> /etc/livy/conf/livy.conf
# RUN yum -y install tesseract-lang

FROM base as runtime
USER glue_user
COPY pom.xml .
RUN wget https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.zip
RUN unzip apache-maven-3.9.5-bin.zip
RUN apache-maven-3.9.5/bin/mvn dependency:copy-dependencies
RUN cp target/dependency/*.* ~/spark/jars/
RUN rm -rf apache-maven-3.9.5-bin.zip
RUN rm -rf apache-maven-3.9.5
RUN rm -rf target
WORKDIR /home/glue_user/workspace/jupyter_workspace
ENV DISABLE_SSL=true
CMD [ "./start.sh" ]
```
In the above Dockerfile:

1. The Tesseract binary must be installed in the Apache Spark container in the above code (if it is a cluster, it must install all the workers). 
1. add the required whitelisted folders to the Livy.conf file.
1. As a Glue user, you download Maven and copy all the necessary pom.xml dependencies to the spark/jars folder; otherwise, you must create jar files with dependencies.

Dependencis are in the pom.xm:

```xml
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.mycompany.app</groupId>
  <artifactId>my-app</artifactId>
  <version>1</version>
  <dependencies>
  <dependency>
      <groupId>org.apache.tika</groupId>
      <artifactId>tika-core</artifactId>
      <!-- <version>2.9.1</version> -->
  </dependency>   
  
  <dependency>
      <groupId>org.apache.tika</groupId>
      <artifactId>tika-parser-microsoft-module</artifactId>
      <!-- <version>2.9.1</version> -->
  </dependency>
  
  <dependency>
      <groupId>org.apache.tika</groupId>
      <artifactId>tika-parser-pdf-module</artifactId>
      <!-- <version>2.9.1</version> -->
  </dependency>

  <dependency>
      <groupId>org.apache.tika</groupId>
      <artifactId>tika-parser-image-module</artifactId>
      <!-- <version>2.9.1</version> -->
  </dependency>

  <!-- https://mvnrepository.com/artifact/org.apache.tika/tika-parser-ocr-module -->
  <dependency>
    <groupId>org.apache.tika</groupId>
    <artifactId>tika-parser-ocr-module</artifactId>
    <!-- <version>2.9.1</version> -->
  </dependency>

  <!-- https://mvnrepository.com/artifact/com.github.jai-imageio/jai-imageio-core -->
  <dependency>
    <groupId>com.github.jai-imageio</groupId>
    <artifactId>jai-imageio-core</artifactId>
    <version>1.3.0</version>
  </dependency>

  <!-- https://mvnrepository.com/artifact/com.github.jai-imageio/jai-imageio-jpeg2000 -->
  <dependency>
    <groupId>com.github.jai-imageio</groupId>
    <artifactId>jai-imageio-jpeg2000</artifactId>
    <version>1.4.0</version>
  </dependency>

  
<!-- https://mvnrepository.com/artifact/org.elasticsearch/elasticsearch-spark-30 -->
<dependency>
  <groupId>org.elasticsearch</groupId>
  <artifactId>elasticsearch-spark-30_2.12</artifactId>
  <version>8.7.1</version>
</dependency>
<!-- <dependency>
  <groupId>org.elasticsearch</groupId>
  <artifactId>elasticsearch-hadoop</artifactId>
  <version>8.7.1</version>
</dependency> -->


</dependencies>
<dependencyManagement>
    <dependencies>
      <dependency>
       <groupId>org.apache.tika</groupId>
       <artifactId>tika-bom</artifactId>
       <version>2.9.1</version>
       <type>pom</type>
       <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
</project>

```



## Spark Job

This job will read a set of binary files to the Spark data frame and extract the data using the User Define Function (UDF).

```scala
package io.github.ojitha.livy

import org.apache.spark.sql.SparkSession
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.sql.SQLContext    
import org.apache.spark.sql.SQLContext._

import org.elasticsearch.spark.sql._      

import org.elasticsearch.spark._


object ExtractJob {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder()
      // .config("es.nodes", "es01")
      // .config("es.port", "9200")
      // .config("es.nodes.wan.only", "true")
      .appName("Parser Docs to ES")
      .getOrCreate()

    import spark.implicits._
    val df = spark.read.format("binaryFile").load("/home/glue_user/workspace/jupyter_workspace/data/*")
    df.printSchema()
    df.show()

    import org.apache.spark.sql.functions.udf
    val findMimeTypeUDF = udf((x:Array[Byte]) => TikaUDF.findMimeType(x))
    val extractTextUDF = udf((x: String, y:Array[Byte]) => TikaUDF.extractText(x, y))

    val test_df = df.withColumn("doctype",findMimeTypeUDF($"content"))
    test_df.show()
    test_df.printSchema()

    val text_df = test_df.withColumn("extract",extractTextUDF($"doctype",$"content")).
        select($"path",$"modificationTime",$"length",$"doctype",$"extract"(0).as("doc_metadata"),$"extract"(1).as("text_contents"))
    text_df.show()
    text_df.printSchema()

    text_df.saveToEs("binarydocs")


    spark.stop()
  }
}
```

Here the UDF:

```scala
package io.github.ojitha.livy

import java.io.ByteArrayInputStream
import org.apache.tika.Tika
import org.apache.tika.parser.microsoft.ooxml.OOXMLParser
import org.apache.tika.parser.pdf.PDFParser
import org.apache.tika.parser.AutoDetectParser
import org.apache.tika.sax.BodyContentHandler
import org.apache.tika.metadata.Metadata
import org.apache.tika.parser.ParseContext

object TikaUDF {
    val tika = new Tika()
    val msofficeparser = new OOXMLParser()
    val pdfparser = new PDFParser()



    def findMimeType(doc: Array[Byte]) : String = {
        return tika.detect(doc)
    }
    def extractText(mimeType: String,doc: Array[Byte] ): Array[String] = {
        val handler = new BodyContentHandler(-1);
        val metadata = new Metadata();
        val context = new ParseContext();

        val docInByte = new ByteArrayInputStream(doc)
        if (mimeType.equals("application/vnd.openxmlformats-officedocument.wordprocessingml.document") ||
            mimeType.equals("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")){
            msofficeparser.parse(docInByte, handler, metadata, context)
            return Array(metadata.toString(), handler.toString()) 
        } else if (mimeType.equals("application/pdf")){
            pdfparser.parse(new ByteArrayInputStream(doc), handler, metadata, context);
            return return Array(metadata.toString(), handler.toString()) 
        } else return Array("metadata not found", "extract not found")
    }
}

```



To run:

```bash
curl -i --location --request POST http://localhost:8998/batches/ \
--header 'Content-Type: application/json' \
--data-raw \
'{ 
    "file": "/home/glue_user/workspace/jars/scala-2.12/hello-livy_2.12-1.0.jar",
    "className":"io.github.ojitha.livy.ExtractJob",
    "conf": {"spark.es.nodes": "es01", "spark.es.port": "9200", "spark.es.nodes.wan.only": "true"},
    "driverMemory": "1G",
    "driverCores": 1,
    "executorCores": 1,
    "executorMemory": "1G",
    "numExecutors": 1,
    "queue": "default"
}'
```



the build.sbt file:

```properties
// The simplest possible sbt build file is just one line:
scalaVersion := "2.12.17"

name := "hello-livy"
organization := "io.github.ojitha.livy"
version := "1.0"
	
libraryDependencies += "org.scala-lang.modules" %% "scala-parser-combinators" % "2.1.1" % "provided" withJavadoc()
libraryDependencies ++= Seq(
    ("org.apache.spark" %% "spark-sql" % "3.3.0" % "provided" withJavadoc())
)  
libraryDependencies += "org.apache.spark" %% "spark-core" % "3.3.0"
libraryDependencies += "ch.qos.logback" % "logback-classic" % "1.2.3"  
libraryDependencies += "ch.qos.logback" % "logback-core" % "1.+" 
// https://mvnrepository.com/artifact/org.apache.livy/livy-client-http
libraryDependencies += "org.apache.livy" % "livy-client-http" % "0.8.0-incubating"
libraryDependencies += "org.apache.livy" %% "livy-scala-api" % "0.8.0-incubating"
libraryDependencies += "org.elasticsearch" %% "elasticsearch-spark-30" % "8.7.1" % "provided"

// https://mvnrepository.com/artifact/org.apache.tika/tika-core
libraryDependencies += "org.apache.tika" % "tika-core" % "2.9.1"
// https://mvnrepository.com/artifact/org.apache.tika/tika-parser-pdf-module
libraryDependencies += "org.apache.tika" % "tika-parser-pdf-module" % "2.9.1"
// https://mvnrepository.com/artifact/org.apache.tika/tika-parser-microsoft-module
libraryDependencies += "org.apache.tika" % "tika-parser-microsoft-module" % "2.9.1"
// https://mvnrepository.com/artifact/org.apache.tika/tika-parser-image-module
libraryDependencies += "org.apache.tika" % "tika-parser-image-module" % "2.9.1"
```

Lest us do the testing using Jupyter notebooks

import tika:

```scala
import org.apache.tika.Tika
import org.apache.tika.parser.pdf
val tika = new Tika()
```

Read the jpeg file:

```scala
val filename="data/PDF/Scan_3.jpeg"
val df = spark.read.format("binaryFile").load(s"$filename")
df.printSchema()
df.show()
```

Detect the file type

```scala
import spark.implicits._
val map = df.select("path","content").as[(String, Array[Byte])].collect.toMap

import java.io.ByteArrayInputStream
val doc = map(s"file:/home/glue_user/workspace/jupyter_workspace/$filename")
tika.detect(doc)
```

Extract the text

```scala
import org.apache.tika.exception.TikaException
import org.apache.tika.parser.ParseContext
import org.apache.tika.parser.AutoDetectParser
import org.apache.tika.sax.BodyContentHandler
import org.apache.tika.metadata.Metadata

import org.apache.tika.parser.pdf.PDFParser
import java.io.ByteArrayInputStream

import org.apache.tika.parser.Parser
import org.apache.tika.parser.ocr.TesseractOCRConfig
import org.apache.tika.parser.pdf.PDFParserConfig

val handler = new BodyContentHandler();
val metadata = new Metadata();
val parser = new AutoDetectParser()
val context = new ParseContext();

val OCRConfig = new TesseractOCRConfig()
// val pdfConfig = new PDFParserConfig();
// pdfConfig.setExtractInlineImages(true)

// context.set(classOf[PDFParserConfig], pdfConfig)
context.set(classOf[TesseractOCRConfig], OCRConfig)
context.set(classOf[Parser], parser)
val text = parser.parse(new ByteArrayInputStream(doc), handler, metadata, context);
print(handler.toString())
```

> NOTE: In the above code, I've commented where the PDF parser can be used if you are using unsearchable PDF files.

if necessary, print all the meta data:

```scala
for (name <- metadata.names()) println($" ${name} :"+metadata.get(name))
spark.close() // close the spark session
```





[^1]: [Getting started with the Elastic Stack and Docker Compose: Part 1](https://www.elastic.co/blog/getting-started-with-the-elastic-stack-and-docker-compose)
