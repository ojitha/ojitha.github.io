---
layout: post
title:  Python Data Classes
date:   2022-02-25
categories: [Python]
---

Python  Data classes.

<!--more-->

------

* TOC
{:toc}
------


## Data class builders
The data class builders provide the following methods automatically:
- `__init__`
- `__repr__`
- `__eq__`

Both `collections.namedtuple` and `typing.NamedTuple` build classes that are `tuple` subclasses. The `@dataclass` is a class decorator that does not affect the class hierarchy.

### collections.namedtuple
The `collections.namedtuple` is the earliest data class. Example data class:

```python
import collections
from dataclasses import dataclass

Cloth = collections.namedtuple('Cloth', ['color','size'])

class Shirts:
    sizes = 'S M L'.split()
    colors = 'Black White Blue Green Yellow'.split()

    def __init__(self) -> None:
        self._cloths = [Cloth(color, size) for color in self.colors for size in self.sizes]

    def __len__(self):
        return len(self._cloths)     

    def __getitem__(self, position):
        return self._cloths[position]
```

You can run the following, because in the above code implemented `__len__` method.

```python
shirts = Shirts()
len(shirts)
```
Now you can print all the available shirts:

```python
for s in shirts:
    print(s)
```

The output is 

```
Cloth(color='Black', size='S')
Cloth(color='Black', size='M')
Cloth(color='Black', size='L')
Cloth(color='White', size='S')
Cloth(color='White', size='M')
Cloth(color='White', size='L')
Cloth(color='Blue', size='S')
Cloth(color='Blue', size='M')
Cloth(color='Blue', size='L')
Cloth(color='Green', size='S')
Cloth(color='Green', size='M')
Cloth(color='Green', size='L')
Cloth(color='Yellow', size='S')
Cloth(color='Yellow', size='M')
Cloth(color='Yellow', size='L')
```

To sort the shirt from `L`,`M` and `S` order:

```python
size_values = dict(S=3,M=2,L=1)
def high2low(cloth):
    color_value = Shirts.colors.index(cloth.color)
    return color_value * len(size_values) + size_values[cloth.size]
```

Print and compare with previous update:

```python
for shirt in sorted(shirts, key=high2low):
    print(shirt)
```

The output is

```
Cloth(color='Black', size='L')
Cloth(color='Black', size='M')
Cloth(color='Black', size='S')
Cloth(color='White', size='L')
Cloth(color='White', size='M')
Cloth(color='White', size='S')
Cloth(color='Blue', size='L')
Cloth(color='Blue', size='M')
Cloth(color='Blue', size='S')
Cloth(color='Green', size='L')
Cloth(color='Green', size='M')
Cloth(color='Green', size='S')
Cloth(color='Yellow', size='L')
Cloth(color='Yellow', size='M')
Cloth(color='Yellow', size='S')
```
Another example found from https://learning.oreilly.com/library/view/fluent-python-2nd/9781492056348/ch07.html#attrgetter_demo

```python
from collections import namedtuple

LatLon = namedtuple('LatLon', 'lat lon')  
Metropolis = namedtuple('Metropolis', 'name cc pop coord')  
metro_areas = [Metropolis(name, cc, pop, LatLon(lat, lon))  
    for name, cc, pop, (lat, lon) in metro_data]
metro_areas
```

the output is 

```
[Metropolis(name='Tokyo', cc='JP', pop=36.933, coord=LatLon(lat=35.689722, lon=139.691667)),
 Metropolis(name='Delhi NCR', cc='IN', pop=21.935, coord=LatLon(lat=28.613889, lon=77.208889)),
 Metropolis(name='Mexico City', cc='MX', pop=20.142, coord=LatLon(lat=19.433333, lon=-99.133333)),
 Metropolis(name='New York-Newark', cc='US', pop=20.104, coord=LatLon(lat=40.808611, lon=-74.020386)),
 Metropolis(name='São Paulo', cc='BR', pop=19.649, coord=LatLon(lat=-23.547778, lon=-46.635833))]
```

to access

```python
metro_areas[0].coord.lat
# output: 35.689722
```

more efficient to access using `attrgetter` in the `operator` package

```python
from operator import attrgetter
name_lat = attrgetter('name', 'coord.lat')  

for city in metro_areas:  
    print(name_lat(city))
```

the ouput is 

```
('Tokyo', 35.689722)
('Delhi NCR', 28.613889)
('Mexico City', 19.433333)
('New York-Newark', 40.808611)
('São Paulo', -23.547778)
```

Convert to the json

```python
import json
json.dumps(shirts[0]._asdict())
```
output is

```
'{"color": "Black", "size": "S"}'
```
### typing.NamedTuple
Since Python 3.6, it made easy to add new methods and override methods by creating data classe extended from `tuple`.

```python
from typing import NamedTuple
from dataclasses import field

class NTShirts(NamedTuple):
    sizes: list[str] = field(default_factory=list)
    colors: list[str] = field(default_factory=list)
    
nt = NTShirts('S M L'.split(),'Black White Blue Green Yellow'.split())
nt    
```

output is

```
NTShirts(sizes=['S', 'M', 'L'], colors=['Black', 'White', 'Blue', 'Green', 'Yellow'])
```

### Data Class

Since Python 3.9, you can find the decorator which can be used to create data class:

```python
from dataclasses import dataclass, field
from typing import ClassVar

@dataclass
class DCShirts:
    sizes: list[str] = field(default_factory=list)
    colors: list[str] = field(default_factory=list)
    inventory: ClassVar[int] = 99

dc = DCShirts('S M L'.split(),'Black White Blue Green Yellow'.split())
dc
```
This will generate the same output, but important point is `ClassVar` which hold the class variable, while `sizes` and `colors` are instance variables.

