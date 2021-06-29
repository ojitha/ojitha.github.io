---
layout: post
title:  Jenkins in Docker Container
date:   2021-06-28
categories: [CI/CD]
---

This is the source code to create a Jenkins Docker container.

<!--more-->

In your root folder create a sub folder name say `jenkins`. All the docker specific files, can be kept in this folder. Your git repositories you can create under the root directory where Jenkinsfile is exists.

![image-20210629194310446](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20210629194310446.png)

As shown in the above screenshot, you have to have docker-compose.yml file:

```yaml
version: "3.7"

services:
  jenkins:
    image: ojitha/pipelines-jenkins:29.06.2021
    ports:
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    build:
      context: ./29.06.2021
```

you can find Jenkins specific configuration in the `29.06.2021` which was created based in the date.

The Dockerfile is as follows:

```dockerfile
FROM alpine:3.11 AS installer

ARG JENKINS_VERSION="2.289.1"

RUN apk add --no-cache curl
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community docker-cli
RUN curl -SL -o jenkins.war http://mirrors.jenkins.io/war-stable/$JENKINS_VERSION/jenkins.war

# Jenkins
FROM alpine:3.11

# jenkins deps
RUN apk add --no-cache \
    bash \
    coreutils \
    git \
    openjdk11 \
    openssh-client \
    ttf-dejavu \
    unzip 

# compose deps
RUN apk add --no-cache \
    gcc \
    libc-dev \
    libffi-dev \
    make \
    openssl-dev \
    python-dev \
    py-pip

RUN pip install --upgrade pip 
RUN pip install docker-compose

ARG JENKINS_VERSION="2.289.1"
ENV JENKINS_VERSION=${JENKINS_VERSION} \
    JENKINS_HOME="/data"

VOLUME ${JENKINS_HOME}

EXPOSE 8080
ENTRYPOINT java -Duser.home=${JENKINS_HOME} -Djenkins.install.runSetupWizard=false -jar /jenkins/jenkins.war

COPY --from=installer /usr/bin/docker /usr/bin/docker
COPY --from=installer /jenkins.war /jenkins/jenkins.war

COPY ./jenkins.install.UpgradeWizard.state ${JENKINS_HOME}/
COPY ./scripts/ ${JENKINS_HOME}/init.groovy.d/
```

The `jenkins.install.UpgradeWizard.state` file contains:

```
2.0
```

Jenkins admin and plugin configurations are in the `scripts` folder. Here the `admin.groovy`:

```groovy
#!groovy
import jenkins.install.*;
import jenkins.model.*
import jenkins.security.s2m.AdminWhitelistRule
import hudson.security.*
import hudson.util.*;

def instance = Jenkins.getInstance()

def username = "ojitha"
def password = "ojitha"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(username, password)
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
instance.save()

Jenkins.instance.getInjector().getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)
```

Here the `install-plugins.groovy`:

```groovy
#!groovy
import jenkins.model.Jenkins;

pm = Jenkins.instance.pluginManager
uc = Jenkins.instance.updateCenter

pm.doCheckUpdatesServer()

["git", "workflow-aggregator", "blueocean"].each {
    if (! pm.getPlugin(it)) {
    deployment = uc.getPlugin(it).deploy(true)
    deployment.get()
    }
}
```



To create container, run the following command in the parent directory level:

```bash
docker-compose -f jenkins/docker-compose.yml up -d
```

you can access Jenkins via http://localhost:8080 using user/pass ojitha/ojitha.

If you want to remove the container:

```bash
docker-compose -f jenkins/docker-compose.yml down
```

This source was written following a course[^1] (author's blog is https://blog.sixeyed.com) and modified to work with latest version of Jenkins.

[^1]: [Using Declarative Jenkins Pipelines](https://pluralsight.pxf.io/DPOAj) 



