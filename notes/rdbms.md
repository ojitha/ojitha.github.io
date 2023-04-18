---
layout: notes 
title: RDBMS
---
**Notes on Relational Databases**

* TOC
{:toc}

## H2 Database

For testing use the following to run in the watch expression:

```bash
org.h2.tools.Server.startWebServer(this.jdbcTemplate.getDataSource().getConnection())
```

if you need to run in the browser(start browser: **java -cp h2-1.4.193.jar org.h2.tools.Console -web -browser**) use the **jdbc:h2:mem:dataSourc**e as connection url for Spring testing.


## MS SQL
Find all the tables where column is exists:
```sql
SELECT      COLUMN_NAME AS 'ColumnName'
            ,TABLE_NAME AS  'TableName'
FROM        <database>.INFORMATION_SCHEMA.COLUMNS
WHERE       COLUMN_NAME = 'Contact_Id'
ORDER BY    TableName
            ,ColumnName;
```

## Athena

### Dates

Use the function `date_parse` to convert formated string to time stamp:

```sql
select * from cte 
where date_parse("issue-date",'%Y%m%d') >  from_iso8601_date('2023-04-17') and date_parse("issue-date",'%Y%m%d') <  from_iso8601_date('2023-04-19')
and  "account-no" in (...) order by "account-no";
```

NOTE: The column `issue-date` is a string type.
In the above code use the function `from_iso8601_date` to create timestamp from the string.

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