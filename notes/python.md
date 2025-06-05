---
layout: notes 
title: Python
mermaid: true
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

# Notes on Python
{:.no_toc}

---

* TOC
{:toc}

---

## First Class Objects

Python can treates function (including anonymous function `lambda`) as an object. A function that takes a function as an argument or returns a function as the result is a higher-order function[^1].

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

## Closures

A function variable becomes local when assigned a value; otherwise, it searches for global scope variable assignment of the same variable (the name of the variables are the same). Therefore, before use the local variable, you have to assign a variable locally, or you have to explicitly inform using the `global` keyword to avoid  the misconception:

```python
a=1
b=2
def bla(p)
    global a
    ...
    print(a) # this is valid because `a` is a global variable
    print(b) # this is not valid, there are errors because 
             # `b` is a local variable due to the following assignment 
    b=3
    ...
    a=5
```
A closure is simply a function with free variables, where the bindings for all such variables are known in advance. 

The *free variable* is a technical term meaning a variable that is not bound in the local scope but in the lexical scope. In Python language, all functions are closed. Therefore in the Python closures, free variables defined in the enclosing functions to access by its nested returning function. 

> lexical scope is the norm: free variables are evaluated considering the environment where the function is defined. Python does not have a program global scope, only module global scopes.

You have to use `nonlocal` keywoard instead of the `global` keyword to access the free variables from the nested function.

```python
g=10
def hoFunc(p):
    my_free_var=0
    def nested(n):
        nonlocal my_free_var,p
        global g # only define as global
        p += 1
        n += g # n is local
        g=1
        my_free_var += (n+p)
        return my_free_var
    return nested     

hoFunc(2)(1) #-> 4        
```
In the above code, `n` parameter is a local variable but `p` parameter is not.

## Decorators

