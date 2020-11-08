---
layout: notes
title: Productivity Tools
---
<script src="https://unpkg.com/mermaid@8.0.0/dist/mermaid.min.js"></script>

**Notes on Productivity tools**

* TOC
{:toc}

## Diagramming
I was very enthustic to know markdown level diagraming.

### mermaid
One of the best so far found is [mermaid](https://mermaid-js.github.io/mermaid/#/) which I cause use with the my blog tool stackedit.io. For example:

<div class="mermaid">
graph TD;
    A-->B;
    A-->C;
    B-->D;
    C-->D;
</div>

such a great diagraming.

## XML
Tools for XML
### Diff
To setup complete python environment, see the [Python my workflow](https://ojitha.blogspot.com/2020/09/python-my-workflow.html).

Here the way to semantically diff the XML files:
First create your project in Python virtual enviroment:
```bash
python3 -m venv xmltest
cd xmltest
source bin/activate
```
You project is `xmltest`. Now install the graphtage packate
```bash
pip install graphtage
```
now you are ready to compare m1.xml and p1.xml files:
```bash
graphtage p1.xml m1.xml
```
This will give you a out put to CLI.
to deactivate, `deactivate` in the CLI to move out from the project environment. For more information see the post "[How to run python GUI in MacOS]({% link _posts/2020-11-07-python-gui-mac.md %})" for macOs.
