---
layout: notes 
title: Python
---

**Notes on Python**

* TOC
{:toc}
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
