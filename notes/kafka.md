---
layout: notes
title: Apache Kafka
category: messaging
tags: [streaming, distributed-systems, apache]
mermaid: true
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

Kafka Notes
{:.no_toc}

---

* TOC
{:toc}

---

## Getting Started with Confluent CLI
Reference: [Apache Kafka® Quick Start - Local Install With Docker](https://developer.confluent.io/quickstart/kafka-local/)


> I've alreay installed
> - Docker Desktop
> - `brew install confluentinc/tap/cli`
> - I have `bash-completion` installed. 

As explained in the [confluent completion | Confluent Documentation](https://docs.confluent.io/confluent-cli/current/command-reference/confluent_completion.html), install the confluent bash completion:

```bash
/usr/local/etc/bash_completion.d/
```

To start [KRaft](https://developer.confluent.io/learn/kraft/):

```bash
confluent local kafka start
```

you will get the message:

To continue your Confluent Local experience, run `confluent local kafka topic create <topic>` and `confluent local kafka topic produce <topic>`.

I've created `quickstart` topic:
```bash
confluent local kafka topic create quickstart
```

## Using Docker Compose

Here the file from the [tutorials/kafka-on-docker at master · confluentinc/tutorials](https://github.com/confluentinc/tutorials/tree/master/kafka-on-docker):

```yml
services:
  broker:
    image: apache/kafka:latest
    hostname: broker
    container_name: broker
    ports:
      - 9092:9092
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT,CONTROLLER:PLAINTEXT
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://broker:29092,PLAINTEXT_HOST://localhost:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS: 0
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
      KAFKA_PROCESS_ROLES: broker,controller
      KAFKA_NODE_ID: 1
      KAFKA_CONTROLLER_QUORUM_VOTERS: 1@broker:29093
      KAFKA_LISTENERS: PLAINTEXT://broker:29092,CONTROLLER://broker:29093,PLAINTEXT_HOST://0.0.0.0:9092
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_CONTROLLER_LISTENER_NAMES: CONTROLLER
      KAFKA_LOG_DIRS: /tmp/kraft-combined-logs
      CLUSTER_ID: MkU3OEVBNTcwNTJENDM2Qk
    volumes:
    - ./data:/data      
```

In addtion to that I have added the volume:
```yml
  volumes:
  - ./data:/data
```

To login to the docker container:

```bash
docker exec -it -w /opt/kafka/bin broker sh
```
To find the kafka version:

```bash
./kafka-topics.sh --version
```
> I am using Kafka 3.9.0.

To create a topic:

```bash
./kafka-topics.sh --create --topic my-topic --bootstrap-server broker:29092
```
