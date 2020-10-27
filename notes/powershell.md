---
layout: notes 
title: Powershell
---
## Syntax
Here the syntax for the commandlet.
```powershell
Verb-noun [-parameter list]
```
Above commandlet is not sensitivities.

## Parameters
Parameters can be positional as follows
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
eyJoaXN0b3J5IjpbOTM4MzIzNzgsMTc3MTgwMDg4NCw3NzI1Nj
U0NDddfQ==
-->