---
layout: post
title:  Spark to create table in AWS Redshift
date:   2023-06-09
categories: [AWS,Redshift, Apache Spark]
---

In this post, Spark read the data from a CSV file to a DateFrame and save that DataFrame as a Redshift table.

<!--more-->

This example has been ran in the Jupyter notebook. 

Configure the Redhsift JDBC driver and Spark Redshift dirver.

```python
%%configure -f
{
  "conf": {
    "spark.jars": "s3://<bucket>/jdbc/redshift-jdbc42-2.1.0.9.jar,s3://<bucket>/jdbc/spark-redshift.jar"
  }
}
```

As ususal create Spark session

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
        .appName("connectToRedshift") \
        .enableHiveSupport() \
        .getOrCreate()
```

In the AWS Console, find the Redshift database JDBC url

```python
url = "jdbc:redshift://<redshift-database...>.<tt...>.ap-southeast-2.redshift.amazonaws.com:5439/<database>"
```

Please specify the database name at the end of the URL.

Create the Schema for the table

```python
from pyspark.sql.types import StructType, StructField, DateType, DecimalType, StringType
tbl_retail_sales = StructType([
    StructField("sales_month",DateType(),False),
    StructField("naics_code", StringType(), False),
    StructField("kind_of_business", StringType(), False),
    StructField("reason_for_null", StringType(), False),
    StructField("sales", DecimalType(8,2), False)
    ]
)
```

Above schem is create for the us_retail_sales.csv[^1] file to read.

```python
df = spark.read.option("header", True).schema(tbl_retail_sales).csv("test1.csv")
# verify the schema
df.printSchema()
```

The most important step wanted to hilighted in this post is create a table in the <database> specified above.

```python
df.write \
    .format("io.github.spark_redshift_community.spark.redshift") \
    .option("url", url) \
    .option("user","<redshift user name>") \
    .option("password","<reshift password>") \
    .option("forward_spark_s3_credentials", "true") \
    .option("tempdir", "s3://<bucke>/temp") \
    .option("dbtable", "public.retail_sales") \
    .mode('append').save()
```

Above table will be created as <database>.public.retail_sales.

To read the Redhsift table

```python
# Read data from a table
df_tbl = spark.read \
    .format("io.github.spark_redshift_community.spark.redshift") \
    .option("url", url) \
    .option("user","<redshift user name>") \
    .option("password","<reshift password>") \
    .option("forward_spark_s3_credentials", "true") \
    .option("tempdir", "s3://<bucke>/temp") \
    .option("query", "SELECT * FROM public.retail_sales") \
    .load()
```

You can verify with

```python
df_tbl.show(5)
```


References:

[^1]: [](https://github.com/cathytanimura/sql_book/tree/master/Chapter%203:%20Time%20Series%20Analysis)
