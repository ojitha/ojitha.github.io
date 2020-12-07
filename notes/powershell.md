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
If you want to get all the aliases available for the commandlet, for example Get-Process:
```powershell
Get-Alias | Where-Object { $_.definition -eq "get-process"}
```
You can create new alias with `Set-Alias` or `New-Alias`.
```powershell
Set-Alias xxx Get-xxxx
New-Alias yyy Get-yyyy
```
> NOTE: `Set-Alias overwrite the existing alias. `New-Alias` will fail if the alias is already exists. You can use the `-description` to create the note.

You can use `Set-Alias to create alias for the application as well.
```powershell
 Set-Alias np C:\LocalDev\npp.7.8.bin\notepad++.exe
```
Now the alias `np` you can use to open any file in the CLI.



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

## Grep 
I need to find all the lines of all the files where the particular string is exists using Select-String:
```bash
Select-String -Path .\<file name>.log.* -Pattern "-511055-141"
```
Here the way to extract all the strings which are matched with the regex `TEST0002H-.*-[0-9].?` :
```bash
Select-String -Path .\<file-name>.log.* -Pattern "TEST0002H-.*-[0-9].?" -AllMatches |  % { $_.Matches } | % {$_.Value } | select -Unique
```
if you  want only the file name only
```bash
Select-String -Path .\*.log -Pattern '<regex>'   |  foreach {$_.Filename} | select -Unique
```
when executed, you will get all the strings matching wit the regex in the `<file-name>.log.*` files.

## Tail
Here the Unix `tail` equivalent:

```bash  
 Get-Content .\<log file name>.log -Tail 4 -Wait
 ```

<!--stackedit_data:
eyJoaXN0b3J5IjpbNTgwNDIyNDU0LDEyNDkzMDM4MTQsLTI1ND
g2MjM0Nyw4MTM1NTA3MSw1NTI1MzIxNDcsMTAzOTc0NTQ1NSwt
MTU0MTQzODIxMiwxNzcxODAwODg0LDc3MjU2NTQ0N119
-->