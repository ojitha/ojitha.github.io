---
layout: notes 
title: Unix Tools
---

## Sed use
G

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
eyJoaXN0b3J5IjpbLTEzMTQ3ODAzMDNdfQ==
-->