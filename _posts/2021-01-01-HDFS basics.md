---
layout: post
title:  HDFS Basics
date:   2021-01-01
categories: [Hadoop,HDFS]
---

After install the sandbox from the Hortonworks, you can visit the http://localhost:50070 page to find the information about the HDFS cluster. YARN job manager can be access via http://localhost:8088. 

<!--more-->


You can use of the following way to communicate with HDFS:

- Ambari
- CLI
- HTTP/HDFS proxies
- Java interface
- Network File System (NFS)

Login to the Hortonworks sandbox:

```bash
ssh root@localhost -p 2222
```

This is how you can copy files to VM baed sandbox using SCP:

```bash
scp -P 2222 mytest.txt root@localhost:
```

from sandbox to local machine:

```bash
scp -P 2222  root@localhost:m1.txt  m1.txt
```

run the following command to list the HDFS files in root directory of the HDFS:

```bash
hdfs dfs -ls /
```

to add the `myfiles` directory to the HDFS:

```bash
hdfs dfs -put myfiles 
```

To list the current directory

```bash
hdfs dfs -ls
```

The result should be like

![image-20210102143959773](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20210102143959773.png)

To delete the `myfiles` directory:

```bash
hdfs dfs -rm -r -skipTrash  myfiles
```

You can use the following command to list the Hadoop jobs:

```bash
hadoop job -list
```

Kill the job using JobId:

```bash
hadoop job -kill job_12...
```

