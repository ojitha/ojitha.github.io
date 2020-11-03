---
layout: post
title: "Python run on containers"
date:   2020-10-20 20:01:30 +1000
categories: [Python, Docker]
---

We have alrady explain [Website hosted as a container](https://ojitha.github.io/blog/2020/10/03/Website-hosted-as-container.html). In this post explained how to host flask web application.

<!--more-->

Suppose your main python application, Dockerfile, Runfile and requirments.txt in the same folder.



```bash
tree <folder>
```

For example suppose you need to create Flask application, the your requriements.txt:

```
flask
```

The Runfile to run the flask

```
web: flask run --host 0.0.0.0
```

The main application is:

```python
from flask import Flask

app = Flask(__name__)


@app.route('/')
def hello_world():
    return 'Hello, Ojitha!'
```

Here the Dockerfile:

```dockerfile
FROM python:3.8.5
WORKDIR /src
RUN pip install flask
COPY app.py .
EXPOSE 5000
CMD ["flask", "run", "--host", "0.0.0.0"]
```

We are using the python version 3.8.5 image. The app working directory in the container is `src`. In addition to that expose port 5000.

build the image:

```bash
docker build -t localhost:5001/ojflaskimage .
```

Now run the docker container

```bash
ocker run -d -p 5000:5000 --name=ojflaskapp localhost:5001/ojflaskimage
```

now test with

```bash
curl http://localhost:5000
```