> Both `NamedTuple` and docorator support [PEP 526 – Syntax for Variable Annotations](https://peps.python.org/pep-0526/)

## First Class Objects
Python can treates function (including anonymous function `lambda`) as an object. A function that takes a function as an argument or returns a function as the result is a [higher-order function](https://learning.oreilly.com/library/view/fluent-python-2nd/9781492056348/ch07.html#idm46582448567408).

NOTE: In the `lambda`, the body cannot contain Python statements (eg:`while`, `try`). Assignment with `=` is also a statement, therefore it cannot be occured in a lambda. However, the new assignment expression syntax using `:=` can be used.

There are 9 flavors of callable objects:
1. User-defined functions
2. Built-in functions (`len`)
3. Built-in methods (of `dict`, `tuple` and so on)
4. Methods of a class
5. Classes
6. Class instances (`__call__` method must be defined) 
7. Generator functions (`yield` returns the generator object)
8. Native coroutine functions (`async def`)
9. Asynchronous generator functions ( function or method defined with `async def` and return by the `yield`.

### Parameter passing in a function
In addition to positional parameters, there are few other parameter types:

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

#### Keyword-only arguments
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

#### Positional only
For example

```
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
For Python 3.7 and 3.8, you need a `__future__` import to make the `[]` notation work with built-in collections such as `list` and Python ≥ 3.5, use the `from typing import List`.

for example in the jupyter notebook cell

```python
%%python3
from __future__ import annotations

def upperWords(text: str) -> list[str]:
    return text.upper().split()
```

### Tuple Types
There are three ways to annotate tuple types:

1.Tuples as records
2.Tuples as records with named fields
3.Tuples as immutable sequences

Tuples as records
```
%%python3

from __future__ import annotations
def printCountryCode(country_code:tuple[str,int]) -> str:
    s, n = country_code
    return f'{s} is +{n}'

print(printCountryCode(('AU', 61)))
```

Tuples as records with named fields

```python
from __future__ import annotations
from typing import NamedTuple

class CountryCode(NamedTuple):
    country: str
    code: int

au_code = CountryCode('AU',61)

# using above method
print(printCountryCode(au_code))

# Method with CountryCode as a parameter

def printCCode(country_code:CountryCode) -> str:
    s, n = country_code
    return f'{s} is +{n}'

print(printCCode(au_code))
#-> Same result from both functions
# AU is +61
# AU is +61
```

Tuples as immutable sequences

```
%%python3

from __future__ import annotations

t1:tuple[str,str] = ('a','b')
t2:tuple[str,str] = ('c','d')
t:tuple[str, ...] = t1 + t2
print(t) #-> ('a', 'b', 'c', 'd')
```
Specify a single type `tuple[<type>,...]`.

### Map types
Here the simple example

```python
letterMap:dict[int,str] = {1:'a',2:'b'}
```

In general it’s better to use abc.Mapping or abc.MutableMapping in parameter type hints.
```python
from collections.abc import Mapping
def printLetters(letters:Mapping[int,str]) ->list[str]:
    return [v for _, v in letterMap.items()]

printLetters(letterMap) #-> ['a', 'b']
```
Using `abc.Mapping` allows to pass the instance of `dict`, `defaultdict`, `ChainMap`, or any other type that is a subtype-of `Mapping`.

The method signature can be change as follows for Python 3.8 or earlier (`typing.List`):

```python
from collections.abc import Mapping
from typing import List

def printLetters(letters:Mapping[int,str]) ->List[str]: # concrete
    return [v for _, v in letterMap.items()]

printLetters(letterMap)
```
As shown above function returns the Concrete object of `List` which is the generic class of `list`. However, to minimize the memeory usage:

```python
from collections.abc import Mapping, Iterator

def printLetters(letters:Mapping[int,str]) ->Iterator[str]:
    for _, v in letterMap.items():
        yield v

l = printLetters(letterMap)
for i in l:
    print(i)
#->
# a
# b
```

In the Python 3.10, you can use type alias

```python
from collections.abc import Mapping
from typing import List
from typing import TypeAlias

# define the type alias
ta:TypeAlias = Mapping[int,str]

def printLetters(letters:ta) ->List[str]:
    return [v for _, v in letterMap.items()]

printLetters(letterMap)
```

This will simplify the method signature.

## Parameterized Generics
Generic type, written as `list[T]`, where `T` is a **type variable** that will be bound to a specific type in each occation.

### Risticted TypeVar
```python
from typing import TypeVar
from collections.abc import Sequence, Iterable

T = TypeVar('T',int,float, str)

def doubElem(l:Sequence[T]) -> Iterable[T]:
    for i in l:
        yield i*2

for i in doubElem((1,2)):
    print(i)  

for i in doubElem(['a','b','c']):
    print(i)
  
```
output is
```
2
4
aa
bb
cc
```

### Bounded TypeVar

```python
from typing import TypeVar
from collections.abc import Sequence, Iterable

T = TypeVar('T',bound=int)

def doubIntElem(l:Sequence[T]) -> Iterable[T]:
    return [i for i in l]

for i in doubIntElem((1,2)):
    print(i)  

# for i in doubIntElem(['a','b','c']):
#     print(i)  
```
output is
```
1
2
```
NOTE:
One of the predefined bounded type variable is `AnyStr`.
