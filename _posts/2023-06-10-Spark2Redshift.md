---
layout: post
title:  Spark to create a table in AWS Redshift
date:   2023-06-13
categories: [AWS, Redshift, Apache Spark]
---

In this post, Spark reads the data from a CSV file to a DateFrame and saves that DataFrame as a Redshift table.

![Spark to Redshift](/assets/images/2023-06-10-Spark2Redshift/Spark2Redshift.jpg)

<!--more-->

------

* TOC
{:toc}
------

This example has run in the Jupyter Notebook. 

## Redshift

Configure the Redshift JDBC driver and Spark Redshift JDBC driver.

```python
%%configure -f
{
  "conf": {
    "spark.jars": "s3://<bucket>/jdbc/redshift-jdbc42-2.1.0.9.jar,s3://<bucket>/jdbc/spark-redshift.jar"
  }
}
```

As usual, create a Spark session

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

Create the Schema for the table.

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

The above schema is created for the us_retail_sales.csv[^1] file to read.

```python
df = spark.read.option("header", True).schema(tbl_retail_sales).csv("test1.csv")
# verify the schema
df.printSchema()
```

The most crucial step this post highlights is creating a table in the `<database>` specified above.

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

To read the Redshift table

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

## Postgres

Here is the code to insert data to Postgres:



```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
        .appName("connectToPostgres") \
        .enableHiveSupport() \
        .config("spark.jars", "/home/glue_user/workspace/jupyter_workspace/libs/postgresql-42.6.0.jar") \
        .getOrCreate()

from pyspark.sql.types import StructType, StructField, DateType, DecimalType, StringType
tbl_retail_sales = StructType([
    StructField("sales_month",DateType(),False),
    StructField("naics_code", StringType(), False),
    StructField("kind_of_business", StringType(), False),
    StructField("reason_for_null", StringType(), False),
    StructField("sales", DecimalType(8,2), False)
    ]
)

df = spark.read.option("header", True).schema(tbl_retail_sales).csv("retail_sales.csv")

df.write.format("jdbc") \
    .option("url", "jdbc:postgresql://postgres_db:5432/sales") \
    .option("dbtable", "public.retail_sales") \
    .option("user", "postgres") \
    .option("password", "ojitha") \
    .option("driver", "org.postgresql.Driver") \
    .mode('append').save()

spark.stop()
```



References:

[^1]: [SQL for Data Analysis](https://github.com/cathytanimura/sql_book/tree/master/Chapter%203:%20Time%20Series%20Analysis)
