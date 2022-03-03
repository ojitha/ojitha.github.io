---
layout: post
title:  PySpark Date Exmple
date:   2022-03-02
categories: [Apache Spark]
---

PySpark date in string to date type conversion example. How you can use python sql functions like `datediff` to calculate the differences in days.

<!--more-->

``` python
from pyspark.sql import SparkSession
import findspark

findspark.init()


spark = SparkSession \
    .builder.appName("Releational operations") \
        .config("spark.sql.legacy.timeParserPolicy","LEGACY") \
    .getOrCreate()

sc = spark.sparkContext

# sel the log leve
sc.setLogLevel('ERROR')
```



Create a table with set of dates which are `StringType`:



``` python
from pyspark.sql import Row

MyDate = Row('name', 'a_date', 'b_date')
df = spark.createDataFrame([
    MyDate('A', '2021-02-10', '2021-06-10')
    , MyDate('B', '2021-02-11', '2022-02-11')
])
df.show()
```


    [Stage 0:>                                                          (0 + 1) / 1]



    +----+----------+----------+
    |name|    a_date|    b_date|
    +----+----------+----------+
    |   A|2021-02-10|2021-06-10|
    |   B|2021-02-11|2022-02-11|
    +----+----------+----------+



​                                                                                    




Display the data types and notice that both the columns(`a_date`,
`b_date`) are string type.



``` python
df.dtypes
```


    [('name', 'string'), ('a_date', 'string'), ('b_date', 'string')]




Now change the string type date columns to date type



``` python
from pyspark.sql.functions import to_date

df = df.withColumn('a_date', to_date('a_date','yyyy-MM-dd'))
df = df.withColumn('b_date', to_date('b_date','yyyy-MM-dd'))
df.dtypes
```


    [('name', 'string'), ('a_date', 'date'), ('b_date', 'date')]




``` python
df.show()
```


    +----+----------+----------+
    |name|    a_date|    b_date|
    +----+----------+----------+
    |   A|2021-02-10|2021-06-10|
    |   B|2021-02-11|2022-02-11|
    +----+----------+----------+




Find the days of differences between `b_date` and `a_date` and record
that results in the `date_diff` column.



``` python
from pyspark.sql.functions import col, datediff, current_date, abs

df.withColumn('date_diff', abs(datediff( col('b_date'), current_date() ))) \
    .filter(col('date_diff') > 2).show()
```


    +----+----------+----------+---------+
    |name|    a_date|    b_date|date_diff|
    +----+----------+----------+---------+
    |   A|2021-02-10|2021-06-10|      266|
    |   B|2021-02-11|2022-02-11|       20|
    +----+----------+----------+---------+




``` python
spark.stop()
```

