---
layout: notes 
title: RDBMS
mermaid: true
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

# Notes on Relational Databases
{:.no_toc}

---

* TOC
{:toc}

---
## H2 Database

For testing, use the following to run in the watch expression:

```bash
org.h2.tools.Server.startWebServer(this.jdbcTemplate.getDataSource().getConnection())
```

if you need to run in the browser(start browser: **java -cp h2-1.4.193.jar org.h2.tools.Console -web -browser**) use the **jdbc:h2:mem:dataSourc**e as connection url for Spring testing.


## MS SQL
Find all the tables where a column is exists:
```sql
SELECT      COLUMN_NAME AS 'ColumnName'
            ,TABLE_NAME AS  'TableName'
FROM        <database>.INFORMATION_SCHEMA.COLUMNS
WHERE       COLUMN_NAME = 'Contact_Id'
ORDER BY    TableName
            ,ColumnName;
```

## SQLite

This database is available on macOS. To run the simple Windows function:

```sql
SELECT value, FIRST_VALUE(value) over w,  LAST_VALUE(value) OVER w  FROM generate_series(1, 10, 1) WINDOW w AS (Range BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING);
```



## Athena

Create a table from a CSV file located in S3:

```sql
CREATE EXTERNAL TABLE exampletable (
  price int,
  address string,
  local_area string,
  zipcode int,
  beds int,
  baths int,
  sqft int,
  url string,
  state string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
LOCATION 's3://<bucket path to csv file>/diy/'
TBLPROPERTIES (
'classification' = 'csv',
'write.compression' = 'GZIP');
```



### Dates

Use the function `date_parse` to convert a formatted string to a timestamp:

```sql
select * from cte 
where date_parse("issue-date",'%Y%m%d') >  from_iso8601_date('2023-04-17') and date_parse("issue-date",'%Y%m%d') <  from_iso8601_date('2023-04-19')
and  "account-no" in (...) order by "account-no";
```

NOTE: The column `issue-date` is a string type.
In the above code, use the function from_iso8601_date to create a timestamp from the string.

### Athena to date example

```sql
select * from table1 
where  "Account ID" in ('1000','1100') 
and year(date_parse("my date/time", '%d/%m/%Y %H:%i:%s')) > 2021 
and month(date_parse("my date/time", '%d/%m/%Y %H:%i:%s')) = 7
order by "Account ID", ...
```

## Redshift

### Date 

functions:

```sql
-- Simple example
select convert_timezone('Australia/Sydney', TIMESTAMP '2023-04-18 06:05:00.170 UTC')

-- How to convert UTC current time to AU
select convert_timezone('Australia/Sydney', current_timestamp AT TIME ZONE 'UTC')

-- get month of the date
select date_part('month', convert_timezone('Australia/Sydney', current_timestamp AT TIME ZONE 'UTC'))
select dateadd('month',1,  current_timestamp AT TIME ZONE 'UTC')

-- get year only
select date_part('year',dateadd('month', 1, current_timestamp AT TIME ZONE 'UTC'))

-- create formatted string from the date
select to_char(current_timestamp AT TIME ZONE 'UTC', 'yyyymmdd')
```

In the following example, the field `issue-date` is varchar type. To convert varchar to date, use the `convert` function.

```sql
select * from "schema"."ViewOrTable"
where convert(TIMESTAMP ,"issue-date") >  date '2023-04-17' and convert(TIMESTAMP ,"issue-date") <  date '2023-04-19' 
```

### Redshift to date example

```sql
SELECT *  FROM table 
where  "Account ID" in (1000,1100) 
and DATE_PART_YEAR(TO_DATE("my date/time", 'dd/mm/yyyy HH24:MI:SS')) > 2021 
and DATE_PART(month, TO_DATE("my date/time", 'dd/mm/yyyy HH24:MI:SS')) = 7
order by "Account ID", ...
```

To truncate:

```
SELECT * FROM table 
where date_trunc('day', "x date") = DATE '2023-02-01';
```

### User handling

To see the user sessions:

```sql
select * from svv_transactions order by txn_start desc;
-- kill the pid
select pg_terminate_backend(1073955175);
```

You can find the users' grant roles

```sql
-- user grants
select * from svv_user_grants;
-- if you set the current session to a role 
set SESSION AUTHORIZATION ...
```

