---
layout: post
title:  Python Sequences
date:   2022-02-25
categories: [Python]
toc: true
---

Here python `list`, `tulple` basic operations are discussed. 

<!--more-->

------

* TOC
{:toc}
------

There are two types of sequences.

1.  Container : `list`, `tuple` and `collections.deque`. Hold the references to the objects.
2.  Flat : `str`, `bytes` and `array.array`

> Flat sequences are compact but limited to holding primitives such as
> bytes, integers and floats.

The most fundamental mutable container is `list`. The list comprehensions(listcomps) and generator expressions(Genexps) can be used because of this mutability.

The built-n sequence types are one dimensional.




## List

``` python
a = 'Ojitha'
[l for l in a]
```


    ['O', 'j', 'i', 't', 'h', 'a']


Some use of list API:

Concatenation supported by both tuple and list

``` python
[1,2] + [2,3]
```


    [1, 2, 2, 3]


but if you concatenate list and tuple

``` python
[1.2] + (2,3)
```


    ---------------------------------------------------------------------------
    TypeError                                 Traceback (most recent call last)
    /Users/ojitha/workspace/pywork/spark/PySparkExamples/code/python_data_structures.ipynb Cell 9' in <module>
    ----> <a href='vscode-notebook-cell:/Users/ojitha/workspace/pywork/spark/PySparkExamples/code/python_data_structures.ipynb#ch0000088?line=0'>1</a> [1.2] + (2,3)
    
    TypeError: can only concatenate list (not "tuple") to list


To append

``` python
b =[1,2,3]
b.append(4)
b
```


    [1, 2, 3, 4]




clear elements



``` python
b.clear()
b
```


    []




Return `True` if a element is in the list



``` python
b =[1,2,3,2, 2]
b.__contains__(1)
```


    True




Count the number of times the element is occurred in the list



``` python
b.count(2)
```


    3




delete it from the list position



``` python
b.__delitem__(2)
b
```


    [1, 2, 2, 2]




Append from iterable



``` python
b.extend([i for i in range(5,10)])
b
```


    [1, 2, 2, 2, 5, 6, 7, 8, 9]




Get item at index



``` python
b.__getitem__(2)
```


    2




Find the first position of the occurrence.



``` python
b.index(2)
```


    1




Find the length of the list.



``` python
len(b)
b.__len__()
```


    9




Insert element before the position



``` python
b.insert(5,4)
b
```


    [1, 2, 2, 2, 5, 4, 6, 7, 8, 9]




Remove the last element from the list



``` python
b.pop()
```


    9




Remove the element from the specific position



``` python
b.pop(3)
```


    2




Remove the first occurrence of the element.



``` python
b.remove(2)
b
```


    [1, 2, 5, 4, 6, 7, 8]







Reverse the order of the list



``` python
b.reverse()
b
```


    [8, 7, 6, 4, 5, 2, 1]




Sort the list



``` python
#b.sort(reverse=True)
b
```


    [8, 7, 6, 4, 5, 2, 1]




### list comprehensions

Listcomps do everything `filter` and `map` do



``` python
[i for i in range(10) if i > 5 ]
```


    [6, 7, 8, 9]




``` python
list(filter(lambda i: i > 5,range(10)))
```


    [6, 7, 8, 9]




``` python
[i+10 for i in range(10)]
```


    [10, 11, 12, 13, 14, 15, 16, 17, 18, 19]




``` python
list(map(lambda i:i+10, range(10)))
```


    [10, 11, 12, 13, 14, 15, 16, 17, 18, 19]




### Listcomps `RxS`

Listcomp can produce a cartesian product of two or more iterables



``` python
[(n1, n2, n3) for n1 in (0,1) for n2 in (0,1) for n3 in (0,1)]
```


    [(0, 0, 0),
     (0, 0, 1),
     (0, 1, 0),
     (0, 1, 1),
     (1, 0, 0),
     (1, 0, 1),
     (1, 1, 0),
     (1, 1, 1)]




### Generator Expressions

Genexps save memory because it yield items one by one instead of
creating a complete list and feed at once as Listcomp do.



``` python
tuple((n1, n2, n3) for n1 in (0,1) for n2 in (0,1) for n3 in (0,1))
```


    ((0, 0, 0),
     (0, 0, 1),
     (0, 1, 0),
     (0, 1, 1),
     (1, 0, 0),
     (1, 0, 1),
     (1, 1, 0),
     (1, 1, 1))




## Tuples

