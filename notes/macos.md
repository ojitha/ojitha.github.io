---
layout: notes 
title: macOS
---


## macOS tools

change the shell to zsh

```bash
chsh -s /bin/zsh
```

Edit a file in a TextEdit

```bash
open -a TextEdit ~/.zshrc
```

Find the file names only with the text recusively

```bash
grep -il -r --include "*.py" 'text' .
```

Find all the files with wild card recursively:

```bash
find . -name "*.pyc" -exec ls {} \;
```

Another recursive example with include and exclude directory:

```bash
grep -rI --include='*.py'  --exclude-dir='lib' "S3Service" *
```

To show all the CHAPTERS:

```bash
grep -i chapter novel.txt
```

Cut only the chapter headings

```bash
grep -i chapter novel.txt | cut -d' ' -f3-
```

Read the line where CHAPTER contains but start with 'the' in the novel.txt.

```bash
grep -E '^CHAPTER (.*)\. The' novel.txt
```

Every word more 5 or more characters

```bash
grep -oE '\w{5,}' novel.txt
```

In the redhat to start the firewall GUI, type the following command:

```bash
sudo system-config-firewall
```

Here the way to validate xml file for schema and generate the report

```bash
	xmllint  --noout --valid --schema UserCentralClients.xsd sample2.xml > error.txt 2>&1
```

noout will stop xml written to the error.txt. 

### awk

Commandline

```bash
awk -F, '{$2="***"; print $1 $2}'  test.txt
```

Above logic in the file called f:

```bash
awk -F, -f t test.txt 
```

Both the above commands produce the same.

here the contents of the f file:

```bash
BEGIN {
  print "1 st \t 2nd"
  print "==== \t ==="
}

{
  $2="***";
  print $1 "\t" $2
}

END{
  print "the end"
}

```

### Brew

List installed packages

```bash
brew list -1
```

### Terminal Commands

Find the type of the command

```bash
type -a pwd
```

create tar file

```bash
tar -czvf mylogs.tar.gz logs-*.log
```

find the directory in the Unix

```shell
find / -type d -name 'pyve*' 2>&1 | grep -v "Permission denied"
#or
find . -type d -name 'pyve*'  2>/dev/null
```

filter the file lines:

```bash
sed -n '1 , 3 p' my.txt > test.txt
```

Top occurrence words in a page

```bash
curl -s http://www.gutenberg.org/files/4300/4300-0.txt | tr '[:upper:]' '[:lower:]' | grep -oE '\w+' | sort | uniq -c | sort -nr | head -n 10
```

Use of Python as command line tool

```python
#!/usr/bin/env python
from sys import stdin, stdout
while True:
    line = stdin.readline()
    if not line:
        break
    stdout.write("%d\n" % int(line))
    stdout.flush()
```

Above will display the lines generated from the sequence. 

```bash
#permission
chmod u+x stream.py

#create the pipeline
seq 1000 | ./stream.py
```

Substitute seq

```bash
seq -f "Line %g" 10
```

Here the equlents, lines is a file

```
< lines head -n 3
< lines sed -n 1,3p
< lines awk 'NR<=3'
```

### Disk Management

To display size of the folder

```bash
du -hsx *
```

this will display the usage of the directory.
The following code show the top 20 files which used most of the file space

```bash
du -a | sort -n -r | head -n 20
```

This will show directory wise usage of file space

```bash
du -hsx * | sort -n -r | head -n 20
```

Here

>  - du command -h option : display sizes in human readable format.
>  - du command -s option : show only a total for each argument (summary).
>  - du command -x option : skip directories on different file systems.