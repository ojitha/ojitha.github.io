---
layout: post
title:  "How to run python GUI in MacOS"
date:   2020-11-07
category: MacOS
---

I tried wxPython, which is not even possible to install. I tried Tkinter, which worked but not the best as I expected. The only choice was PyObjC that worked as expected, but not cross platform capable.

<!--more-->

First install the Python 3.9.0 or above using `pyenv`:

```bash
  pyenv install 3.9.0
```

Now make the new version as default

```bash
  pyenv global 3.9.0
```

Now create new project using `venv` that is a new virtual environment for your project:

```bash
  python -m venv gui
```

Now my project directory is `gui`. Change the project directory and start Visual Studio Code which is my favourite python editor.

![image-20201107231807569](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20201107231807569.png)

Now you can select the interpreter as `bin/python`. If VCS termintal is not activated with virtual enviroment, then activate:

```bash
source bin/activate
```

To upgrade pip to newest version:

```bash
python -m pip install --upgrade pip
```

Whatever you install in this virtual enviroment, is only for that enviroment.

```bash
pip install <...>
```

You will get installation as shown in the following screen:

![image-20201107232355595](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20201107232355595.png)

In the bottom left shows your selected virtual environment. For example, to start tkinter, first verify:

```bash
python -m tkinter
```

Of if you wish 

```bash
pip install pyobjc
```

which is best worked framewor [PyObjC](https://pyobjc.readthedocs.io) for you.

