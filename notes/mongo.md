---
layout: notes 
title: Mongo DB
mermaid: true
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

---

* TOC
{:toc}

---

How to tunnel to mongo db using ssh:

```bash
ssh -L 27017:localhost:27017 <user name>@<host>
```
### Queries
Here the important pattern of query collection.

#### Basic Queries from MongDb University

Array find **all**

```javascript
db.getCollection('movieDetails').find({genres: {$all: ['Comedy', 'Crime', 'Drama']}})
```

#### elemMatch

```json
/*
{
    "_id" : "Ojitha",
    "name" : "Ojitha Hewa",
    "addresses" : [ 
        {
            "street" : "321 Fake Street",
            "city" : "Epping",
            "state" : "NSW",
            "zip" : "2121"
        }, 
        {
            "street" : "5 Waterloo Rd",
            "city" : "Marsfield",
            "state" : "NSW",
            "zip" : "2120"
        }
    ]
}
*/

//elemMatch example
db.getCollection('embbeded').find(
    {addresses:{
        $elemMatch:{"state":"NSW",'zip':'2121', "street" : "321 Fake Street"}
        }
    }
)
```

#### Aggregates

Query to find duplicates

```json
db.users.aggregate(
    {$group : {
        _id : {un:{userName: '$userName'}, 
        accountType:{accountType:'$accountType'}},
        count : {$sum : 1}
    }},
    {$match: {
        count : {$gt: 1}
    }}
)
```

#### Updates

Here the way to insert array elements:

```javascript
db.getCollection('embbeded').updateOne({"_id":"joe"},
    {$push: 
                {testing: {test1: "test1", test2:"test2"}}
    }
)

//result is
/*
	...
	...
    "testing" : [ 
        {
            "test1" : "test1",
            "test2" : "test2"
        }
    ]
}
*/
```

Above same thing can be achieve through the 

```javascript
db.getCollection('embbeded').updateOne({"_id":"joe"},
    {$push: 
                {testing: {$each : [
                        {test1: "test1", test2:"test2"}
                    ]}}
    }
)
```

Add new values without overwriting:

```javascript
db.getCollection('embbeded').updateOne({"_id":"joe"},
    {$push: 
                {testing: {$each : [
                        {test3: "test3", test4:"test4"}
                    ], $slice: 2}}
    }
)

//result is
/*
	...
	...
   ],
    "testing" : [ 
        {
            "test1" : "test1",
            "test2" : "test2"
        }, 
        {
            "test3" : "test3",
            "test4" : "test4"
        }
    ]
}
*/
```

But if you want to push to the front of the array:

```javascript
db.getCollection('embbeded').updateOne({"_id":"joe"},
    {$push: 
                {testing: {$each : [
                        {test5: "test5", test6:"test6"}
                    ], $position:0, $slice: 2}}
    }
)

//result is
/*
	...
	...
   ],
    "testing" : [ 
        {
            "test5" : "test5",
            "test6" : "test6"
        }, 
        {
            "test1" : "test1",
            "test2" : "test2"
        }
    ]
}
*/
```

Here the query to update the multiple documents, multi: true

```json
db.users.update(
    {$and: [ {userNId: {$exists: true}},
        {$or: [
        {accType:'Facebook'}, {accType:'Google'}, {accType:'Twitter'}
        ]}
     ]},
    {$unset: {userNId: ''}},
    {multi: true}
)
```

In the above query, userNId has been removed from all the documents where userNId exist and accType is Facebook, Google or Twitter.

```json
db.getCollection('users').find({
    $and: [ {userNId: {$exists: false}},
        {$or: [
        {accType:'Facebook'}, {accType:'Google'}, {accType:'Twitter'}
        ]}
     ]
 })
```

Above query shows you the changes have done in the above multi update query.

Mongo Replica

```bash
screen -d -m -S mongo-rs1 mongod --port 27017 --dbpath ~/mongo/data-rs1 --replSet rs0 --smallfiles --oplogSize 128 --logpath ~/mongo/logs/mongo-rs1.log
screen -d -m -S mongo-rs2 mongod --port 27018 --dbpath ~/mongo/data-rs2 --replSet rs0 --smallfiles --oplogSize 128 --logpath ~/mongo/logs/mongo-rs2.log
screen -d -m -S mongo-rs3 mongod --port 27019 --dbpath ~/mongo/data-rs3 --replSet rs0 --smallfiles --oplogSize 128 --logpath ~/mongo/logs/mongo-rs3.log

```

### Date offset for Australia:

It is important to find the proper date based on the offset in the mongo, for example consider the following dates ISODate("2016-08-31T03:49:13.857Z") <—> ISODate("2016-08-31T13:49:13.857Z")

```javascript
#to get the AU morning
var auDate = ISODate("2016-08-31T13:49:13.857Z") 
isoDate = new Date(date - (+600 * 60000))

#to get the AU date
var date = ISODate("2016-08-31T03:49:13.857Z") 
auDate = new Date(date - (-600 * 60000))
```

For example, beginning of the day

```javascript
var date = ISODate("2016-08-31T00:00:00.000Z") 
new Date(date - (+600 * 60000))
# ISODate("2016-08-30T14:00:00Z")
```

Run the following code to get the current Date and time

```javascript
var date = new Date()
db.getCollection('Orderlines').insert({"_id":"mytest",d:date})
db.getCollection('Orderlines').find({"_id":"mytest"})
```

or run

```javascript
var date = new ISODate()
```

Mongoldb oplog time stamp query

```javascript
var date = new ISODate()
db.getCollection('oplog.rs').find({
    ts: {$gt : date}, ns: 'OrdersTest.Orderlines',
    $or: [ {op:'i'}, {op: 'u'}]
}).limit(2)
```

#### Find the docs who has a field

It is sometimes important to find the all users who has particular key

```json
db.getCollection(<collection>).find({<target-field>:{$exists: true}})
```

####Update field of array
for example, Person document has addresses field and it is is an array of addresses: street is the first element. To convert all the street names to uppercase:

```javascript
db.getCollection(<collection>).find({<criteria>}).forEach(function(e){
    for ( i = 0; i < e.addresses.length ;i++){
        e.addresses[i].street=e.addresses[i].street.toUpperCase();
    }
    //save to the collection
    db.<collection>.save(e)

})
```

Update with the $pull:

```json
db.getCollection('Orderlines').update(
    {'_id':{$in: ['20161019,42121,2','20161109,39661,2','20161019,38036,2', '583ba80a09edaa2fc0d8ba61,1', '20161017,29051,9,cp']}},
    {$pull: {orderlineItems: {'fees.typeName':'test'}}},
    {multi: true}
)
```

### Backup

How to dump the backup and restore from the remote mong server ? Here you have to follow the three steps

1. First create a tunnel to the remote mongo server

```bash
   ssh -L 27018:<remote server>:27017 <username>@<remote server>
```

   Here the port 27018 fro the local machine. This port is map to the <remote server>:27017. 

2. dump the collection to the directory

   ```bash
   /usr/bin/mongodump --host localhost --port 27018  -u <mongodb user name> -p <mongodb password> -d <database> -c <mongo collection> -o <directory>	
   ```

   as  shown in the above  you have to provide the remote mongo server username/password, datatbase and the collection.

3. Now restore the backup

   ```bash
   /usr/bin/mongorestore --host 127.0.0.1 --port 27017 --db <database> --drop <directory>/user-admin
   ```

   backup and restore is completed.

#### Find the type of the field
Here the way to find the type of the field in the mongodb

```javascript
 db.users.find({userName:'oj_1'}).forEach( function(e) { return print(typeof(e.password)); } );
```
