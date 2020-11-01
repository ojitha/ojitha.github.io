---
layout: post
title: "Quick sort in Python"
date:   2020-11-01 00:00:00 +1000
categories: [blog]
excerpt_separator: <!--more-->
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
Quick sort avarage runining time is $$O(n\log{}n)$$.

![image-20201101122401694](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20201101122401694.png)

To learn more about Python generators, see [python fun](https://ojitha.blogspot.com/2015/11/python-fun.html).

<!--more-->

For example to sort the above array:

```python
def qs(a):
    if len(a) <2: #base case
        return a
    else: # recursive case
         p =  a[0] #pivot as first element of the array
         l = [e for e in a[1:] if e <= p]
         r = [e for e in a[1:] if e > p]
         return qs(l)+[p]+qs(r)

#Test         
print (qs([5,9,4,7,6,8,2,1,3]))
```

Quick sort complexcity

![image-20201101124728600](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20201101124728600.png)

The complexcity of the quick sort can be worst as $$O(n^2)$$ base on the pivotal you choose. For example, even for the sorted array if the pivotal is first element, the deapth is `n`.

