---
layout: notes 
title: macOS
mermaid: true
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

# Notes on macOS
{:.no_toc}

---

* TOC
{:toc}

---

## Shell

change the shell to zsh

```bash
chsh -s /bin/zsh
```

Edit a file in a TextEdit

```bash
open -a TextEdit ~/.zshrc
```

### Find files

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

## Tools

Here some important tools to use in the shell.

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

### Logging

For the log stream

```bash
log stream
```

To filter

```bash
log stream --predicate 'eventMessage contains "<searh word>"'
```

Filter by the specific process:

```bash
log stream  --process 153
# or
log stream --predicate '(process == <PID>)'
```

### Convert between file formats

To convert files:

```bash
textutil -convert doc textfile.rtf -output msword.doc
```

### Scriptable Image Processing System (sips)

To make the jpeg to 200 pixels wide

```bash
sips --resampleWidth 200 image_file.jpeg
```

### IP

To get current public IPv4 address:

```bash
curl -4 https://icanhazip.com/; echo
```

### Flush DNS Cache

To reset the DNS cache

```bash
sudo killall -HUP mDNSResponder
```

You have to provide root password.

### Empty Trash forcefully

Sometime it is not possible to empty the trash. Run the following command:

```bash
sudo rm -ri ~/.Trash/*
```

### Disk utitlity

```bash
diskutil list
```



### nslookup

In addition to showing you a host’s domain name or IP address, `nslookup` gives you the IP address of the DNS server i if you’re trying to diagnose a DNS problem:

```bash
nslookup ojitha.blogspot.com
nslookup ojitha.github.io
```

### Domain information

Find out what person or organization owns a domain name

```bash
whois ojitha.blogspot.com
```

### lsof

Which apps have open TCP network connections:

```bash
lsof -i
```

### 

## Terminal Commands

Find the hidden files 

```bash
defaults write com.apple.finder AppleShowAllFiles true; killall Finder
```

Change the screenshot format (`bmp`,`gif`,`pdf`,`png`,`tiff` or `jpeg`)

```bash
defaults write com.apple.screencapture type -string "jpeg"; killall SystemUIServer
```

Software updates CLI:

```bash
sudo softwareupdate -i -a
```

Here, `-i` and `-a` flags to go ahead and install every available update.

To list the last reboots:

```bash
last reboot
```

Find the uptime:

```bash
uptime
```

History of user Loggins:

```bash
last
```

To add the new user

```bash
sysadminctl -addUser <username> -fullName "<Full Name>" -password <password>
```

To change the password of the user:

```bash
sysadminctl -resetPasswordFor <username> -newPassword <new password> -passwordHint "<password hint>"
```

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



### Shortcuts

If you want to select all and only the output from the most recent command press ⌘-Shift-A.

![image-20220806200426196](/assets/images/macos/image-20220806200426196.png)



## Disk Management

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

Enable Clipboard [reddit](https://www.reddit.com/r/MacOS/comments/k149hz/universal_clipboard_and_safari_links_not_working/)

1.Run Terminal

2.Type the following to _check_ to see if ClipboardSharingEnabled is equal to zero. (if so, proceed to #3)

```bash
defaults read ~/Library/Preferences com.apple.coreservices.useractivityd.plist
```



3.Type the following to _delete_ the ClipboardSharingEnabled = 0 setting.

```bash
defaults delete ~/Library/Preferences/com.apple.coreservices.useractivityd.plist ClipboardSharingEnabled
```

4.Reboot your mac. Copy paste across devices should now work.

Alternatively, type the following to enable ClipboardSharingEnabled as the default:

```bash
defaults write ~/Library/Preferences/com.apple.coreservices.useractivityd.plist ClipboardSharingEnabled 1
```

### File sharing to Ubuntu

First enable the sharing in the Mac as explained in the [Set up file sharing on Mac](https://support.apple.com/en-au/guide/mac-help/mh17131/mac).

In the Ubuntu you can access this as follows
