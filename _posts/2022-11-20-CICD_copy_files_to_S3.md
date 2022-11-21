---
layout: post
title:  AWS CI/CD pipeline to Copy files to S3 bucket
date:   2022-11-19
categories: [AWS]
---

Sometime it is necessary to copy files to S3 via CI/CD build pipelines. 

<!--more-->

------

* TOC
{:toc}
------

## Why CICD to copy files?
With my experiences,occations are:

- Extra python files for Glue jobs
- Copy DAGs to the S3 location where AWS MWAA can pick up

Here the minimalist example to Create CI/CD pipeline via AWS Cloudformation.