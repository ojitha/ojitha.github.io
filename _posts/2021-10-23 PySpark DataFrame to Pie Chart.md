---
layout: post
title:  PySpark Data Frame to Pie Chart
date:   2021-10-23
categories: [Apache Spark]
---

I am sharing a Jupyter notebook. This shows:
1. Access to PostgreSQL database connection
2. How to draw Pie Chart 
3. SQL shows common table expression



```python
from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("Postgres Connection") \
    .config("spark.jars", # add the PostgresSQL jdbc driver jar
            "/home/jovyan/work/extlibs/postgresql-9.4.1207.jar").getOrCreate()
```


```python
db_name = 'dvdrental'
sql = """
WITH first_orders AS (
	SELECT * FROM (
			SELECT p.payment_id
			, p.customer_id
			, p.payment_date
			, p.rental_id
			, p.amount
			, row_number() over (PARTITION BY p.customer_id ORDER BY p.payment_date) as rn
		FROM payment p) t WHERE t.rn =1  
), 
summary AS (SELECT * 
FROM first_orders fo 
	JOIN rental r ON r.rental_id = fo.rental_id
	JOIN inventory i ON i.inventory_id = r.inventory_id
	JOIN film f ON f.film_id = i.film_id
)				 

SELECT s.rating, SUM(s.amount) 
FROM summary s GROUP BY s.rating 
"""
db_props = {"user":"postgres","password":"ojitha","driver":"org.postgresql.Driver"}
```


```python
df1 = spark.read.jdbc(url="jdbc:postgresql://Mastering-postgres:5432/%s" % db_name, 
    table='(%s) as foo' % sql, # SQL query to create dataframe
    properties= db_props)
```


```python
df1.show(6)
```

    +------+--------------------+
    |rating|                 sum|
    +------+--------------------+
    |     G|407.0800000000000...|
    |    PG|480.8500000000000...|
    | PG-13|549.6200000000000...|
    |     R|489.7400000000000...|
    | NC-17|495.7200000000000...|
    +------+--------------------+




```python
#define data
df = df1.toPandas()
```


```python
import matplotlib.pyplot as plt

fig = plt.pie(df['sum'], labels=df['rating'])
plt.title('DVD rental revenue on ratings')
plt.show()             
```


![2021-10-23 PySpark DataFrame to Pie Chart_5_0](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/2021-10-23%2520PySpark%2520DataFrame%2520to%2520Pie%2520Chart_5_0.png)
    



```python
spark.stop()
```
