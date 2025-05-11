---
layout: notes 
title: Utils
---

# Utils
{:.no_toc}

---

* TOC
{:toc}

---

## Email

Most of the web application send email to their users.

### Fake the mail server
The application is currently running in the CentOS and it uses postfix mail server as a default. For my local development, I don't need this mail server and very happy with fake mail server which can help to find the email immediately from the console. 

- Stop the mail server if it is running in your development 
- Create a mail service using python

Here the code for the terminal:

```bash
sudo postfix stop
sudo python -m smtpd -n -c DebuggingServer localhost:25
```

Install python 2.7 on Centos:

```bash
sudo yum update # update yum
sudo yum install centos-release-scl # install SCL 
sudo yum install python27 # install Python 2.7
scl enable python27 bash
```

virtual env:

```bash
virtualenv -p /opt/rh/python27/root/usr/bin/python test
cd test
source test/activate
```