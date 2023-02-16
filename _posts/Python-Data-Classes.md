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

