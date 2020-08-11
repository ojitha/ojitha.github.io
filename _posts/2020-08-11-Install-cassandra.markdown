---
layout: post
title: "Install Cassandra"
date:   2020-08-11 21:45:30 +1000
categories: [blog]
excerpt_separator: <!--more-->
---

Apache [Cassandra](https://cassandra.apache.org) is well known big data database. Here the summarisation of how to install. Follow the [instructions](https://cassandra.apache.org/doc/latest/getting_started/installing.html) for more information.

![Apache Cassandra](https://cassandra.apache.org/img/cassandra_logo.png)
<!--more-->

First download:
Download the [Cassandra](https://cassandra.apache.org)
```bash
wget http://archive.apache.org/dist/cassandra/4.0-alpha4/apache-cassandra-4.0-alpha4-bin.tar.gz
```

Extract that:

```bash
tar xvzf apache-cassandra-4.0-alpha4-bin.tar.gz
```
the configuration file for the Cassandra is `cassandra.yaml`.
Start the Daemon

```bash
cd apache-cassandra-4.0-alpha4
bin/cassandra -R
```

NOTE: for supper user need `-R` and for foreground run `-f`. To stop the server at the end you have to write the PID to a file, for that use `-p`.

To search the log 
```bash
grep -m 1 -C 1 "cassandra.yaml" logs/system.log
```

To find the version of the Cassandra:
```bash
grep -m 1 -A 2 "Cassandra version" logs/system.log
```

To find the JMX
```bash
grep -m 1 "JMX" logs/system.log
```

for CQL client
```bash
grep -m 1 "listening" logs/system.log
```

connect to CQLSH:
```bash
bin/cqlsh
```

To learn the cluster you are working on
```bash
ESCRIBE CLUSTER
```

to exit from CQLSH
```bash
EXIT;
```

To stop the server
```bash
bin/stop-server
```

The best way to stop the server is
```bash
user=`whoami`
pkill -u $user -f cassandra
```

