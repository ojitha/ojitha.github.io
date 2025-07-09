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
4. Address outliers
5. Anomalous samples
6. Feature summary (definition and statistics MSE, MAE, RMSE and median absolute error)

For efficent data formats like Parquet or RecordIO for large dataset has to be used.

- To handle large datasets in S3, use *Pipe Mode*.
- To preprocess data without exporting it, Data Wrangler supports *in-place* transformation.

> To access S3 from Data Wrangler you need to associate IAM policy with Data Wrangler which allow to access data in the S3 bucket: <span>assume as</span>{:gtxt} IAM role.
{:.yellow}



Contents goes here[^1]...

{:gtxt: .message color="green"}



[^1]: [Machine Learning with SageMaker](https://learning.oreilly.com/course/machine-learning-with/9780135479452/)