Tuples are immutable lists as well as records with values and their
positions. Tuple uses less memory compared to the same length of list.
For the API operations, refer to the
[Table 2-1](https://learning.oreilly.com/library/view/fluent-python-2nd/9781492056348/ch02.html#list_x_tuple_attrs_tbl)
in the *Comparing Tuple and List Methods* of the book [2. An Array of
Sequences \| Fluent Python, 2nd
Edition](https://learning.oreilly.com/library/view/fluent-python-2nd/9781492056348/ch02.html#idm45613945359760).



``` python
state, city, postCode = ('NSW', 'Sydney', 2000)
postCode # position = 3
```


    2000




example, API use to get the element at the position



``` python
t = ('a','b','c')
t[2]
```


    'c'




Find the index of an element



``` python
t.index('b')
```


    1




repeated concatenation (the list also support)



``` python
t * 2
```


    ('a', 'b', 'c', 'a', 'b', 'c')




concatenation support both list and tuple



``` python
t + (1,2)
```


    ('a', 'b', 'c', 1, 2)




``` python
t+[1,2]
```


    ---------------------------------------------------------------------------
    TypeError                                 Traceback (most recent call last)
    /Users/ojitha/workspace/pywork/spark/PySparkExamples/code/python_data_structures.ipynb Cell 56' in <module>
    ----> <a href='vscode-notebook-cell:/Users/ojitha/workspace/pywork/spark/PySparkExamples/code/python_data_structures.ipynb#ch0000083?line=0'>1</a> t+[1,2]
    
    TypeError: can only concatenate tuple (not "list") to tuple




The [PEP 3132 \-- Extended Iterable Unpacking \|
Python.org](https://www.python.org/dev/peps/pep-3132/) is well known.



``` python
a, *b, c = range(5,10)
a, c
```


    (5, 9)




Swapping the variables without temporary variable:



``` python
a, c = c, a
a, c
```


    (9, 5)




If you use split, the return is a list



``` python
"ojitha hewa".split(" ")
```


    ['ojitha', 'hewa']




but you can convert to tuple



``` python
tuple("ojitha hewa".split(" "))
```


    ('ojitha', 'hewa')




This can be used in the string format as follows:



``` python
"my first '%s' and last '%s'" % tuple("ojitha hewa".split(" "))
```


    "my first 'ojitha' and last 'hewa'"




Tuples hold the object references. Therefore, reference can be mutable
such as a list. That means the tuple which has mutable references can not
be hash.



``` python
immutable_t = (10,(1,3))
hash(immutable_t)
```


    3408708537663480494




``` python
muttable_t = (10,[1,3])
hash(muttable_t)
```


    ---------------------------------------------------------------------------
    TypeError                                 Traceback (most recent call last)
    /Users/ojitha/workspace/pywork/spark/PySparkExamples/code/python_data_structures.ipynb Cell 53' in <module>
          <a href='vscode-notebook-cell:/Users/ojitha/workspace/pywork/spark/PySparkExamples/code/python_data_structures.ipynb#ch0000022?line=0'>1</a> muttable_t = (10,[1,3])
    ----> <a href='vscode-notebook-cell:/Users/ojitha/workspace/pywork/spark/PySparkExamples/code/python_data_structures.ipynb#ch0000022?line=1'>2</a> hash(muttable_t)
    
    TypeError: unhashable type: 'list'




### Unpacking

Let us first see the use of the `*` when passing parameters.



``` python
def f(a,b,c):
    return a, b, c
```



The simple parameter pass is



``` python
f([1,2], 3, 4)
```


    ([1, 2], 3, 4)




But if you use `*`



``` python
f(*[1,2], 3, 4)
```


    ---------------------------------------------------------------------------
    TypeError                                 Traceback (most recent call last)
    /Users/ojitha/workspace/pywork/spark/PySparkExamples/code/python_data_structures.ipynb Cell 79' in <module>
    ----> <a href='vscode-notebook-cell:/Users/ojitha/workspace/pywork/spark/PySparkExamples/code/python_data_structures.ipynb#ch0000100?line=0'>1</a> f(*[1,2], 3, 4)
    
    TypeError: f() takes 3 positional arguments but 4 were given




This is because first argument is unpacked, therefore, above function
can call as



``` python
f(*[1,2], 3)
```


    (1, 2, 3)




``` python
*range(3),10
```


    (0, 1, 2, 10)




Nested unpacking



``` python
a, b, (c,d) = 'a', 'b', (1,2)
d
```


    2




### Named Tuples

The `namedtuple` is a factory method that provide a subclass of tuple
with field names and class name, for example



``` python
from collections import namedtuple
a = namedtuple('State', 'city postcode')
syd = a('Sydney', ('Sydney',2000))
syd
```


    State(city='Sydney', postcode=('Sydney', 2000))




## Slicing

The well-known operation of `[n1:n2]` on all sequence types
(`list`, `tuple` or `str`). 

![image-20220226192145428](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20220226192145428.png)



``` python
r=[i for i in  range(10)] # [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
r[3:8] # 8 - 3 = 5 elemennts          s              e         s - start e - end 
```


    [3, 4, 5, 6, 7]




``` python
r[-8:-3] # [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
         #  
```


    [2, 3, 4, 5, 6]




As shown above, For example, split sequence to two



``` python
'{left} and {right}'.format(left=r[:5], right=r[5:])
```


    '[0, 1, 2, 3, 4] and [5, 6, 7, 8, 9]'




Compare the above with the following



``` python
'{left} and {right}'.format(left=r[:-5], right=r[-5:])
```


    '[0, 1, 2, 3, 4] and [5, 6, 7, 8, 9]'




you can use stride or step, for example, 2:



``` python
r[:5:2]
```


    [0, 2, 4]




``` python
r[5::2]
```


    [5, 7, 9]




``` python
r[:5:-2]
```


    [9, 7]

## dict comprehensions
First create listcomps 

``` python
import string
myList = [chr(chNum) for chNum in list(range(ord('a'),ord('z')+1))]
codes =  [(i,x) for i, x in enumerate(myList) if i > 10]
```
From the above listcomp, create dictcomps:

```python
d = {letter: i+1 for i, letter in codes if i > 20}
```

use this in a function

```python
def dump(**kwargs):
    return kwargs
dump(a=1,**d)   
# {'a': 1, 'v': 22, 'w': 23, 'x': 24, 'y': 25, 'z': 26}
```

above is simlar to the `{'a':1, **{'v': 22, 'w': 23, 'x': 24, 'y': 25, 'z': 26}}`, but notice the first 
element.

## Hack for JSON

To [hack](https://learning.oreilly.com/library/view/fluent-python-2nd/9781492056348/ch03.html#idm46582491014480) to copy and paste jon to python:

```python
true, false, null = True, False, None # hack
fruit = {
     "type": "banana",
     "avg_weight": 123.2,
     "edible_peel": false,
     "species": ["acuminata", "balbisiana", "paradisiaca"],
     "issues": null,
 }
```

