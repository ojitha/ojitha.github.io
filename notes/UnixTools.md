---
layout: notes 
title: Unix Tools
---
**Notes on UNIX tools**

* TOC
{:toc}
## Mac terminal

### shortcut keys

[My 5 Favorite Linux Shell Trickes for SPEEEEED](https://youtu.be/V8EUdia_kOE)

| Command  | Purpose                                          |
| -------- | ------------------------------------------------ |
| Ctrl+l   | Clear the screen                                 |
| Ctrl+a   | Move to begining of the line                     |
| Ctrl+e   | Got to the end of the line                       |
| Ctrl+k   | cut rest of the line contents                    |
| Ctrl+u   | cut completely before the current position       |
| Ctrl+y   | Get the cut text back                            |
| Ctrl+w   | delete word by word backward                     |
| Ctrl+x+e | Open in text editor while typing in the terminal |



## awk

Sed is the flip side of interactive editor such as vi. Therefore sed is limited to editor, but aws is a proramming language and provide more control over processin files. 

The standard syntax is `awk 'instructions' <files>`. The `awk -f <script> <files>` is the syntax for script files.

> Default `awk` field separator is either spaces or tabs. To change the file separator use the option `-F`.

NOTE: awk is using the same metacharacters supported by egrep.

Options:

`-F`: file separator

`-f`: script separator

`-v`: This is for the parameters such as `var=value`

| No | Exmple|Description  |
| -- | -- | -- |
| 1 | `awk -F, '/pattern/ { print $1; print $2}' <files>` |Output the matching lines only |
| 1 |  `awk 'NR == 14428, NR == 14633 { print NR, $0}' <fileName>` | Print range of lines with  line numbers |
| 2 | `echo -e 'first,last\nojitha,kumanayaka\nMark,Athony\nMichael,Yass'  | awk -F ',' '{print $1}'` | To get the first column |
| 3 | `echo -e 'first,last\nojitha,kumanayaka\nMark,Athony\nMichael,Yass'  | awk -F ',' -v OFS='|' '{print $2,$1}'` | To exchange the columns. Eg: `print $(NF -1)}` mean total columns reduce by one. |


## cut

| No   | Example                                       | Description                                                  |
| ---- | --------------------------------------------- | ------------------------------------------------------------ |
| 1    | `cut -c 2 t.txt`                              | Get the first letter vertically                              |
| 2    | `cut -c 2-6 t.txt`                            | Get the letter from position 2 up to the postion 6 vertically. |
| 3    | `cut -c 2- t.txt`                             | Get the rest starting from the position 2.                   |
| 4    | `echo -e 'one\ttwo\tthree' | cut -f 1`        | if tab separated you can use field                           |
| 5    | `echo -e 'one,two,tthree'  | cut -d ',' -f 3` | to get the comma separated field.                            |



## grep

| No   | Example                                                      | Description          |
| ---- | ------------------------------------------------------------ | -------------------- |
| 1    | `echo -e 'first,last\nojitha,kumanayaka\nMark,Athony\nMichael,Yass' | grep -v ^first,last$` | You will give you what doesn't match. |
| 2 | `echo -e 'first,last\nojitha,kumanayaka\nMark,Athony\nMichael,Yass'  | grep -Ev 'oj|Yass'` | To avoid lines based on *OR*. Eg: This command will remove ojitha and Yass both lines. |
| 3 | `grep -c 'smoething' <filename>` | Count number of lines occurred the something. |


## less

| No | Exmple|Description  |
| -- | -- | -- |
| 1 | `less -N <fileName>` | Show line numbers |

## sed 

Sed is a non-interactive stream-oriented editor.

Syntax is `sed [-e] <instruction> file` and `-e` for more than one instruction to be executed. The `sed -f scriptfile file` is the way to apply commands via `scriptfile`. 

Options:

`-n`: default is display all the input lines as output. This opton suppress that and work with `p` (see the 3rd example in the table bellow) option to display the output

`-f`: script file

`-e`: instructions

NOTE: sed is using same set of metacharacters used by the grep.

| No | Example | Description |
| -- | -- | -- |
| 1 | `sed -n '14428,14633p' <file>` | If you want to output the lines in the number range |
| 2 | `sed 's/<source>/<target>/' <file>` | Substitute source with target |
| 3 | sed -n -e '.../p' | display only the affected lines |

> Sed applies the entire script to the first input before move to second line of the input. Therefore you cannot depends on the previous line values because which are already changed by the script.



## sort

| No   | Example                                 | Description                                 |
| ---- | --------------------------------------- | ------------------------------------------- |
| 1    | `du  /Users/ojitha/GitHub/ | sort -nr`  | to find most used disk space used directory |
| 2    | `du -h /Users/ojitha/GitHub/ | sort -h` | Human readable way                          |
| 3    |` cat <file> | sort -t ':' -k 3 `      | sort on field 3 where field separator found by `;` |


Option `u`: unique



## Networking

To get the port numbers for UDP, TCP and listing ports

First remove first tow lines:
```bash
netstat -nutl | egrep -Ev '^Active|^Proto'
```
or
```bash
netstat -nutl | grep ':'
```
To get the host and the port:
```bash
netstat -nutl | grep ':' | awk '{print $4}'
```
to print only the ports
```bash
netstat -nutl | grep ':' | awk '{print $4}' | awk -F ':' '{print $NF}'
```
or 
```bash
netstat -nutl | grep 'tcp' | awk '{print $4}' | cut -d':' -f 2
```
Unique ports
```bash
netstat -nutl | grep 'tcp' | awk '{print $4}' | awk -F ':' '{print $NF}' | sort -n | uniq -c
```

For the listening ports
```bash
netstat -nutlp | grep 'tcp'
```

## SFTP Data transfer

To connect to the SFTF site:

```bash
sftp -o IdentityFile=live-lessons.pem sftpuser@ec2-54-252-168-81.ap-southeast-2.compute.amazonaws.com
```

Install AWS Chalice

```bash
sudo yum groupinstall -y "development tools"
```

next 

```bash
sudo yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel expat-devel
```

download and install python 2.7.13

```bash
wget http://python.org/ftp/python/2.7.13/Python-2.7.13.tar.xz
tar xf Python-2.7.13.tar.xz
cd Python-2.7.13
./configure --prefix=/usr/local --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
make 
sudo make altinstall
```

to optimize

```bash
strip /usr/local/lib/libpython2.7.so.1.0
```

create links

```shell
sudo ln -sf /usr/local/bin/python2.7 /usr/bin/python2.7
```

download pip:

```bash
curl -O https://svn.apache.org/repos/asf/oodt/tools/oodtsite.publisher/trunk/distribute_setup.py
```

install pip

```bash
sudo python2.7 distribute_setup.py
sudo easy_install pip
```

Install virtual environment

```bash
sudo pip2.7 install virtualenv
```

Install Chalice

```shell
virtualenv ~/.virtualenvs/chalice
```

activate the environment each and every time when new terminal open

```bash
source ~/.virtualenvs/chalice/bin/activate
```

but only once install the AWS Chalice

```bash
pip install chalice
```

Now create the project you want

```bash
chalice new-project <project name>
```

Install paramiko

```bash
pip install paramiko
```

following libs are installed

asn1crypto-0.22.0 cffi-1.10.0 cryptography-1.8.1 enum34-1.1.6 idna-2.5 ipaddress-1.0.18 paramiko-2.1.2 pyasn1-0.2.3 pycparser-2.17

