---
layout: notes 
title: Powershell
---


## Calculated parameters

you can calculate the process id 1100 as follows
```
 Get-Process -id (1000 + 100)
```
Another example to exclude services start with`v` to `w` 
```
Get-Service -exclude "[v-w]*"
```
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTk3NjQ4MjkxXX0=
-->