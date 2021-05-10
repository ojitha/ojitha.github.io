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
if you  want only the file name:
```bash
Select-String -Path .\*.log -Pattern '<regex>'   |  foreach {$_.Filename} | select -Unique
```
when executed, you will get all the strings matching wit the regex in the `<file-name>.log.*` files.

## Tail
Here the Unix `tail` equivalent:

```bash  
 Get-Content .\<log file name>.log -Tail 4 -Wait
 ```
## WSL 2
You can install [WSL 2](https://docs.microsoft.com/en-us/windows/wsl/install-win10), but first step you have to elevate Powershell as follows after open with "Run as DefendPoint Admin":
```bash
start-process powershell –verb runAs
```
As explained in the https://serverfault.com/questions/11879/gaining-administrator-privileges-in-powershell.

AWS installation : [Developing on Amazon Linux 2 using Windows](https://aws.amazon.com/blogs/developer/developing-on-amazon-linux-2-using-windows/)
### Uninstall
first find the Linux version you are using:
```bash
wslconfig /l
```
Then uninstall:
```bash
wslconfig /u Amazon2
```
### Install
Set the default to WSL 2
First update to the [WSL2 Linux kernel update package for x64 machines](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi). then set to the version 2:
```bash
 wsl --set-default-version 2
```
Download [Amazon Linux 2](https://github.com/yosukes-dev/AmazonWSL/releases/download/2.0.20200722.0-update.2/Amazon2.zip) and extract to the `c:\wsl` folder.
 


<!--stackedit_data:
eyJoaXN0b3J5IjpbMTU0MTc3NzU4OSwxMzgzNjA4Njg1LC0xMz
Q5NzgxNDE5LC0xMzQ1ODg3MDk2LDEyNDkzMDM4MTQsLTI1NDg2
MjM0Nyw4MTM1NTA3MSw1NTI1MzIxNDcsMTAzOTc0NTQ1NSwtMT
U0MTQzODIxMiwxNzcxODAwODg0LDc3MjU2NTQ0N119
-->