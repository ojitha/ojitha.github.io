---
layout: post
title: "Website hosted as a container"
date:   2020-10-03 13:01:30 +1000
categories: [blog]
excerpt_separator: <!--more-->
---

This is very short tutorial to show how to quickly create a web server using Docker container. The Docker should be installed in your machine as a prerequesit.

<!--more-->

First step is to create `Dockerfile`:

```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
```

The based image is `nginx:alpine` and copy the content of your current directory to the nginx/html directory. For example, index.html with the following text:

```html
<h1>Hello Ojitha</h1>
```

Now you have to run the Docker CLI command for the second step to create a docker image:

```bash
docker build -t <build-directory>
```

the paramter for `t` to tag the image: for example web-img:v1 (repository:version)

when you run the following command, you can find all the images available

```bash
docker images
```

Third step is to launch the docker image.

```bash
docker run -d -p 80:80 web-img:v1
```

