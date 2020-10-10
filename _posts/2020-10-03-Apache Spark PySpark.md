---
layout: post
title: "Apache Spark begin with PySpark"
date:   2020-10-03 20:01:30 +1000
categories: [blog]
excerpt_separator: <!--more-->
---

PySpark is one of the most popular way of using Spark. This blog consider the basics use of Spark SQL with data frames.

<!--more-->

* TOC
{:toc}

## First Step
To start you new SparkSession

```python
from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("MyApp").getOrCreate()
```

Let us create `hello word` first:

```python
df = spark.sql('SELECT "hello world" as c1')
df.show()
```

It is important to stop your application at the end

```python
spark.stop()
```

Spark uses lazy evaluation and Catalyst query optimisation to plan an exeecution plan  to be triggered when action happened.

There are three different operations at the level of Data Frames:

1. Transformation: Spark wait until the lazy transformation encounters an action.
2. Action: All the transformations collected will be performed
3. Property: Depending on the context, property can be either action or transformation.

> Spark keeps a lineage graph (DAG) of all transformations requested of the data.

## Spark SQL

The query API to query structured data within the Spark context. Spark SQL has native Hadoop/Hive integration.

The first example is to read a CSV file:

```python
df = spark.read.csv(path="ratings.csv"
                    ,sep=","
                    ,header=True
                    ,inferSchema=True
                   )
```

The `inferSchema` inference the data type. If you execute `df.printSchema(), you will get:

![image-20201004173447563](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20201004173447563.png)

Or you can specify the type:

```python
,schema="userId string,movieId string,rating double,timestamp int"
```

instead of the `inferSchema`. The above timestamp can be translated to unix time as follows:

```python
df = (
    df
    .withColumnRenamed("timestamp","unix_ts")
    .withColumn("timestamp", f.from_unixtime("unix_ts"))
)
```

If you want to change the type of the timestamp string to timestamp, then add the following as well:

```python
...
		.withColumn("timestamp", f.to_timestamp("timestamp"))
)
```

Or you can do this when you are loading the CSV file:

```python
df = (
     spark.read.csv(path="ratings.csv"
        ,sep=","
        ,header=True
        ,schema="userId int,movieId int,rating double,timestamp int"
    )
    .withColumnRenamed("timestamp", "unix_ts")
    .withColumn("timestamp", f.to_timestamp(f.from_unixtime("unix_ts")))
)
```

If you want to filter 

```python
df.where(f.col("rating") > 4).show()
```

If you want to do `where` in python way

```python
movies = (
    spark.read.csv(
        path="movies.csv"
        ,sep=","
        ,header=True
        ,quote='"'
        ,schema="movieId int, title string, genres string"
    )
)
```

Here the output

![image-20201010112745165](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20201010112745165.png)

then python way

```python
movies.where("genres = 'Action'").show()
```

or Spark SQL way

```python
movies.where(f.col('genres') == 'Action').count()
```

As shown in the above screenshot, `genres` is separated by the pipe symbol. Using `f.split` function, you can create an array of genres for each row.

```python
mgenre = (
    movies.withColumn("agenres", f.split("genres","\|"))
)
mgenre.printSchema()
```



![image-20201010114718863](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20201010114718863.png)

You can explode based on the genres as follows:

```python
mgenre = (
    movies
    # .withColumn("agenres", f.split("genres","\|"))
    .withColumn("egenre", f.explode(f.split("genres","\|")))
)
mgenre.show(5,truncate=False)
mgenre.printSchema()
```

![image-20201010120227183](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20201010120227183.png)

You can simplify your output droping the genres if you want

```python
mgenre = (
    movies
    # .withColumn("agenres", f.split("genres","\|"))
    .withColumn("egenre", f.explode(f.split("genres","\|")))
    .select("movieId", "title", "egenre")
)
```

For example,

```python
mgenre.show(20,truncate=False)
mgenre.printSchema()
```

the output is 

![image-20201010120721310](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20201010120721310.png)

Now you can query to see all the avaialble genres:

```python
mgenre.select("egenre").distinct().show()
```

![image-20201010122035508](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20201010122035508.png)

If you want to list which moves doesn't have genres

```python
movies.where(f.col("genres") == "(no genres listed)").show()
```

if you want to count how many films belongs to each genre

```python
mgenre.groupBy("egenre").count().show()
```

If you want to find that how many genras for each movie:

```python
mgenre.groupBy("movieId").count().show()
```

For inner join the above and the movie data frame give you the result of how many genras for each movie:

```python
movies.join(mgenre.groupBy("movieId").count(),['movieId'], how = "inner").show(truncate=False)
```

![image-20201010140404297](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20201010140404297.png)

There are following joining options:

- inner
- cross (better to use `.crossJoin()`)
- outer
- left outer
- right outer
- left semi
- left anti

## Aggregations

You can use aggreations as follows:

```python
ratings.groupBy("movieId").agg(
    f.count("*"),
    f.min("rating")
).show()
```

The function `collect_set` is the inverse of explode explained above. For example,

```python
tags.where(f.col("movieId") == 1959).show()
```

the result is as follows:

![image-20201010172339770](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20201010172339770.png)

if you run the following command:

```python
tags.groupBy("movieId").agg(
    f.collect_set("tag")
).show()
```

![image-20201010172447987](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20201010172447987.png)

As shown in the above figure, collect_set(tag) has created an array. You can change the second column name to `tags` using `alias` command.

```python
tags.groupBy("movieId").agg(
    f.collect_set("tag").alias("tags"),
    f.count("tag").alias("number_of_tags")
).sort(f.col("number_of_tags").desc()).show()
```

In the above code tags are listed with number of tags per movie.



<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE3MTE3OTM3MzZdfQ==
-->