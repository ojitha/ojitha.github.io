---
layout: post
title:  MapReduce
date:   2021-01-03
categories: [Hadoop]
toc: true
---

Hadoop MapReduce well explains the pain is writing too much code for simple MapReduce in Java. This organic blog explains how to use [MRJob](https://mrjob.readthedocs.io/en/latest/) package in Python to write and execute Movie ratings.

<!--more-->

* TOC
{:toc}
## Introduction

MapReduce is natively Java-based. Hadoop streaming interface allows to written MapReduce in other languages such as C++ and Python.

This is the good explanation found in section 4.3 "Understand how MapReduce works"[^2]:

![MapReduce explained](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20210103115520588.png)

> NOTE: HDFS examples are given in the [HDFS Basics]({% post_url 2021-01-01-HDFS basics %}).

## Prepare Python

I am using Hortonworks 2.6.5 for the following RatingsBreakdown.py[^1] example. First download:

```bash
wget http://media.sundog-soft.com/hadoop/RatingsBreakdown.py
```

Here the python source:


```python
from mrjob.job import MRJob
from mrjob.step import MRStep

class RatingsBreakdown(MRJob):
    def steps(self):
        return [
            MRStep(mapper=self.mapper_get_ratings,
                   reducer=self.reducer_count_ratings)
        ]

    def mapper_get_ratings(self, _, line):
        (userID, movieID, rating, timestamp) = line.split('\t')
        yield rating, 1

    def reducer_count_ratings(self, key, values):
        yield key, sum(values)

if __name__ == '__main__':
    RatingsBreakdown.run()
```
and

```bash
wget http://media.sundog-soft.com/hadoop/ml-100k/u.data
```


Install pip: 

```bash
sudo yum install python-pip
```

Now upgrade the pip version:

```bash
sudo pip install --upgrade pip
```

Install the MRJob:

```bash
pip install mrjob==0.5.11
```

When the installation is finished, run the MapReduce job as follows.

## Run on Hadoop

In the Hortonworks 2.6.5, streaming jar is available at `/usr/hdp/current/hadoop-mapreduce-client/hadoop-streaming.jar`.

![image-20210103180002108](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20210103180002108.png)

First, copy the u.data to data directory as shown in the above screenshot. To run the MapReduce job:

```bash
python RatingsBreakdown.py -r hadoop --hadoop-streaming-jar /usr/hdp/current/hadoop-mapreduce-client/hadoop-streaming.jar hdfs://172.18.0.2:8020/user/maria_dev/data/u.data
```

## Investigate the Job

If you want to investigate the job ran above. Find the job as follows:

```bash
mapred job -list all
```

From the above command, you will get the job number. Now find the URL for the job executing the following command:

```bash
mapred job -status job_<number>
```



REF

[^1]: The Ultimate Hands-on Hadoop, Frank Kane, Packt Publishing 2017 
[^2]: Hadoop and Spark Fundamentals, Douglas Eadline, Addison-Wesley Professional 2018

