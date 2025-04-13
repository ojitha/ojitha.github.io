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

## Create Spark 3.4.4 Docker container from Amazon Linux 2
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

## Update the Dockerfile to use Tika

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

