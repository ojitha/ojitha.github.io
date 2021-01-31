---
layout: post
title:  Hortonworks 3 Installation
date:   2021-01-31
categories: [Hadoop]
---

I was using Hortonworks 2.x.x for a long time for my learning. This blog was written to explain how to install [HDP3](https://docs.cloudera.com/HDPDocuments/HDP3/HDP-3.1.0/release-notes/content/relnotes.html) (version 3.1.0) on Ubuntu 20.10.

<!--more-->

To access the VM from the external computers but in the same network, you have to change the Network adaptor to bridge with the physical network as follows:

![image-20210131183447224](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20210131183447224.png)

Install [open-vm-tools](https://docs.vmware.com/en/VMware-Tools/11.2.0/com.vmware.vsphere.vmwaretools.doc/GUID-C48E1F14-240D-4DD1-8D4C-25B6EBE4BB0F.html) first. In the CentOS:

```bash
sudo yum install open-vm-tools
```

To share folder create a shared folder in your local machine and map

![image-20210131163117878](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20210131163117878.png)

Now create a directory.

```bash
mkdir /tmp/mydocs
```

Map this to your local directory

```bash
/usr/bin/vmhgfs-fuse .host:/mydocs /tmp/mydocs -o subtype=vmhgfs-fuse,allow_other                              
```

To show the swap partition:

```bash
swapon --sh
```

![image-20210131184442903](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20210131184442903.png)

For VMware Workstation, you need to have 5GB of swap partition as shown in the above.