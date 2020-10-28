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
Here the way to semantically diff the XML files:
First create your project
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
to deactivate, `deactivate` in the CLI to move out from the project environment.

<!--stackedit_data:
eyJoaXN0b3J5IjpbMTY1OTU2MTMwMCwxNDI0MDIwNjRdfQ==
-->