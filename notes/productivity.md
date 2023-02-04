---
layout: notes
title: Productivity Tools
mermaid: true
---


**Notes on Productivity tools**

* TOC
{:toc}

## Blog tools
I was very enthustic to know markdown level diagraming.

### Mermaid
One of the best so far found is [mermaid](https://mermaid-js.github.io/mermaid/#/) which I have used with the my blog tool stackedit.io. For example:

<div class="mermaid">
graph TD;
    A-->B;
    A-->C;
    B-->D;
    C-->D;
</div>
such a great diagraming.

### asciinema

The tool [asciinema](https://asciinema.org) record your terminal and upload to cloud. You can [install](https://asciinema.org/docs/installation) this tool using `brew` in the MacOS.

## XML
Tools for XML
## Python
To setup complete python environment, see the [Python my workflow](https://ojitha.blogspot.com/2020/09/python-my-workflow.html).
To fond the python directories in the `PYTHONPATH`:

```python
import sys
import pprint from pprint
pprint(sys.path)
```

### Atom editor for Spark

First set the following path:

```bash
export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip
```

I have used SDK MAN to install the spark home.

Now create virtual environment

```bash
pyenv global 2.7.18
virtualenv mypython
source bin/activate
python -m pip install --upgrade pip
```

In the virtual enviroment, install

```bash
pip install ipykernel
```

Then run the following, if above is not working.

```bash
python -m ipykernel install --user --name=env
```

You can open in Atom editor and do the inline debugging, if you install [hydrogen](https://atom.io/packages/hydrogen) in the editor.

If you want to use PySpark, first install

```bash
pip install pyspark
```

To find the installed pyspark version:

```bash
pip show pyspark
```

If you want, install the following packages to Atom editor:

- Script (to execute python from IDE, CMD+i)
- autocomplete-python
- flake 8 (to enable `pip install flake8`)
- python-autopep8

### Diff

Here the way to semantically diff the XML files:
First create your project in Python virtual enviroment:
```bash
python3 -m venv xmltest
cd xmltest
source bin/activate
```
You project is `xmltest`. Now install the graphtage packate
```bash
pip install graphtage
```
now you are ready to compare m1.xml and p1.xml files:
```bash
graphtage p1.xml m1.xml
```
This will give you a out put to CLI.
to deactivate, `deactivate` in the CLI to move out from the project environment. 

## Spark

I have configured Spark using SDKMAN.

- [Building Spark JAR Files with SBT](https://mungingdata.com/apache-spark/building-jar-sbt/)
- [Setting up a Spark Development Environment with Scala](https://www.cloudera.com/tutorials/setting-up-a-spark-development-environment-with-scala/.html)

```bash
docker run --name pyspark -e JUPYTER_ENABLE_LAB=yes -e JUPYTER_TOKEN="pyspark"  -v "$(pwd)":/home/jovyan/work -p 8888:8888 jupyter/pyspark-notebook:d4cbf2f80a2a
```

Use the http://localhost:8888/?token=pyspark to open the jupyter notebook.

To run the Zeppelin:

```bash
docker run -u $(id -u) -p 8080:8080 -p 4040:4040 --rm -v $PWD/logs:/logs -v $PWD/:/notebook -e ZEPPELIN_LOG_DIR='/logs' -e ZEPPELIN_NOTEBOOK_DIR='/notebook' --name zeppelin apache/zeppelin:0.10.0
```

Command to create Apache Airflow

```bash
docker run -ti -p 8080:8080 -v ${PWD}/<dag>.py:/opt/airflow/dags/download_rocket_launches.py --name airflow --entrypoint=/bin/bash apache/airflow:2.0.0-python3.8 -c '( airflow db init && airflow users create --username admin --password admin --firstname Anonymous --lastname Admin --role Admin --email ojithak@gmail.com); airflow webserver & airflow scheduler'
```

## Docker Databases containers

### Postgres

Create docker image: (In the current directory, create a `data` folder)

```bash
docker run -t -i \
    --name Mastering-postgres \
    --rm \
    -p 5432:5432 \
    -e POSTGRES_PASSWORD=ojitha \
    -v "$(pwd)/data":/var/lib/postgresql/data \
    postgres:13.4
```

Docker to access psql:

```bash
docker exec -it Mastering-postgres bash
```

Inside the bash run the following command to get into the `psql`:

```bash
psql -h localhost -p 5432 -U postgres
```

### MSSQL

Pull the image

```powershell
docker pull mcr.microsoft.com/mssql/server:2019-latest
```

to run

```powershell
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Pwd@2023" `
   -p 1433:1433 --name sql1 --hostname sql1 `
   -v C:\Users\ojitha\dev\mssql\data:/var/opt/mssql/data `
   -v C:\Users\ojitha\dev\mssql\log:/var/opt/mssql/log `
   -d `
   mcr.microsoft.com/mssql/server:2019-latest
```

Download the sample database from the [backup](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms)

Run the following fix before restore

```powershell
docker container exec sql1 touch /var/opt/mssql/data/AdventureWorks2019.mdf
docker container exec sql1 touch /var/opt/mssql/log/AdventureWorks2019_log.ldf
```

## Jekylle

To start Jekylle

```bash
bundle exec jekyll serve
```

## Quarto

[Quarto](https://quarto.org) is based on the [pandoc](https://pandoc.org/MANUAL.html#option--reference-doc). Here the workflow to include Jupyter notebook in [Jekyll](https://jekyllrb.com/docs/posts/) site.

1. Frirst create Jupyter notebook in the vscode and include the yaml in the raw form.

    ```yaml
    ---
    title: PySpark Date Example
    format:
        html:
            code-fold: true
    jupyter: python3        
    ---
    ```

    

2. now copy the `ipynb` to temp directory

3. now run the following command 

    ```bash
    quarto render pyspark_date_example.ipynb --to html
    ```

    

4. copy both of the generated folder and the html file to `<jekyll root>/_include` foler.

5. remove the `<!DOCTYPE html>` first statement from the HTML page

6. And add the post such as

    ```
    ---
    layout: post
    title:  PySpark Date Exmple
    date:   2022-03-02
    categories: [Apache Spark]
    ---
    
    PySpark date in string to date type conversion example. How you can use python sql functions like `datediff` to calculate the differences in days.
    
    <!--more-->
    
    -- include pyspark_date_example.html using liquid --
    ```

    As shown in the line# 12 embed the html file to post. 

7. Now run the Jekyll if not started

## 
