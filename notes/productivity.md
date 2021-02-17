---
layout: notes
title: Productivity Tools
---
<script src="https://unpkg.com/mermaid@8.0.0/dist/mermaid.min.js"></script>

**Notes on Productivity tools**

* TOC
{:toc}

## Blog tools
I was very enthustic to know markdown level diagraming.

### mermaid
One of the best so far found is [mermaid](https://mermaid-js.github.io/mermaid/#/) which I cause use with the my blog tool stackedit.io. For example:

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
to deactivate, `deactivate` in the CLI to move out from the project environment. For more information see the post "[How to run python GUI in MacOS]({% link _posts/2020-11-07-python-gui-mac.md %})" for macOs.

## Spark

I have configured Spark using SDKMAN. 

- [Building Spark JAR Files with SBT](https://mungingdata.com/apache-spark/building-jar-sbt/)
- [Setting up a Spark Development Environment with Scala](https://www.cloudera.com/tutorials/setting-up-a-spark-development-environment-with-scala/.html)

