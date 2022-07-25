---
layout: post
title:  Glue Development using Jupyter
date:   2022-04-08
categories: [AWS, Glue, Jupyter]
---

If you want to create Glue job using vscode, you can create glue job using jupyter. In addition to that vscode support of Jupyter notebook will help to do more rapid development.

<!--more-->


## Docker based environment
First you have to Docker on Amazon Linux to as explained in the [install](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install-linux.html). 

to start the docker service
```bash
sudo service docker start
```

Create a docker instance based on the Glue 3:

```bash
docker run -it -v ~/.aws:/home/glue_user/.aws -v "$(pwd)":/home/glue_user/workspace/jupyter_workspace/ -e AWS_PROFILE=$PROFILE_NAME -e DISABLE_SSL=true --rm -p 4040:4040 -p 8888:8888 --name glue_pyspark amazon/aws-glue-libs:glue_libs_3.0.0_image_01
```
This will take you to the container bash shell.

In the container bash prompt, if you want _optionally_ install any library before use any notebook. For eample, pyathena to access AWS Athena:

```bash
pip3 install pyathena
```

It is **requred** to start the livy server. Run the following command in the container bash shell prompt:

```bash
livy-server start
```

and run the notebook

```bash
jupyter lab --no-browser --ip=0.0.0.0 --allow-root --ServerApp.root_dir=/home/glue_user/workspace/jupyter_workspace/ --ServerApp.token='pyspark' --ServerApp.password=''
```

## Notebook for JDBC access
You have to specify the JDBC driver file in the Jupyter before access:

```python
%%configure -f
{"conf": {
    "spark.jars": "s3://<s3-bucket>/jdbc/AthenaJDBC42.jar"
    }
}   
```

Create a glue context:

```python
from awsglue.job import Job
from awsglue.context import GlueContext

glueContext = GlueContext(spark)
```

Create a database JDBC connection

```python
from datetime import datetime
con = (
    glueContext.read.format("jdbc")
    .option("driver", "com.simba.athena.jdbc.Driver")
    .option("AwsCredentialsProviderClass","com.simba.athena.amazonaws.auth.InstanceProfileCredentialsProvider")
    .option("url", "jdbc:awsathena://athena.ap-southeast-2.amazonaws.com:443")
    .option("S3OutputLocation","s3://{}/temp/{}".format('<s3 bucket>', datetime.now().strftime("%m%d%y%H%M%S")))
 )
```

Create spark datataframe from the JDBC executing SQL specified in the `query` variable:

```python
glue_df = con.option('query', query).load()
glue_df.show(10)
```

## Using pyathena

Create a coursor
```python
from pyathena import connect
cursor = connect(s3_staging_dir="s3://<s3-bucket>/temp/",
                 region_name="ap-southeast-2").cursor()
```

Execute the coursor and get the result set:
```python
cursor.execute(query)
print(cursor.description)
```

Load the data to dataframe
```python
import pandas as pd
from pyathena.pandas.util import as_pandas
df = as_pandas(cursor)
df
```

NOTE:
You have to have proper service policies configure with your EC2.
