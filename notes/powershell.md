---
layout: notes 
title: Powershell
---

**Notes on Windows PowerShell**

* TOC
{:toc}

## Syntax
Here the syntax for the commandlet.
```powershell
Verb-noun [-parameter list]
```
Above commandlet is not sensitivities.
For example similar to UNIX `pwd` is:
```powershell
Get-Location
```

## Parameters

Parameters can be positional or with the name such as `Filter`:
```powershell
 Get-ChildItem 'C:\Local\xxxx\forms' -Filter *.pdf
```
 This will shows only the PDF files.
 
## Calculated parameters

you can calculate the process id 1100 as follows
```powershell
 Get-Process -id (1000 + 100)
```
Another example to exclude services start with`v` to `w` 
```powershell
Get-Service -exclude "[v-w]*"
```
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTU2MDk1MTE0MywxNzcxODAwODg0LDc3Mj
U2NTQ0N119
-->