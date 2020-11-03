---
layout: post
title: "Selection sort in Python"
date: 2020-10-31
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

Selection sort runining time is very high as $$O(N^2)$$.

![Selection Sort](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20201031111651922.png)

<!--more-->

Example code:

```python
def findSmallest(a):
    smallest=a[0]
    index = 0
    for i in range(1, len(a)):
        if smallest > a[i]:
            smallest = a[i]
            index = i

    return index

def selection_sort(a):
    sorted_array = []
    for i in range(len(a)):
        smallest_position = findSmallest(a) # O(nxn)
        sorted_array.append(a.pop(smallest_position))
    return sorted_array

# Test
print(selection_sort([5,3,9,4,1,6,20]))
```
