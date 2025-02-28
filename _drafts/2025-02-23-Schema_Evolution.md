---
layout: post
title:  Schema Evolution
date:   2025-02-23
categories: [Modelling]
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

TBC

<!--more-->

------

* TOC
{:toc}
------

## Introduction {#intro}
Schema evolutions are inevitable in OLAP. Various tools exist to allow this type of schema change without database downtime[^1]. However, it is operationally challenging to maintain backward compatibility. 

## AVRO

To decode data, use two schemas: the writer's schema and the reader's schema, which may differ. If the writer and reader schemas are the same, decoding is easy. Otherwise, Avro resolves the differences by looking at the writer's schema into the readers's schema[^2].

<p style="background-color:#fff6e4; padding:15px; border-width:3px; border-color:#f5ecda; border-style:solid; border-radius:6px"> 📝 <b>Note: </b> Different orders in the schemas don't matter, because schema resolution is based on the field names.<br/>
When reading fields that should be in the writer's schema but are not provided, even though they are included in the reader's schema, they are populated with a default value specified in the reader’s schema. 
</p>

| Writer's Schema | Readers Schema | Compatibility |
| --------------- | -------------- | ------------- |
| New version     | old version    | Forward       |
| Old version     | New version    | Backword      |
|                 |                |               |






```json
// Example of adding a field with a default value
schema = new Schema.Parser().parse("{\"type\":\"record\",\"name\":\"Example\",\"fields\":[{\"name\":\"f1\",\"type\":\"string\"},{\"name\":\"f2\",\"type\":\"int\",\"default\":0}]}");
```

### Dynamic Generated Schemas

Avro's approach to schema evolution is more flexible. Avro's schema evolution is helpful in scenarios where the database schema changes and a new Avro schema can be generated from the updated database schema.

```python
#generating an Avro schema from a database schema
import avro.schema

database_schema = [{"name": "column1", "type": "string"}, {"name": "column2", "type": "int"}]

avro_schema = {"type": "record", "name": "Example", "fields": []}
for column in database_schema:
    avro_schema["fields"].append({"name": column["name"], "type": column["type"]})
schema = avro.schema.Parse(json.dumps(avro_schema))
```

## Parquet

Parquet stores data in a columnar format, enabling efficient compression (including Snappy, LZO, Gzip, and LZ4) and encoding techniques and improving query performance. Parquet uses a hierarchical schema representation, allowing for complex and nested data structures, ideal for storing and querying complex data.

Schema evolution in Parquet is a crucial feature that allows users to modify the schema of a dataset without rewriting the entire dataset. Parquet stores the schema, and its design enables evolvability. Thus, multiple Parquet files with different but compatible schemas can evolve the schema.

How to use schema evolution in Parquet:

```python
# read a Parquet file with schema evolution
df = spark.read.option("mergeSchema", "true").parquet("path_to_parquet_file")

# write a Parquet file with schema evolution
df.write.option("mergeSchema", "true").parquet("path_to_parquet_file")
```

Parquet's advantages include its ability to support schema evolution and its efficient compression and encoding techniques: [See Orielly Question][q1]{:target="_blank"}.

## Delta Lake

Developers can easily use schema evolution to add new columns previously rejected due to a schema mismatch. Schema evolution is activated by adding ` .option('mergeSchema', 'true')` to your `.write` or `.writeStream` Spark command.

```
# Add the mergeSchema option
loans.write.format("delta") \
           .option("mergeSchema", "true") \
           .mode("append") \
           .save(DELTALAKE_SILVER_PATH)
```

As stated in the Databricks[^4],the following types of schema changes are eligible for schema evolution during table appends or overwrites:

- <u>Adding new columns</u> (this is the most common scenario)
- <u>Changing of data types</u> 
    - from `NullType ->` any other type, or 
    - upcasts from `ByteType -> ShortType -> IntegerType`{:.language-python}

<span style="color:red">Other changes, which are not eligible for schema evolution</span>, require that the **schema and data** are overwritten by adding `.option("overwriteSchema", "true")`. For example, if the column "Foo" was originally an `integer` data type and the new schema would be a `String` data type, then all of the Parquet (data) files would need to be re-written. Those changes include:

- Dropping a column
- Changing an existing column's data type (in place)
- Renaming column names that differ only by case (e.g. "Foo" and "foo")

## Schema Registry

The AWS Glue Schema Registry[^5] is a centralised repository for managing and enforcing data stream schemas. It offers several key benefits for AWS users:

1. Centralised schema management: It provides a single location to store, version, and manage schemas for various data streams.

2. Schema evolution support: The registry allows schemas to change over time while maintaining compatibility with previous versions.

3. Integration with AWS services: It seamlessly integrates with services like Amazon Kinesis Data Streams, Amazon Managed Streaming for Apache Kafka (MSK), and AWS Glue.

4. Improved data quality: Enforcing schemas helps ensure data consistency and reduce errors in data processing pipelines.

5. Serialisation and deserialisation: The registry provides libraries for serialising and deserialising data according to the registered schemas.

To use the AWS Glue Schema Registry, you can:

- Create a registry using the AWS Glue console, AWS CLI, or SDKs.
- Register schemas manually or enable auto-registration for supported services.
- Integrate the registry with your data producers and consumers using the provided **SerDe** libraries.
- Use the registry with other AWS services like **AWS Glue Data Catalog**[^6] for comprehensive data management.



***

[^1]:[3. Data Models and Query Languages,  Designing Data-Intensive Applications, 2nd Edition](https://learning.oreilly.com/library/view/designing-data-intensive-applications/9781098119058/ch03.html)

[^2]:[Schema evolution in Avro, Protocol Buffers and Thrift — Martin Kleppmann’s blog](https://martin.kleppmann.com/2012/12/05/schema-evolution-in-avro-protocol-buffers-thrift.html)

[^4]: [Schema Evolution & Enforcement on Delta Lake - Databricks](https://www.databricks.com/blog/2019/09/24/diving-into-delta-lake-schema-enforcement-evolution.html)

[^5]: [How the schema registry works](https://docs.aws.amazon.com/glue/latest/dg/schema-registry-works.html)

[^6]: [AWS Glue Schema registry - AWS Glue](https://docs.aws.amazon.com/glue/latest/dg/schema-registry.html)

[q1]: https://learning.oreilly.com/answers2/?questionId=d24e503c-4713-4e4a-b9e3-2b0aed406a37 "Orielly Question"
