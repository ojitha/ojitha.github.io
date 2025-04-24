---
layout: notes 
title: Apache Spark
---

# Apache Spark notest
{:.no_toc}

---

* TOC
{:toc}

---



## Spark Docker configurations

### Create Spark 3.4.4 Docker container from Amazon Linux 2

I haven't found direct way to access Spark server from the Jupyter lab. 
Therefore, I've used the Apache Livy server. Here the docker file:

```dockerfile
FROM amazonlinux:2

# Install essential packages
RUN yum update -y && \
    yum install -y \
    python3 \
    python3-pip \
    java-11-amazon-corretto \
    wget \
    tar \
    gzip

RUN yum groupinstall 'Development Tools' -y
RUN yum install -y krb5-workstation krb5-libs krb5-devel  
RUN yum install -y python3-devel
RUN yum install -y procps  

# Make Python 3 the default
RUN alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    alternatives --set python /usr/bin/python3 && \
    alternatives --install /usr/bin/pip pip /usr/bin/pip3 1 && \
    alternatives --set pip /usr/bin/pip3

    
# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto

# Install Apache Spark
ENV SPARK_VERSION=3.4.4
ENV SPARK_HOME=/opt/spark

# Copy and extract Spark
COPY spark-${SPARK_VERSION}-bin-hadoop3.tgz /tmp/
RUN tar -xzf /tmp/spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop3 ${SPARK_HOME} && \
    rm /tmp/spark-${SPARK_VERSION}-bin-hadoop3.tgz

# Set Spark environment variables
ENV PATH=$PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin
ENV PYSPARK_PYTHON=python3


# Create spark-defaults.conf file
RUN mkdir -p ${SPARK_HOME}/conf
RUN echo "spark.driver.extraJavaOptions=-Djava.security.krb5.realm= -Djava.security.krb5.kdc= -Djava.awt.headless=true" > ${SPARK_HOME}/conf/spark-defaults.conf

# Set environment variable to silence the native library warning
ENV HADOOP_HOME=${SPARK_HOME}
ENV SPARK_CONF_DIR=${SPARK_HOME}/conf
ENV HADOOP_CONF_DIR=${SPARK_HOME}/conf

# Create empty native directory
RUN mkdir -p ${HADOOP_HOME}/lib/native

# Install Python dependencies
RUN pip3 install urllib3==1.26.6
RUN pip3 install --no-cache-dir \
    jupyterlab==3.5.2 \
    ipywidgets \
    sparkmagic

# Configure sparkmagic mkdir -p /usr/local/share/jupyter/kernels \
RUN jupyter-kernelspec install --user $(pip show sparkmagic | grep Location | cut -d" " -f2)/sparkmagic/kernels/sparkkernel  \
    && jupyter-kernelspec install --user $(pip show sparkmagic | grep Location | cut -d" " -f2)/sparkmagic/kernels/pysparkkernel \
    # && jupyter-kernelspec install --user $(pip show sparkmagic | grep Location | cut -d" " -f2)/sparkmagic/kernels/sparkrkernel \
    && jupyter server extension enable --py sparkmagic \
    && jupyter nbextension enable --py widgetsnbextension 
 

# Create sparkmagic config
RUN mkdir -p ~/.sparkmagic && cat <<EOF > ~/.sparkmagic/config.json
{
    "kernel_python_credentials": {
        "username": "",
        "password": "",
        "url": "http://127.0.0.1:8998",
        "auth": "None"
    },
    "kernel_scala_credentials": {
        "username": "",
        "password": "",
        "url": "http://127.0.0.1:8998",
        "auth": "None"
    },
    "custom_headers": {},
    "session_configs": {
        "driverMemory": "1g",
        "executorMemory": "1g"
    },
    "server_extension_default_kernel_name": "pysparkkernel",
    "use_auto_viz": true,
    "codemirror_mode": "python",
    "heartbeat_refresh_seconds": 30,
    "livy_server_heartbeat_timeout_seconds": 0,
    "retry_seconds": 1,
    "retry_seconds_after_failure": 5,
    "arrow_enabled": true,
    "max_display_rows": 1000
}
EOF

# Install Apache Livy
ENV LIVY_VERSION=0.8.0-incubating
ENV LIVY_HOME=/opt/apache-livy-0.8.0-incubating_2.12-bin

# Download and install Livy
RUN wget https://dlcdn.apache.org/incubator/livy/0.8.0-incubating/apache-livy-0.8.0-incubating_2.12-bin.zip -P /tmp/
RUN   unzip /tmp/apache-livy-0.8.0-incubating_2.12-bin.zip -d /opt/  \
      && rm /tmp/apache-livy-0.8.0-incubating_2.12-bin.zip

# Configure Livy
RUN mkdir -p ${LIVY_HOME}/logs

# COPY log4j.properties ${LIVY_HOME}/conf/

RUN cat <<EOF > /opt/apache-livy-0.8.0-incubating_2.12-bin/conf/livy.conf
livy.server.host = 0.0.0.0
livy.server.port = 8998
livy.spark.master = local[*]
livy.repl.enable-hive-context = true
livy.spark.scala-version = 2.12
# livy.file.local-dir-whitelist = /opt/spark/.livy-sessions
EOF

RUN echo '#!/bin/bash' > /start-services.sh && \
    echo 'set -e' >> /start-services.sh && \
    echo 'echo "Starting Livy server..."' >> /start-services.sh && \
    echo '${LIVY_HOME}/bin/livy-server start' >> /start-services.sh && \
    echo 'echo "Waiting for Livy server to start..."' >> /start-services.sh && \
    echo 'sleep 10' >> /start-services.sh && \
    echo 'echo "Starting JupyterLab..."' >> /start-services.sh && \
    echo 'cd /app && jupyter lab --no-browser --ip=0.0.0.0 --allow-root --ServerApp.root_dir=/app --ServerApp.token="pyspark" --ServerApp.password=""' >> /start-services.sh && \
    chmod +x /start-services.sh

# Create working directory
WORKDIR /app

# Expose JupyterLab port
EXPOSE 8888 8999

RUN pip install findspark
ENV PYTHONPATH=${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.9.7-src.zip
ENV PATH=$PATH:${JAVA_HOME}/bin

CMD ["/start-services.sh"] 
```

