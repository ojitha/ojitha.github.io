---
layout: post
title:  Spark Hive metastore - create database and table
date:   2024-11-03
categories: [Apache Spark, Hive]
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

This is a short note to create a Hive meta store using Spark 3.3.1.

<!--more-->

The source directory can be either a file system or S3. In the case of the file system, We have to import the following:


```scala
import java.io.File
import org.apache.spark.sql.{Row, SaveMode, SparkSession}
```





    import java.io.File
    import org.apache.spark.sql.{Row, SaveMode, SparkSession}


Need a location to create the meta store


```scala
val warehouseLocation = new File("spark-warehouse").getAbsolutePath
```





    warehouseLocation: String = /home/spark/spark-warehouse


Create spark session


```scala
val spark = SparkSession.builder().appName("Spark Hive Example").config("spark.sql.warehouse.dir", warehouseLocation).
  enableHiveSupport().getOrCreate()
```





    spark: org.apache.spark.sql.SparkSession = org.apache.spark.sql.SparkSession@1a02d68a


You need to import implicit if you are going to access the Spark SQL context directly:


```scala
import spark.implicits._
import spark.sql
```





    import spark.implicits._
    import spark.sql


Create a database first:


```scala
sql("CREATE DATABASE movieLen")
```





    res13: org.apache.spark.sql.DataFrame = []


use that database to create a table


```scala
sql("use database movieLen")
```





    res14: org.apache.spark.sql.DataFrame = []


The `movies` table was created from the `LOCATION` and metadata will be added to the Hive meta store created above.


```scala
sql("""
CREATE TABLE movies (movieId INT,title STRING, genres STRING) USING CSV
    OPTIONS(header=true) 
    LOCATION '/opt/spark/work-dir/data/movieLense/ml-latest-small/movies.csv' 
""")
```





    res15: org.apache.spark.sql.DataFrame = []


Verify the table has been created


```scala
sql("select * from movies").show()
```





    +-------+--------------------+--------------------+
    |movieId|               title|              genres|
    +-------+--------------------+--------------------+
    |      1|    Toy Story (1995)|Adventure|Animati...|
    |      2|      Jumanji (1995)|Adventure|Childre...|
    |      3|Grumpier Old Men ...|      Comedy|Romance|
    |      4|Waiting to Exhale...|Comedy|Drama|Romance|
    |      5|Father of the Bri...|              Comedy|
    |      6|         Heat (1995)|Action|Crime|Thri...|
    |      7|      Sabrina (1995)|      Comedy|Romance|
    |      8| Tom and Huck (1995)|  Adventure|Children|
    |      9| Sudden Death (1995)|              Action|
    |     10|    GoldenEye (1995)|Action|Adventure|...|
    |     11|American Presiden...|Comedy|Drama|Romance|
    |     12|Dracula: Dead and...|       Comedy|Horror|
    |     13|        Balto (1995)|Adventure|Animati...|
    |     14|        Nixon (1995)|               Drama|
    |     15|Cutthroat Island ...|Action|Adventure|...|
    |     16|       Casino (1995)|         Crime|Drama|
    |     17|Sense and Sensibi...|       Drama|Romance|
    |     18|   Four Rooms (1995)|              Comedy|
    |     19|Ace Ventura: When...|              Comedy|
    |     20|  Money Train (1995)|Action|Comedy|Cri...|
    +-------+--------------------+--------------------+
    only showing top 20 rows
    


Show the available datases. You will ge the `default` database as well. 
> NOTE: The `default` database cannot be created or deleted.


```scala
sql("show databases").show()
```





    +---------+
    |namespace|
    +---------+
    |  default|
    | movielen|
    +---------+
    


Show the tables of all the databases:


```scala
sql("show tables").show()
```





    +---------+---------+-----------+
    |namespace|tableName|isTemporary|
    +---------+---------+-----------+
    | movielen|   movies|      false|
    +---------+---------+-----------+
    


Drop the table:


```scala
sql("DROP TABLE IF EXISTS movies")
```





    res19: org.apache.spark.sql.DataFrame = []


Drop the database:


```scala
sql("DROP DATABASE movieLen")
```





    res20: org.apache.spark.sql.DataFrame = []


Stop the spark context


```scala
spark.stop()
```





This is the end of this short blog.
