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
The alias for the above command is `pwd`. All the aliases can be found as follows:
```powershell
Get-Alias
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
The short form for the above commandlet is `ps`.

Another example to exclude services start with`v` to `w` 
```powershell
Get-Service -exclude "[v-w]*"
```
<!--stackedit_data:
eyJoaXN0b3J5IjpbNzk5MzQ0MjA3LDE3NzE4MDA4ODQsNzcyNT
Y1NDQ3XX0=
-->