To find the [masking policies](https://www.youtube.com/watch?v=jXYoxRxEpOU)

```sql
-- all the masking policies
select * from svv_attached_masking_policy;
```

### Query optimisation
Find the latest query by the user

```sql
SELECT * from stl_query q where q.userid=102 order by q.starttime desc;
```
Or from the query column, you can find the query ID: 

```sql
select *
from svl_qlog
where userid = 102
order by query
desc limit 20;
```

After finding the query ID from the above, find the query summary details.

```sql
select * from SVL_QUERY_SUMMARY s 
where s.query = 42379953 order by s.maxtime desc;
```

or 

```sql
Select segment, step, event, solution from stl_alert_event_log where query in (	43052982,43055809,43055811) order by segment, step
```

### Redshift Windowing functions
If you run the example with the default window:

```sql
select sales
    , COUNT(sales) OVER ()
   , SUM(sales) OVER ()
FROM "retail_sales";
```
The following query generates the same result as the above result:

```sql
select sales
    , COUNT(sales) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING )
   , SUM(sales) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM "retail_sales";
```

Based on the above result, I realised the default is `(ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)` for Redshift. For Postgres, the default is (RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW). However, `RANGE` is not supported by the Redshift version I am using.

As I found from the following query, the upper bound default is `CURRENT ROW` (same as in Postgres):

```sql
select sales
    , COUNT(sales) OVER (ROWS CURRENT ROW )
   , SUM(sales) OVER (ROWS BETWEEN CURRENT ROW AND CURRENT ROW)
FROM "retail_sales";
```
Because `ROWS CURRENT ROW` generate the same result as `ROWS BETWEEN CURRENT ROW AND CURRENT ROW`.

### Redshift data sharing
You can create a view that spans Amazon Redshift and Redshift Spectrum external tables. With late-binding views, table binding occurs at runtime, providing your users and applications with seamless access to query data.

**Late-binding views**:

Allows you to drop and modify referenced tables without affecting the views. With this feature, you can query frequently accessed data in your Redshift cluster and less-frequently accessed data in S3, using a single view.

A **Datashare** is the unit of sharing data in Amazon Redshift. Use data shares in the same AWS account or in different AWS accounts. Datashare objects are objects from specific databases on a cluster that producer cluster administrators can add to share with data consumers. Datashare objects are read-only for data consumers. Examples of datashare objects are tables, views, UDFs and so on.

There are different types of datashare such as 
- Standard 
- Data Exchange
- Lakeformation Managed


## Query Optimisation

### Predicate Pushdown

### Partition Pruining

### Partition Projection

### Materialized views
For example, Amazon Redshift returns the precomputed results from the materialised view, without accessing the base tables at all, resulting in query results that are much faster than retrieving the same data from the base tables. You can define a materialised view using other materialised views. A materialised view plays the same role as a base table.

In Redshift, to update the data in the materialised view, users can use the REFRESH MATERIALIZED VIEW statement to refresh materialised views manually. Amazon Redshift provides a few ways to keep materialised views up to date for automatic rewriting: 

- Analysts can configure materialised views to refresh when the base tables of materialised views are updated. This autorefresh operation runs when cluster resources are available to minimise disruptions to other workloads.
- Users can schedule a materialised view refresh job by using the Amazon Redshift scheduler API and console integration.



### SPICE

## CDC

### Types of CDCs

There are two type, interst only and full:

| **Aspect**             | **Insert-only CDC **                                   | **Full CDC (with updates and deletes)**                      |
| ---------------------- | ------------------------------------------------------ | ------------------------------------------------------------ |
| **Common use cases**   | Suitable for append-only data, like logging            | Applies to dynamic datasets where records are modified or purged |
| **Data operations**    | Inserts only                                           | Involves inserts, updates, and deletes, requiring handling of existing records |
| **Performance impact** | Generally lower, optimized for insertions              | Higher, due to the additional steps required to locate and modify or delete existing records |
| **Data consistency**   | Straightforward to maintain because data is only added | More challenging to ensure consistency and integrity across transactions |
| **CDC method**         | Efficient capture of new entries.                      | Might require sophisticated methods to capture and replicate changes accurately, including transaction logs or triggers |
