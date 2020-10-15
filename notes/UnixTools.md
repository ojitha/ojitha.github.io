---
layout: notes 
title: Unix Tools
---

## awk

The syntax is

```bash
awk '/search pattern/' <action file>
```

| No | Exmple|Description  |
| -- | -- | -- |
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

| No | Example | Description |
| -- | -- | -- |
| 1 | `sed -n 14428, 14633 <fileName>` | If you want to output the lines in the number range |
| 2 | `echo "123 abc "` | To repeats using regex |



## sort

| No   | Example                                 | Description                                 |
| ---- | --------------------------------------- | ------------------------------------------- |
| 1    | `du  /Users/ojitha/GitHub/ | sort -nr`  | to find most used disk space used directory |
| 2    | `du -h /Users/ojitha/GitHub/ | sort -h` | Human readable way                          |
|      |                                         |                                             |

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
<!--stackedit_data:
eyJoaXN0b3J5IjpbOTQxNDk0NDcwLDEzMzM4NTc3MTgsMjAwNz
gxODI5OCwxMTkxMjQ4NjE2LC0yMTEyMjQxNTY3LC0zNDE4MTk4
NjIsLTUzNjI3Njc1OSwtMTM0ODk1NDI3NCw3OTE4MzQwMTQsLT
c1NTYzODM2OCwtMTMxNDc4MDMwM119
-->