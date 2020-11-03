---
layout: post
title: "Binary search in Python"
date: 2020-10-29
categories: [Python, Algorithm]
---
<script type="text/javascript" id="MathJax-script" async
  src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js">
</script>
<script type="text/javascript">
window.MathJax = {
  tex: {
    packages: ['base', 'ams']
  },
  loader: {
    load: ['ui/menu', '[tex]/ams']
  }
};
</script>
Binary Search is one of the most fundamental algorithm.

![Binary Search](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20201030093627427.png)

I explain the procedural and functional way of binary search algorithm.

<!--more-->

Binary sarch can be run only on sorted list (line# 17). The running time of the binary search is $$O(\log{}n)$$, for more information, see [Algorithm Analysis](https://ojitha.blogspot.com/2016/05/algorithm-analysis.html).

```python
def bs(list, s):
    l =0 # low boundry
    h = len(list) - 1 # high boundary
    while (h >= l):
        m = (l+h) // 2 #calculate middle
        guess = list[m]
        if (guess == s):
            return m
        if (s > guess):
            l = m + 1
        else:
            h = m -1

    return None

# Test to run
list = [0,1,2,3,4,5,6,7,8,9]
result = bs(list, 0)
print(result)
```

If you follow the functional programming, here the recursive founction

```python
def bsf(list,s,l,h):
    m = (l+h) // 2
    guess = list[m]
    while(h >= l): #if not found this will fail
        if (guess == s):
            return m # found
        # not found, find a either side of the list    
        if (s > guess):
            return bsf(list,s,m+1,h) # right side of the list
        else:
            return bsf(list,s,l,m-1) # left side of the list

    return None


# Test to run
list = [0,1,2,3,4,5,6,7,8,9]
result = bsf(list,2,0,len(list))
print(result)
```