You have to <span>download Spark and other files before create docker</span> container:
1. [Spark 3.4.4](https://downloads.apache.org/spark/spark-3.4.4/spark-3.4.4-bin-hadoop3.tgz)
2. [Apache Livy](https://dlcdn.apache.org/incubator/livy/0.8.0-incubating/apache-livy-0.8.0-incubating_2.12-bin.zip)

To build this image:

```bash
docker build -t spark-dev . --progress=plain
```

To create a container:

```bash
docker run  -it --rm  -p 8888:8888 -p 4040:4040  -p 8998:8998  -v $(pwd):/app   spark-dev
```

### Update the Dockerfile to use Tika

Simply replace the `findspark` line in the above script with the following lines:

```dockerfile
RUN pip install findspark
RUN wget https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.zip
RUN unzip apache-maven-3.9.5-bin.zip -d /opt/
RUN mv /opt/apache-maven-3.9.5 /opt/maven
ENV MAVEN_HOME=/opt/maven
ENV PATH=$PATH:${MAVEN_HOME}/bin
COPY pom.xml .
RUN mvn dependency:copy-dependencies
RUN cp target/dependency/*.* ${SPARK_HOME}/jars/
RUN rm -rf target
```

The pom.xml file:

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

### Dockerfile from Glue

The simplest way to create working Spark single cluster for Jupyter.

```dockerfile
FROM amazon/aws-glue-libs:glue_libs_4.0.0_image_01 as base
USER root
# RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
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

To enable the Tika capabilities, use the above `pom.xml` file.

Here is the `start.sh` :

```bash 
livy-server start
jupyter lab --no-browser --ip=0.0.0.0 --allow-root --ServerApp.root_dir=/home/glue_user/workspace/jupyter_workspace/ --ServerApp.token='pyspark' --ServerApp.password=''
```



## Spark Applications

### Jupyter 

#### PDF metadata extraction

Here the Jupyter example

specify the filename to extract metadata

```scala
// Example with one file
val filename="/opt/spark/work-dir/data/test.pdf"
```

Create a dataframe from that

```scala
val df = spark.read.format("binaryFile").load(s"$filename")
df.printSchema()
df.show()
```

Get the binary data

```scala
import spark.implicits._
val map = df.select("path","content").as[(String, Array[Byte])].collect.toMap
```

initiate Tika

```scala
import org.apache.tika.Tika
import org.apache.tika.parser.pdf
val tika = new Tika()
```

Detect the document

```scala
import java.io.ByteArrayInputStream
val doc = map(s"file:$filename")
tika.detect(doc)
```

Parser the data

```scala
import org.apache.tika.exception.TikaException
import org.apache.tika.parser.ParseContext
import org.apache.tika.parser.AutoDetectParser
import org.apache.tika.sax.BodyContentHandler
import org.apache.tika.metadata.Metadata

import org.apache.tika.parser.pdf.PDFParser
import java.io.ByteArrayInputStream

val handler = new BodyContentHandler();
val metadata = new Metadata();
val pdfparser = new PDFParser()
val context = new ParseContext();

val text = pdfparser.parse(new ByteArrayInputStream(doc), handler, metadata, context);
// print(handler.toString())
```

List the metadata:

```scala
for (name <- metadata.names()) println($" ${name} :"+metadata.get(name))
```

OCR

```scala
for (name <- metadata.names()) println($" ${name} :"+metadata.get(name))
```

use the `spark.stop()` close the sesstion.

#### JPEG metadata extraction

Initiate the Tika

```scala
import org.apache.tika.Tika
val tika = new Tika()
```

Create dataframe from images

```scala
val filename="data/PDF/Scan_3.jpeg"
val df = spark.read.format("binaryFile").load(s"$filename")
df.printSchema()
df.show()
```

extract binary to avoid UDF:

```scala
import spark.implicits._
val map = df.select("path","content").as[(String, Array[Byte])].collect.toMap
```

Detect the document

```scala
import java.io.ByteArrayInputStream
val doc = map(s"file:/home/glue_user/workspace/jupyter_workspace/$filename")
tika.detect(doc)
```

parser the document

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

iterate over metadata:

```scala
for (name <- metadata.names()) println($" ${name} :"+metadata.get(name))
```

You can close the spark session with  `spark.stop()`.

### Scala 

#### Auto Parser

Here is the sample application written in Java and Scala for Spark 3.

the pom.xml:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>io.github.ojitha.blog.de.findmetadata</groupId>
    <artifactId>metaextract</artifactId>
    <version>1-SNAPSHOT</version>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <scala.version>2.12.15</scala.version>
        <scala.binary.version>2.12</scala.binary.version>
        <spark.version>3.4.4</spark.version>
        <tika.version>3.0.0</tika.version>
        <java.version>11</java.version>
    </properties>

    <dependencies>
        <!-- Scala -->
        <dependency>
            <groupId>org.scala-lang</groupId>
            <artifactId>scala-library</artifactId>
            <version>${scala.version}</version>
        </dependency>

        <!-- Apache Spark -->
        <dependency>
            <groupId>org.apache.spark</groupId>
            <artifactId>spark-core_${scala.binary.version}</artifactId>
            <version>${spark.version}</version>
            <scope>provided</scope>
        </dependency>

        <!-- Apache Tika -->
        <dependency>
            <groupId>org.apache.tika</groupId>
            <artifactId>tika-core</artifactId>
            <version>${tika.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.tika</groupId>
            <artifactId>tika-parsers-standard-package</artifactId>
            <version>${tika.version}</version>
        </dependency>

        <!-- Test Dependencies -->
        <dependency>
            <groupId>org.scalatest</groupId>
            <artifactId>scalatest_${scala.binary.version}</artifactId>
            <version>3.2.15</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <sourceDirectory>src/main/scala</sourceDirectory>
        <testSourceDirectory>src/test/scala</testSourceDirectory>
        <plugins>
            <!-- Scala Compiler -->
            <plugin>
                <groupId>net.alchim31.maven</groupId>
                <artifactId>scala-maven-plugin</artifactId>
                <version>4.8.1</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>compile</goal>
                            <goal>testCompile</goal>
                        </goals>
                    </execution>
                </executions>
                <configuration>
                    <scalaVersion>${scala.version}</scalaVersion>
                </configuration>
            </plugin>

            <!-- Maven Shade Plugin for creating uber JAR -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-shade-plugin</artifactId>
                <version>3.4.1</version>
                <executions>
                    <execution>
                        <phase>package</phase>
                        <goals>
                            <goal>shade</goal>
                        </goals>
                        <configuration>
                            <transformers>
                                <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                                    <mainClass>io.github.ojitha.blog.de.findmetadata.MetadataExtractor</mainClass>
                                </transformer>
                                <transformer implementation="org.apache.maven.plugins.shade.resource.ServicesResourceTransformer"/>
                            </transformers>
                            <filters>
                                <filter>
                                    <artifact>*:*</artifact>
                                    <excludes>
                                        <exclude>META-INF/*.SF</exclude>
                                        <exclude>META-INF/*.DSA</exclude>
                                        <exclude>META-INF/*.RSA</exclude>
                                    </excludes>
                                </filter>
                            </filters>
                        </configuration>
                    </execution>
                </executions>
            </plugin>

            <!-- Java Compiler -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
                <configuration>
                    <source>${java.version}</source>
                    <target>${java.version}</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

Scala source

```scala
package io.github.ojitha.blog.de.findmetadata

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.tika.metadata.Metadata
import org.apache.tika.parser.{AutoDetectParser, ParseContext}
import org.apache.tika.sax.BodyContentHandler
import org.xml.sax.ContentHandler

import java.io.{ByteArrayInputStream, FileNotFoundException}
import scala.collection.JavaConverters._
import scala.util.{Failure, Success, Try}

object MetadataExtractor {
  def main(args: Array[String]): Unit = {
    if (args.length != 2) {
      System.err.println("Usage: MetadataExtractor <input_path> <output_path>")
      System.exit(1)
    }

    val inputPath = args(0)
    val outputPath = args(1)

    // Initialize Spark
    val conf = new SparkConf()
      .setAppName("Document Metadata Extractor")
    val sc = new SparkContext(conf)

    try {
      // Read all files from input directory
      val files = sc.binaryFiles(inputPath)

      // Process each file to extract metadata
      val results = files.map { case (path, content) =>
        val fileName = path.split("/").last
        extractMetadata(fileName, content.toArray())
      }

      // Save results
      results.saveAsTextFile(outputPath)
    } finally {
      sc.stop()
    }
  }

  private def extractMetadata(fileName: String, content: Array[Byte]): String = {
    Try {
      val parser = new AutoDetectParser()
      val metadata = new Metadata()
      val context = new ParseContext()
      
      // Set filename for better mime type detection
      // metadata.set(Metadata.RESOURCE_NAME_KEY, fileName)
      
      // Use empty content handler to avoid content parsing
      val handler: ContentHandler = new BodyContentHandler(-1)
      
      // Parse metadata only
      parser.parse(new ByteArrayInputStream(content), handler, metadata, context)
      
      // Convert metadata to map
      val metadataMap = metadata.names().map(name => 
        name -> metadata.get(name)
      ).toMap
      
      s"File: $fileName\nMetadata: ${metadataMap.mkString(", ")}"
    } match {
      case Success(result) => result
      case Failure(e) => s"Error processing $fileName: ${e.getMessage}"
    }
  }
}
```

submit to the Spark:

```bash
spark-submit \
  --class io.github.ojitha.blog.de.findmetadata.MetadataExtractor \
  --master local[*] \
  apps/metaextract/target/metaextract-1-SNAPSHOT.jar \
  apps/data/BaB.pdf \
  apps/data/file_metadata
```

## Bloom Filter

### Scala Bloom Filter

Example Jupyter notebook

```scala
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions.col

// Initialize Spark session
val spark = SparkSession.builder().appName("BloomFilterExample").getOrCreate()
import spark.implicits._

// Create sample DataFrames
// DataFrame 1: Events with IDs
val events = Seq((0, "event0"), (1, "event1"), (2, "event2"), (3, "event3"))
val eventsDF = events.toDF("id", "event")

// DataFrame 2: IDs to filter by
val ids = Seq((0), (1), (2))
val idsDF = ids.toDF("id")

// Create Bloom filter on 'id' column of idsDF
val expectedNumItems = 1000L // Estimated distinct items
val fpp = 0.01 // 1% false positive probability
val bloomFilter = idsDF.stat.bloomFilter(col("id"), expectedNumItems, fpp)

// Broadcast Bloom filter to executors
val bloomFilterBC = spark.sparkContext.broadcast(bloomFilter)

// Filter eventsDF using Bloom filter
val filteredDF = eventsDF.filter { row =>
  val id = row.getAs[Int]("id")
  bloomFilterBC.value.mightContain(id)
}

// Show results
println("Original Events DataFrame:")
eventsDF.show()
println("IDs DataFrame:")
idsDF.show()
println("Filtered Events DataFrame:")
filteredDF.show()

// Clean up
bloomFilterBC.unpersist()
spark.stop()
```



### PySpark Bloom filter

example Jupyter script:

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col

# Initialize Spark session
spark = SparkSession.builder.appName("BloomFilterExample").getOrCreate()

# Create sample DataFrames
# DataFrame 1: Events with IDs
events_data = [(0, "event0"), (1, "event1"), (2, "event2"), (3, "event3"), (4, "event4"), (5, "event5")]
events_df = spark.createDataFrame(events_data, ["id", "event"])

# DataFrame 2: List of IDs to filter by
ids_data = [(0,), (1,), (2,)]
ids_df = spark.createDataFrame(ids_data, ["id"])

# Create a Bloom filter on the 'id' column of ids_df
expected_num_items = 1000  # Estimate of distinct items
fpp = 0.01  # 1% false positive probability
bloom_filter = ids_df.stat.bloomFilter("id", expected_num_items, fpp)

# Broadcast the Bloom filter to executors
bloom_filter_bc = spark.sparkContext.broadcast(bloom_filter)

# Define a UDF to check membership in the Bloom filter
from pyspark.sql.functions import udf
from pyspark.sql.types import BooleanType

def might_contain(id_val):
    return bloom_filter_bc.value.mightContain(id_val) if id_val is not None else False

might_contain_udf = udf(might_contain, BooleanType())

# Filter events_df using the Bloom filter
filtered_df = events_df.filter(might_contain_udf(col("id")))

# Show results
print("Original Events DataFrame:")
events_df.show()
print("IDs DataFrame:")
ids_df.show()
print("Filtered Events DataFrame:")
filtered_df.show()

# Clean up
bloom_filter_bc.unpersist()
spark.stop()

```

## PySpark Package not Found

For the `JavaPackage object is not callable` error in the PySpark:

```python
import findspark
findspark.init()
from py4j.java_gateway import java_import
java_import(spark._sc._jvm, "org.apache.spark.sql.api.python.*")
```

