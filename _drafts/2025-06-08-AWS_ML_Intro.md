---
layout: post
title:  AWS ML Intro
date:   2025-06-08
categories: [AWS]
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

Breif introduction

<!--more-->

------

* TOC
{:toc}
------

## Data Wrangler

Well integrated with **SageMake** and simplify data *ingestion* and *preprocessing* in via the visual interface:

Processing taks:

1. Handling missing values
2. Scaling and normalizing data
3. Encoding categorical varaibles

For efficent data formats like Parquet or RecordIO for large dataset has to be used.

> To access S3 from Data Wrangler you need to associate IAM policy with Data Wrangler which allow to access data in the S3 bucket: <span>assume as</span>{:gtxt} IAM role.
{:.yellow}



Contents goes here[^1]...

{:gtxt: .message color="green"}



[^1]: Fluent Python, 2nd Edition, Luciano Ramalho, [Chapter 7](https://learning.oreilly.com/library/view/fluent-python-2nd/9781492056348/ch07.html#attrgetter_demo)
