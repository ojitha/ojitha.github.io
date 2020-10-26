---
layout: notes 
title: Powershell
---
## Syntax
Here the syntax for the commandlet.
```powershell
Verb-noun [-parameter list]
```

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
eyJoaXN0b3J5IjpbMTAxMzU3NzIzMyw3NzI1NjU0NDddfQ==
-->