---
layout: post
title: "Binary search in Python"
date: 2020-10-29
categories: [python, algorithm]
excerpt_separator: <!--more-->
---

Binary Search one of the most fundamental algorithm. Here the very simple explanation and the running time of this algorithm. 

<!--more-->

The running time of the binary search is $ \log_{2} 3 $.

```python
def bs(list, search_item):
    l =0 # low boundry
    h = len(list) - 1 # high boundary
    while (h >= l):
        m = (l+h) // 2 #calculate middle
        guess = list[m]
        if (guess == search_item):
            return m
        if (search_item > guess):
            l = m + 1
        else:
            h = m -1

    return None

# Test to run
list = [0,1,2,3,4,5,6,7,8,9]
result = bs(list, 0)
print(result)

```