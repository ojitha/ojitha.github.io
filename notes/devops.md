---
layout: notes 
title: DevOps
---
**Notes on DevOps**

* TOC
{:toc}

Here the important commands and information collected while programming. 

### AWS console

configure the AWS console (For the region  http://docs.aws.amazon.com/general/latest/gr/rande.html)

```bash
aws configure
```

Find all the running EC2 instances:

```bash
aws ec2 describe-instances
```

To find Instance Id

```bash
ec2 describe-instances | grep InstanceId
```

Terminate the instance 

```bash
aws ec2 terminate-instances --instance-id i-07fbd393a04fdd22c
```

### AWS KMS

```bash
#encrypt the password: InsightReadWrite
aws kms encrypt --key-id cfc7acf7-4f20-49c3-aa11-8be4cdc3291d --output text --query CiphertextBlob --plaintext InsightReadWrite

#encrypt the password: InsightReadWrite
aws kms encrypt --key-id cfc7acf7-4f20-49c3-aa11-8be4cdc3291d --plaintext fileb://test.txt --output text | base64 --decode > out.txt

#decrypt the password: InsightReadWrite
aws kms decrypt  --ciphertext-blob fileb://out.txt --output text --query Plaintext | base64 --decode
```

### AWS Kinesis

AWS Kinesis shows only example shows only one sequence. This is the record I found from the log with multiple sequences:

```json
{
    u 'Records': [{
        u 'eventVersion': u '1.0',
        u 'eventID': u 'shardId-000000000000:49559921416499955208897145459995453707469374714070171650',
        u 'kinesis': {
            u 'approximateArrivalTimestamp': 1502065218.908,
            u 'partitionKey': u 'TI2I7c',
            u 'data': u '<data1>',
            u 'kinesisSchemaVersion': u '1.0',
            u 'sequenceNumber': u '49559921416499955208897145459995453707469374714070171650'
        },
        u 'invokeIdentityArn': u 'arn:aws:iam::389920326251:role/Lambda-execution-role-Uat',
        u 'eventName': u 'aws:kinesis:record',
        u 'eventSourceARN': u 'arn:aws:kinesis:ap-southeast-2:389920326251:stream/ticketing-uat',
        u 'eventSource': u 'aws:kinesis',
        u 'awsRegion': u 'ap-southeast-2'
    }, {
        u 'eventVersion': u '1.0',
        u 'eventID': u 'shardId-000000000000:49559921416499955208897145459996662633288989343244877826',
        u 'kinesis': {
            u 'approximateArrivalTimestamp': 1502065218.908,
            u 'partitionKey': u 'ihwN32',
            u 'data': u '<data2>',
            u 'kinesisSchemaVersion': u '1.0',
            u 'sequenceNumber': u '49559921416499955208897145459996662633288989343244877826'
        },
        u 'invokeIdentityArn': u 'arn:aws:iam::389920326251:role/Lambda-execution-role-Uat',
        u 'eventName': u 'aws:kinesis:record',
        u 'eventSourceARN': u 'arn:aws:kinesis:ap-southeast-2:389920326251:stream/ticketing-uat',
        u 'eventSource': u 'aws:kinesis',
        u 'awsRegion': u 'ap-southeast-2'
    }, {
        u 'eventVersion': u '1.0',
        u 'eventID': u 'shardId-000000000000:49559921416499955208897145460000289410747833230768996354',
        u 'kinesis': {
            u 'approximateArrivalTimestamp': 1502065218.913,
            u 'partitionKey': u 'PoGyUG',
            u 'data': u 'H4sIAAAAAAAAAzMAACHf2/QBAAAA',
            u 'kinesisSchemaVersion': u '1.0',
            u 'sequenceNumber': u '<data3>'
        },
        u 'invokeIdentityArn': u 'arn:aws:iam::389920326251:role/Lambda-execution-role-Uat',
        u 'eventName': u 'aws:kinesis:record',
        u 'eventSourceARN': u 'arn:aws:kinesis:ap-southeast-2:389920326251:stream/ticketing-uat',
        u 'eventSource': u 'aws:kinesis',
        u 'awsRegion': u 'ap-southeast-2'
    }]
}
```

### AWS Chalice

Package first :

```bash
aws cloudformation package --template-file out/sam.json --s3-bucket ojemr --output-template-file pkg.yaml
```

Deploy :

```bash
aws cloudformation deploy --template-file /home/cloudera/dev/hellochalice/pkg.yaml --stack-name hellochalice --capabilities CAPABILITY_IAM
```

SQL Server

Login to the docker:

```bash
docker exec -i -t 8ae7c51a90fe /bin/bash
```

Create a new folder in the /var/opt/mssql

```bash
cd /var/opt/mssql/
mkdir backup
```

Download the AdventureWork from https://msftdbprodsamples.codeplex.com/downloads/get/880661 to your local machine and unzip.

```bash
docker cp AdventureWorks2014.bak 8ae7c51a90fe:/var/opt/mssql/backup
```

In your host machine use the sqlcmd

```bash
sqlcmd -S 127.0.0.1 -U SA -P '<password>'
```

Following the link https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-migrate-restore-database

Restore the backup file:

```bash
RESTORE DATABASE AdventureWorks
FROM DISK = '/var/opt/mssql/backup/AdventureWorks2014.bak'
WITH MOVE 'AdventureWorks2014_Data' TO '/var/opt/mssql/data/AdventureWorks2014_Data.mdf',
MOVE 'AdventureWorks2014_Log' TO '/var/opt/mssql/data/AdventureWorks2014_Log.ldf'
GO
```

How to start docker again

```bash
#find the container id
docker ps -a
#start that container id
docker start <container-id>
```
## Status Codes

- 1nn: informational
- 2nn: success
- 3nn: redirection
- 4nn: client errors
- 5nn: server errors

## 200 common

- 200 ok: everything ok
- 201 created: Returns a location header for new resources
- 202 Accepted: Server has accepted the request, but it is not yet complete.

## 400 common

- 400 Bad Request: Malformed Syntax, retry with change
- 401 Unauthorized: Authentication is required
- 403 Forbidded: Server has understood, but refuses request
- 404 Not Found: Server can't find a resource for URI
- 406 Incompatible: Incompatible Accept headers specified
- 409 Conflict: Resource conflicts with client request

## Dynamodb
Basic operations
List all the tables

```bash
aws dynamodb list-tables
```

describe a table found in the above command:

```bash
aws dynamodb describe-table --table-name <table name> 
```



<!--stackedit_data:
eyJoaXN0b3J5IjpbLTMyMjgwMzI5MiwtNTc0NzkxMzk3XX0=
-->