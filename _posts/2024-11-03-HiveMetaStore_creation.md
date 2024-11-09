---
layout: post
title:  Spark - create database and table
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


Spark by default uses the Apache Hive metastore:`/user/hive/warehouse`. we can set new location to create the meta store.
Please check the [example](https://github.com/dmatrix/examples/blob/master/spark/databricks/apps/scala/2.x/src/main/scala/zips/SparkSessionZipsExample.scala).


```scala
// val warehouseLocation = new File("spark-warehouse").getAbsolutePath
val warehouseLocation = "file:/opt/spark/work-dir/data/hive-spark-warehouse"
```





    warehouseLocation: String = file:/opt/spark/work-dir/data/hive-spark-warehouse


Create spark session


```scala
val spark = SparkSession.builder().appName("Spark Hive Example").config("spark.sql.warehouse.dir", warehouseLocation).
  enableHiveSupport().getOrCreate()
```





    spark: org.apache.spark.sql.SparkSession = org.apache.spark.sql.SparkSession@689f367b


You need to import implicit if you are going to access the Spark SQL context directly:


```scala
import spark.implicits._
import spark.sql

//set new runtime options
spark.conf.set("spark.sql.shuffle.partitions", 6)
// spark.conf.set("spark.executor.memory", "2g")
```





    import spark.implicits._
    import spark.sql



```scala
spark.catalog.listDatabases.show(false)
```





    +-------+----------------+--------------------------------+
    |name   |description     |locationUri                     |
    +-------+----------------+--------------------------------+
    |default|default database|file:/home/spark/spark-warehouse|
    +-------+----------------+--------------------------------+
    



```scala
spark.catalog.listTables.show(false)
```





    +----+--------+-----------+---------+-----------+
    |name|database|description|tableType|isTemporary|
    +----+--------+-----------+---------+-----------+
    +----+--------+-----------+---------+-----------+
    


By default, Spark creates tables under the default database. Create a database first:


```scala
sql("CREATE DATABASE movieLen")
sql("use database movieLen")
```





    res18: org.apache.spark.sql.DataFrame = []
    res19: org.apache.spark.sql.DataFrame = []


The `movies` unmanaged table was created from the `LOCATION` and metadata will be added to the Hive meta store created above.
Data never lost when you drop the table.


```scala
sql("""
CREATE TABLE movies (movieId INT,title STRING, genres STRING) USING CSV
    OPTIONS(header=true) 
    LOCATION '/opt/spark/work-dir/data/movieLense/ml-latest-small/movies.csv' 
""")
```





    res20: org.apache.spark.sql.DataFrame = []


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
    


Views can be visible globally across all SparkSessions on a given cluster or single `SparkSesision` called session-scoped. Views are temporary: they disappear after your Spark application terminates.


```scala
sql("CREATE OR REPLACE GLOBAL TEMP VIEW movie_temp AS SELECT title from movies where genres == 'Action';")
```





    res24: org.apache.spark.sql.DataFrame = []


To access from global temp, you have to use `global_temp`.


```scala
sql("SELECT * FROM  global_temp.movie_temp;").show()
```





    +--------------------+
    |               title|
    +--------------------+
    | Sudden Death (1995)|
    |    Fair Game (1995)|
    |Under Siege 2: Da...|
    |  Hunted, The (1995)|
    |Bloodsport 2 (a.k...|
    |Best of the Best ...|
    |  Double Team (1997)|
    |        Steel (1997)|
    |    Knock Off (1998)|
    |    Avalanche (1978)|
    |Aces: Iron Eagle ...|
    |Omega Code, The (...|
    |Minnie and Moskow...|
    |   Bloodsport (1988)|
    |Thunderbolt and L...|
    |Double Impact (1991)|
    |Kiss of the Drago...|
    |Game of Death (1978)|
    |     Red Heat (1988)|
    |Best of the Best ...|
    +--------------------+
    only showing top 20 rows
    


Caching the tables


```scala
sql("""
-- tags table
CREATE TABLE tags (userId INT, movieId INT, tag STRING, timestamp INT) USING CSV
    OPTIONS(header=true)
    LOCATION '/opt/spark/work-dir/data/movieLense/ml-latest-small/tags.csv'
""")

```





    res26: org.apache.spark.sql.DataFrame = []


Similar to the DataFrames, you can cache and uncache SQL tables and views. For example:


```scala
sql("cache lazy table tags")
```





    res27: org.apache.spark.sql.DataFrame = []


DataFrame can be saved as persistent table into Hive metastore:
> The `saveAsTable` will materialize the contents of the DataFrame and create a pointer to the data in the Hive metastore.


```scala
val tags_df = sql("select tag from tags")
```





    tags_df: org.apache.spark.sql.DataFrame = [tag: string]


Create a managed table `mytags`.


```scala
tags_df.write.mode("overwrite").option("path","/opt/spark/work-dir/data/hive").saveAsTable("mytags")
```





As a result:
![Fig.: SaveAsTable](/assets/images/2024-11-03-HiveMetaStore_creation/saveAsTable.png){: style="float: centre;  height: 65%; width: 65%; margin-left: 1em; margin-top: 2em;"}


```scala
sql("select * from mytags").show()
```





    +-----------------+
    |              tag|
    +-----------------+
    |            funny|
    |  Highly quotable|
    |     will ferrell|
    |     Boxing story|
    |              MMA|
    |        Tom Hardy|
    |            drugs|
    |Leonardo DiCaprio|
    |  Martin Scorsese|
    |     way too long|
    |        Al Pacino|
    |         gangster|
    |            mafia|
    |        Al Pacino|
    |            Mafia|
    |        holocaust|
    |       true story|
    |     twist ending|
    |  Anthony Hopkins|
    |  courtroom drama|
    +-----------------+
    only showing top 20 rows
    



```scala
sql("DROP TABLE IF EXISTS mytags")
```





    res35: org.apache.spark.sql.DataFrame = []



```bash
%%bash
ls /opt/spark/work-dir/data/hive
```

    _SUCCESS
    part-00000-f88cffd0-31d8-45a9-8dd9-7df24cddf266-c000.snappy.parquet


As shown above still data is available if the table is dropped.

Drop the database:


```scala
sql("DROP DATABASE IF EXISTS movieLen CASCADE")
```





    res45: org.apache.spark.sql.DataFrame = []


Stop the spark context


```scala
spark.stop()
```





This is the end of this short blog.