The `singledispatch` is one of the [standard library decorator](https://learning.oreilly.com/library/view/fluent-python-2nd/9781492056348/ch09.html#idm46582438196432), which is use to create overloaded functions similar to Java overload methods instead dispatch function. For example,

```python
from functools import singledispatch
from collections import abc

@singledispatch
def myprint(obj:object) -> str: # generic function
    return f'object: {obj}'

@myprint.register
def _(text: str) -> str:
    return f'str: {text}'

@myprint.register
def _(n: int) -> str:
    return f'int: {n}'

@myprint.register(abc.Sequence) # pass the type if you want
def _(seq) -> str:
    return (f'sequence: {seq}')   
```

When you call `myprint(1)` the output: `'int: 1'` and call `myprint('oj')` the output is `'str: oj'`. In the case of input sequence such as `myprint([1,2,3])` the output is `'sequence: [1, 2, 3]'`.

> NOTE:  Java-style method overloading is missing in Python. When possible, register the specialized functions to handle abstract classes such as `numbers.Integral` and `abc.MutableSequence`, instead of concrete implementations like `int` and `list`.
> from [Fluent Python][fluent]

Here the simple decorator

```python
def deco(func):
    def inner(*args):
        result = func(*args)
        name = func.__name__
        arg_str = ', '.join(repr(arg) for arg in args)
        print(f' {name}({arg_str}) -> {result!r} in the decorator')
        return result
    return inner    
```

You can docorate `myfunc` as follows:

```python
@deco
def myfunc(p):
    print(f'parameter: {p}')

myfunc(1)   
```

output is 

```
parameter: 1
 myfunc(1) -> None in the decorator
```

But there is a problem, if you run `myfunc(p=1) `, you get the following error, because above decorator not support keyword arguments

```
TypeError                                 Traceback (most recent call last)
Cell In[11], line 5
      1 @deco
      2 def myfunc(p):
      3     print(f'parameter: {p}')
----> 5 myfunc(p=1)    

TypeError: deco..inner() got an unexpected keyword argument 'p'
```

The resoultion:

```python
import functools

def deco(func):
    @functools.wraps(func)
    def inner(*args, **kwargs):
        result = func(*args, **kwargs)
        name = func.__name__
        arg_str = ', '.join(repr(arg) for arg in args)
        print(f' {name}({arg_str}) -> {result!r} in the decorator')
        return result
    return inner   
```

As shown in the above code in the  

- line #1, you have to import `functools`
- line #4, do the wraping
- line #5, pass the `**kwargs` to the inner function
- line #6, pass the `**kwargs` to the function



### Decorator with arguments

To send parameter in the decorator[^2]:

```python
import functools
def docowithargs(show=True): #1
    def deco(func):
        @functools.wraps(func)
        def inner(*args, **kwargs):
            result = func(*args, **kwargs)
            if show: #2
                name = func.__name__
                arg_str = ', '.join(repr(arg) for arg in args)
                print(f' {name}({arg_str}) -> {result!r} in the decorator')
            return result
        return inner   
    return deco  #3  
```

Modify the `deco` function to pass the parameter as follows

1. New decorator which wrap the `deco` function
2. Use the argument pass in the decorator
3. return the deco function

If you run the following code:

```python
@docowithargs(show=True)
def myfuncT(p):
    print(f'parameter: {p}')

@docowithargs(show=False)
def myfuncF(p):
    print(f'parameter: {p}')

myfuncT(1)    
myfuncF(2)   
```

the output is

```
parameter: 1
 myfuncT(1) -> None in the decorator
parameter: 2
```

### Class based decorator

This is simple as follows:

```python
class classdeco:
    def __init__(self, show=True):
        self.show = show

    def __call__(self, func):
        def inner(*args, **kwargs):
            result = func(*args, **kwargs)
            if self.show: #1
                name = func.__name__
                arg_str = ', '.join(repr(arg) for arg in args)
                print(f' {name}({arg_str}) -> {result!r} in the decorator')
            return result
        return inner 
```

It is a same `inner` function with the modification to #1 in the above code. Decorate the function as follows and call the function:

```python
@classdeco(show=False)
def myfuncT(p):
    print(f'parameter: {p}')
    
# call the function
@classdeco(show=True)
def myfuncT(p):
    print(f'parameter: {p}')
```

The output is 

```
parameter: 3
 myfuncT() -> None in the decorator
```

## static vs class method
Class method expect class as a first parameter, but static method not:

```python
class MethodDeco:
    @classmethod #1
    def myClassMethod(*args) -> None:
        print(args)
    
    @staticmethod #2
    def myStaticMethod(*args) -> None:
        print(args)
```
if you call class method `MethodDeco.myClassMethod(1)` the output is:
```
(<class '__main__.MethodDeco'>, 1)
```
but if you call static method `MethodDeco.myStaticMethod(1)` the output is:

```
(1,)
```

Docker-compose

```dockerfile
  dev:
    build:
      context: ./
      target: mydev
      args:
        - ENV_ROOT=/usr/local/pyenv
        - PYTHON_VER=3.8.20
    privileged: true 
    volumes:
      - .:/opt/spark/work-dir:rw  
    ports:
      - 8888:8888
      - 8998:8998        
      - 4040:4040      
    depends_on:
      - spark-master
      - spark-worker-1  
    container_name: dev
```

Setup_sparkmagic

```bash
eval "$(pyenv init -)"
pyenv activate notebook 
SM_DIR=`pip list -v | grep sparkmagic | xargs echo | awk '{print $3}'`
cd $SM_DIR
echo "spark magic directory is $SM_DIR"
jupyter nbextension enable --py --sys-prefix widgetsnbextension 
jupyter-kernelspec install sparkmagic/kernels/sparkkernel
jupyter-kernelspec install sparkmagic/kernels/pysparkkernel
jupyter serverextension enable --py sparkmagic
```

entry

```bash
# Dockerfile
ARG http_proxy
ARG https_proxy
ARG ftp_proxy

RUN if [ -n "$http_proxy" ]; then \
    export http_proxy="$http_proxy"; \
    fi && \
    if [ -n "$https_proxy" ]; then \
    export https_proxy="$https_proxy"; \
    fi && \
    if [ -n "$ftp_proxy" ]; then \
    export ftp_proxy="$ftp_proxy"; \
    fi && \
    # Your build commands that require network access
    apt-get update && apt-get install -y some-package
```

## Conda

After install the conda,

If you are need proxy setting, then setup that in the file `miniconda3/.condarc`:

```
ssl_verify: false
proxy_servers:
	http://...
	https://...<same as above>
channels:
	- default
	- conda-forge
```

To create a new environment

```bash
conda create --name myenv python=3.11.11
```

To get all the existing environments

```bash
conda info --envs
```

To activate the environment:

```bash
conda activiate myenv
```

To deactivate

```bash
conda deactivate
```

To delete the environment

```bash
conda remove -n myenv --all
```

## Logging

### Custom JSON Formatter 

Creates structured logs with timestamp, level, message, and metadata

```python
# Method 1: Custom JSON Formatter
class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_entry = {
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno,
        }
        
        # Add exception info if present
        if record.exc_info:
            log_entry['exception'] = self.formatException(record.exc_info)
        
        # Add any extra fields
        for key, value in record.__dict__.items():
            if key not in ['name', 'msg', 'args', 'levelname', 'levelno', 'pathname', 
                          'filename', 'module', 'exc_info', 'exc_text', 'stack_info',
                          'lineno', 'funcName', 'created', 'msecs', 'relativeCreated',
                          'thread', 'threadName', 'processName', 'process', 'getMessage']:
                log_entry[key] = value
        
        return json.dumps(log_entry, default=str)
```



### Library Integration 

Shows how to use `python-json-logger` for simpler setup:

```python
import logging
import sys
from pythonjsonlogger import jsonlogger

def setup_json_logger(name='app', level=logging.INFO):
    """
    Initialize JSON logger once - call this only from main module
    """
    logger = logging.getLogger(name)
    
    # Prevent duplicate handlers if called multiple times
    if logger.handlers:
        return logger
    
    logger.setLevel(level)
    
    # Console handler with JSON formatting
    console_handler = logging.StreamHandler(sys.stdout)
    
    # JSON formatter with custom fields
    formatter = jsonlogger.JsonFormatter(
        '%(asctime)s %(name)s %(levelname)s %(message)s %(module)s %(funcName)s %(lineno)d',
        rename_fields={
            'asctime': 'timestamp',
            'levelname': 'level',
            'name': 'logger'
        }
    )
    
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    
    # Prevent propagation to root logger
    logger.propagate = False
    
    return logger
```

Spark basic logger initialisation:

```python
from pyspark.sql import SparkSession
from pyspark import SparkContext

# Create SparkSession with log4j2 configuration
spark = SparkSession.builder \
    .appName("MyPySparkApp") \
    .config("spark.driver.extraJavaOptions", "-Dlog4j2.configurationFile=log4j2.properties") \
    .config("spark.executor.extraJavaOptions", "-Dlog4j2.configurationFile=log4j2.properties") \
    .getOrCreate()

# Get the SparkContext
sc = spark.sparkContext

# Get the log4j logger
log4j = sc._jvm.org.apache.log4j
logger = log4j.LogManager.getLogger(__name__)

# Use the logger
logger.info("This is an info message from PySpark")
logger.warn("This is a warning message")
logger.error("This is an error message")
```





[fluent]: https://www.oreilly.com/library/view/fluent-python-2nd/9781492056348 "Fluent Python 2nd Edition"

[^1]: [higher-order function](https://learning.oreilly.com/library/view/fluent-python-2nd/9781492056348/ch07.html#idm46582448567408)

[^2]: [Primer on Python Decorators](https://realpython.com/primer-on-python-decorators/#decorators-with-arguments)
