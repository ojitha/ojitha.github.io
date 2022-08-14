---
layout: post
title:  AWS Glue run locally
date:   2022-08-13
categories: [AWS]
---

This blog explains how to create an AWS Glue container to develop PySpark scripts locally. I've already explained how to run the Glue locally using [Glue Development using Jupyter]({% post_url 2022-07-11-Glue development using Jupyter %}).

<!--more-->

You have to create start.sh and both the Dockerfile and the docker-compose.yml file in the same directory for this blog:

## Docker file

Here the Dockerfile:

```dockerfile
FROM amazon/aws-glue-libs:glue_libs_3.0.0_image_01
WORKDIR /home/glue_user/workspace/jupyter_workspace
ENV DISABLE_SSL=true
RUN pip3 install pyathena
CMD [ "./start.sh" ]
```

You can install any Python libraries as shown in the line #4.

You have to have start.sh which start the Jupyter:

```bash
livy-server start
jupyter lab --no-browser --ip=0.0.0.0 --allow-root --ServerApp.root_dir=/home/glue_user/workspace/jupyter_workspace/ --ServerApp.token='pyspark' --ServerApp.password=''
```



## Docker compose file

Here the docker-compose.yaml:

```dockerfile
version: '3.9'
services:
  aws_glue:
    build: .
    volumes:
      - .:/home/glue_user/workspace/jupyter_workspace
    privileged: true
    ports:
      - 8888:8888
      - 4040:4040
```



## Run

To run the docker:

```bash
docker compose -up
```

If you are using vscode, first you have to specify the Jupyter server connection: 

![Jupyter Server Connection](/assets/images/2022-08-13-AWS-Glue-run-locally/image-20220814152406318.png)

and specify the remote server URL (http://localhost:8888/?token=pyspark):

![Jupyter remote server URL](/assets/images/2022-08-13-AWS-Glue-run-locally/image-20220814152542162.png)

In the command pallet, select `Create: New Jupyter Notebook"`. 

![Connect to remote docker glue server](/assets/images/2022-08-13-AWS-Glue-run-locally/image-20220814153055371.png)

In the notebook select the `Glue Spark - Local (PySpark) (Remote) Jupyter Kernal`. In the above Dockerfile, because you install the PyAthena, it should be possible to `import pyathena` as a test.

You can use the http://localhost:4040 to access the SparkUI.