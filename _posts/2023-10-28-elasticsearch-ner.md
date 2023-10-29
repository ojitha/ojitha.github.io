---
layout: post
title:  Elastic Search NER
date:   2020-07-11
categories: [ELK]
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

This post is on ElasticSearch 8 NER[^1]. 

<!--more-->

------

* TOC
{:toc}
------

## Install

Environment variable file `.env` is:

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
# LICENSE=basic
LICENSE=trial


# Port to expose Elasticsearch HTTP API to the host
ES_PORT=9200


# Port to expose Kibana to the host
KIBANA_PORT=5601


# Increase or decrease based on the available host memory (in bytes)
ES_MEM_LIMIT=2147483648
KB_MEM_LIMIT=1073741824
LS_MEM_LIMIT=1073741824


# SAMPLE Predefined Key only to be used in POC environments
ENCRYPTION_KEY=c34d38b3a14956121ff2170e5030b471551370178f43e5626eec58b04a30fae2
```

NOTE: You don't need user/password

The docker-compose.yml:

```yml
version: '3'

volumes:
 esdata01:
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
      - bootstrap.memory_lock=true
      - discovery.type=single-node
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

  kibana:
    depends_on:
     es01:
       condition: service_healthy
    image: docker.elastic.co/kibana/kibana:${STACK_VERSION}
    labels:
     co.elastic.logs/module: kibanaß
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

Install Eland client:

```bash
git clone git@github.com:elastic/eland.git
cd eland/
docker build -t elastic/eland .
```

Select a NER model from the [third-party model reference list](https://www.elastic.co/guide/en/machine-learning/8.10/ml-nlp-model-ref.html#ml-nlp-model-ref-ner). This example uses an [uncased NER model](https://huggingface.co/elastic/distilbert-base-uncased-finetuned-conll03-english).

```bash
docker run -it --rm --network elastic elastic/eland eland_import_hub_model --url http://es01:9200/ --hub-model-id elastic/distilbert-base-uncased-finetuned-conll03-english --task-type ner  --start --clear-previous
```

## Inferencing

API test using Kibana Dev Tools

```
POST _ml/trained_models/elastic__distilbert-base-uncased-finetuned-conll03-english/deployment/_infer
{
  "docs": [
    {
      "text_field": "Hi my name is Ojitha and I live in Sydeny"
    }
  ]
}
```

[Download](https://github.com/elastic/stack-docs/blob/8.5/docs/en/stack/ml/nlp/data/les-miserables-nd.json) the novel text split by paragraph as a JSON file, then upload it by using the [Data Visualizer](https://www.elastic.co/guide/en/kibana/8.10/connect-to-elasticsearch.html#upload-data-kibana). Give the new index the name `book` when uploading the file.

create the pipeline

```
PUT _ingest/pipeline/ner
{
  "description": "NER pipeline",
  "processors": [
    {
      "inference": {
        "model_id": "elastic__distilbert-base-uncased-finetuned-conll03-english",
        "target_field": "ml.ner",
        "field_map": {
          "paragraph": "text_field"
        }
      }
    },
    {
      "script": {
        "lang": "painless",
        "if": "return ctx['ml']['ner'].containsKey('entities')",
        "source": "Map tags = new HashMap(); for (item in ctx['ml']['ner']['entities']) { if (!tags.containsKey(item.class_name)) tags[item.class_name] = new HashSet(); tags[item.class_name].add(item.entity);} ctx['tags'] = tags;"
      }
    }
  ],
  "on_failure": [
    {
      "set": {
        "description": "Index document to 'failed-<index>'",
        "field": "_index",
        "value": "failed-{{{ _index }}}"
      }
    },
    {
      "set": {
        "description": "Set error message",
        "field": "ingest.failure",
        "value": "{{_ingest.on_failure_message}}"
      }
    }
  ]
}
```



Reindex the `book` index with `ner` pipeline:

```
POST _reindex
{
  "source": {
    "index": "book",
    "size": 50 
  },
  "dest": {
    "index": "les-miserables-infer",
    "pipeline": "ner"
  }
}
```







[^1]: [How to deploy named entity recognition](https://www.elastic.co/guide/en/machine-learning/current/ml-nlp-ner-example.html#ml-nlp-ner-example)