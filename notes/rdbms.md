---
layout: notes 
title: RDBMS
---

**Notes on Relational Databases**

* TOC
{:toc}

### H2 Database

For testing use the following to run in the watch expression:

```bash
org.h2.tools.Server.startWebServer(this.jdbcTemplate.getDataSource().getConnection())
```

if you need to run in the browser(start browser: **java -cp h2-1.4.193.jar org.h2.tools.Console -web -browser**) use the **jdbc:h2:mem:dataSourc**e as connection url for Spring testing.

##Tomcat

Configure the tomcat for CAS

```xml
    <Connector port="8443" 
	   protocol="org.apache.coyote.http11.Http11NioProtocol" 
	   SSLEnabled="true"
           maxThreads="150" scheme="https" secure="true"
           clientAuth="false" sslProtocol="TLS"
	   allowTrace="true" 
    	   keystoreFile="conf/abc-keys/keystore.jks" 
    	   keystorePass="<key-password>" 
    	   truststoreFile="conf/abc-keys/truststore.jks"
    	   URIEncoding="UTF-8" useBodyEncodingForURI="true"/>
```

Add the above code to the server.xml file before the `<Connector port="8009" protocol...` statement.

Install apahce web server

```bash
sudo yum install httpd -y
```

Start the service

```bash
sudo service httpd start
```

Configure to start every time:

```bash
sudo chkconfig httpd on
```

Show the disk volumes

```bash
lsblk
```

check the data in the volume:

```bash
sudo file -s /dev/xvdf
```

format the before mount the volume:

```bash
sudo mkfs -t ext4 /dev/xvdf
```

Now mount the volume:

```bash
#first create myfileserver
cd /
sudo mkdir myfileserver

#then mount
sudo mount /dev/xvdf /myfileserver
```

Unmount as a root:

```bash
umount /dev/xvdf
```

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
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTczOTYxNDk0MSwtNTc3MDg5OTc2XX0=
-->