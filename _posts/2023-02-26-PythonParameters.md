---
layout: post
title:  Python Parameter passing
date:   2023-02-26
categories: [Python]
toc: true
---

Discuss the most possible ways of passing parameters in the python functions.

<!--more-->

------

* TOC
{:toc}
------

## Parameter passing in a function

In addition to positional parameters, there are few other parameter types including variadic parameters:

```python
def p2f(name, *content, namedpara=None, **attrs):
    print(f'name:{name}')
    print(f'content:{content}')
    print(f'namedpara:{namedpara}')
    print(f'attrs:{attrs}')
```
above positional parameter is the first one, named parameter is `namedpara`.

```python
p2f('ojitha')
```
output
```
name:ojitha
content:()
namedpara:None
attrs:{}
```
if your pass extra, it is for `content` tuple as follows
```python
p2f('ojitha','hewa', 'kum')
```
output
```
name:ojitha
content:('hewa', 'kum')
namedpara:None
attrs:{}
```
and

```python
p2f('ojitha',id=1)
```
output

```
name:ojitha
content:()
named parameters:None
attrs:{'id': 1}
```
if you pass parameters as follows
```python
params = {'name':'ojitha', 'last_name':'kuma'}
p2f(**params)
```
the output is
```
name:oj
content:()
namedpara:None
attrs:{'last_name': 'kuma'}
```
With type hints

```python
from typing import Optional


def p2f(name: str
    , *content: str
    , namedpara: Optional[str] = None
    , **attrs: str):
    
    print(f'name:{name}')
    print(f'content:{content}')
    print(f'namedpara:{namedpara}')
    print(f'attrs:{attrs}')
```
if you have different value to pass in the variadic parameters:

```python
from typing import Optional, Union

def p2f(name: str
    , *content: Union[str,int]
    , namedpara: Optional[str] = None
    , **attrs: Union[str,int]) :
    
    ...
```


## Keyword-only arguments
This will never capture unnamed positional arguments, for example

```python
def f(p1,*,p2):
    print(p1,p2)
```
and if you call the function

```python
f(1,2)
```
The ouput is an error

```
TypeError                                 Traceback (most recent call last)
Cell In[11], line 1
----> 1 f(1,2)

TypeError: f() takes 1 positional argument but 2 were given
```

Therefore you have to call the above function as follows

```python
f(1, p2 =2)
```

## Positional only
For example

```python
# since python 3.8
# position only parameters

def f(p1, p2, /, p3):
    print(p1, p2, p3)
```
if you call the function

```python
f(1, p2=2, p3=3)
```
the output is 

```
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
Cell In[25], line 1
----> 1 f(1, p2=2, p3=3)

TypeError: f() got some positional-only arguments passed as keyword arguments: 'p2'
```
but, if you call as follows:

```python
f(1,2, p3=3)
# output is 1 2 3
```

## Type Hints

You can use the following type Hints to define the method signature:

```python
from typing import Optional, Union


def p2f(name: str
    , *content: Union[str,int]
    , namedpara: Optional[str] = None
    , **attrs: Union[str,int]) :

    print(f'name:{name}')
    print(f'content:{content}')
    print(f'namedpara:{namedpara}')
    print(f'attrs:{attrs}')
```

If you call the above function `p2f('ojitha','hewa',21,id1='test', id2=2)`, the output is:

```
name:ojitha
content:('hewa', 21)
namedpara:None
attrs:{'id1': 'test', 'id2': 2}
```

