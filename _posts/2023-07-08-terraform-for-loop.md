---
layout: post
title:  Terraform For each iteration
date:   2023-07-08
categories: [Terraform]
toc: true
---

<style>
/* Styles for the two-column layout */
.image-text-container {
    display: flex; /* Enables flexbox */
    flex-wrap: wrap; /* Allows columns to stack on small screens */
    gap: 20px; /* Space between the image and text */
    align-items: center; /* Vertically centers content in columns */
    margin-bottom: 20px; /* Space below this section */
}

.image-column {
    flex: 1; /* Allows this column to grow */
    min-width: 250px; /* Minimum width for the image column before stacking */
    max-width: 40%; /* Maximum width for the image column to not take up too much space initially */
    box-sizing: border-box; /* Include padding/border in element's total width/height */
}

.text-column {
    flex: 2; /* Allows this column to grow more (e.g., twice as much as image-column) */
    min-width: 300px; /* Minimum width for the text column before stacking */
    box-sizing: border-box;
}

</style>

<div class="image-text-container">
    <div class="image-column">
        <img src="/assets/images/2023-07-08-terraform-for-loop/create 3 S3 buckets.jpg" alt="arcitecture of the streaming application" width="200" height="30">
    </div>
    <div class="text-column">
<p>This is to explain Terraform for each looping technique. In this example, 3 buckets are created to demonstrate the looping idea.
</p>

    </div>
</div>


<!--more-->

------

* TOC
{:toc}
------

## Simple Example

In the first step, we will create the above 3 buckets starting from 0.

![create 3 S3 buckets](/assets/images/2023-07-08-terraform-for-loop/create 3 S3 buckets.jpg)

This is a simple example[^1] where you have only string interpolations in the local variables. In the main.tf file:

```terraform
terraform {
  required_version = ">=0.12.0"
}

provider "aws" {
  version = "~> 2.0"
  region  = "ap-southeast-2"
  profile = "dev"
}

variable "bucket_owner" {
  type    = string
  default = "oj"

}


locals {
  bucket_prefix= "${data.aws_caller_identity.current.account_id}-${var.bucket_owner}-${local.bucket_resource}"
  bucket_resource = "bucket"    
}

resource "aws_s3_bucket" "bucket0" {
  bucket =  "${local.bucket_prefix}0"
}

resource "aws_s3_bucket" "bucket1" {
  bucket = "${local.bucket_prefix}1"
  tags = {
    "dependency" = aws_s3_bucket.bucket0.arn
  }
}

resource "aws_s3_bucket" "bucket2" {
  bucket = "${local.bucket_prefix}2"
  #Explicit
  depends_on = [aws_s3_bucket.bucket1]
}

data "aws_caller_identity" "current" {

}

data "aws_availability_zones" "available" {
  state = "available"
}

output "bucket1_info" {
  value = aws_s3_bucket.bucket1
}

output "bucket2_info" {
  value = aws_s3_bucket.bucket1
}

output "aws_caller_info" {
  value = data.aws_caller_identity.current
}

output "aws_availability_zones" {
  value = data.aws_availability_zones.available
}

output "aws_caller_identity_account_id" {
  value = data.aws_caller_identity.current
}
```

The bucket name is composed in line #19 under the local variables.

![three-s3-buckets](/assets/images/2023-07-08-terraform-for-loop/three-s3-buckets.png)

## Count

You can use the `count.index` to start the base number. For example, if the count value is 3, the bucket is 1 to 2, not starting from zero.

```terraform
terraform {
  required_version = ">=0.12.0"
}

provider "aws" {
  version = "~> 2.0"
  region  = "ap-southeast-2"
  profile = "dev"
}

variable "bucket_owner" {
  type    = string
  default = "oj"

}


locals {
  bucket_prefix= "${data.aws_caller_identity.current.account_id}-${var.bucket_owner}-${local.bucket_resource}"
  bucket_resource = "bucket"    
}

resource "aws_s3_bucket" "bucket" {
  count = 3
  bucket =  "${local.bucket_prefix}${count.index}"
}

# resource "aws_s3_bucket" "bucket1" {
#   bucket = "${local.bucket_prefix}1"
#   tags = {
#     "dependency" = aws_s3_bucket.bucket0.arn
#   }
# }

# resource "aws_s3_bucket" "bucket2" {
#   bucket = "${local.bucket_prefix}2"
#   #Explicit
#   depends_on = [aws_s3_bucket.bucket1]
# }

data "aws_caller_identity" "current" {

}

data "aws_availability_zones" "available" {
  state = "available"
}

output "bucket_info" {
  value = aws_s3_bucket.bucket
}

# output "bucket2_info" {
#   value = aws_s3_bucket.bucket2
# }

output "aws_caller_info" {
  value = data.aws_caller_identity.current
}

output "aws_availability_zones" {
  value = data.aws_availability_zones.available
}

output "aws_caller_identity_account_id" {
  value = data.aws_caller_identity.current
}
```

The above provision script is simplified as follows:

![three-s3-buckets_count](/assets/images/2023-07-08-terraform-for-loop/three-s3-buckets_count.png)



The magic count has been used in lines #24-25.

## For each

Here,



```terraform
terraform {
  required_version = ">=0.12.0"
}

provider "aws" {
  version = "~> 2.0"
  region  = "ap-southeast-2"
  profile = "dev"
}

variable "bucket_owner" {
  type    = string
  default = "oj"

}


locals {
  bucket_prefix= "${data.aws_caller_identity.current.account_id}-${var.bucket_owner}-${local.bucket_resource}"
  bucket_resource = "bucket"    
}

locals {
  buckets = {
    bucket0 = "0"
    bucket1 = "1"
    bucket2 = "2"
  }
}

resource "aws_s3_bucket" "bucket" {
  for_each = local.buckets
  bucket =  "${local.bucket_prefix}${each.value}"
}

# resource "aws_s3_bucket" "bucket1" {
#   bucket = "${local.bucket_prefix}1"
#   tags = {
#     "dependency" = aws_s3_bucket.bucket0.arn
#   }
# }

# resource "aws_s3_bucket" "bucket2" {
#   bucket = "${local.bucket_prefix}2"
#   #Explicit
#   depends_on = [aws_s3_bucket.bucket1]
# }

data "aws_caller_identity" "current" {

}

data "aws_availability_zones" "available" {
  state = "available"
}

output "bucket_info" {
  value = aws_s3_bucket.bucket
}

# output "bucket2_info" {
#   value = aws_s3_bucket.bucket2
# }

output "aws_caller_info" {
  value = data.aws_caller_identity.current
}

output "aws_availability_zones" {
  value = data.aws_availability_zones.available
}

output "aws_caller_identity_account_id" {
  value = data.aws_caller_identity.current
}
```

In the above code, the `count` has been replaced by the `foreach` lines 23-34 as follows:

![three-s3-buckets_foreach](/assets/images/2023-07-08-terraform-for-loop/three-s3-buckets_foreach.png)

You can change the above code's map to list as follows:

```terraform
locals {
  buckets = ["0","1","2"]
}

resource "aws_s3_bucket" "bucket" {
  for_each = toset(local.buckets)
  bucket =  "${local.bucket_prefix}${each.key}"
}
```

As shown in lines #1-3, only the list elements are created as buckets. Please note how line #6 has been changed to return set. In line #7 instead of `each.value` now we are using `each.key`.

[^1]: [Developing Infrastructure as Code with Terraform LiveLessons](https://learning.oreilly.com/videos/developing-infrastructure-as/9780136608776/9780136608776-dict_01_03_08_00/)
