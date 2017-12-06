# rhce-playground

RHCE Vagrant environment for EX300 preparation

# Quick start

1. Requirements: `vagrant`, `libvirt`

Fedora:

		$ sudo dnf install vagrant vagrant-libvirt

1. Get a scientific-linux vagrant box (minimal installation)

You can prepare one using [vagrant-sl7-libvirt](https://github.com/policorn/vagrant-sl7-libvirt) repo:

		$ git clone https://github.com/policorn/vagrant-sl7-libvirt
		$ cd vagrant-sl7-libvirt
		$ make ISOPATH=../iso/SL-7-DVD-x86_64.iso
		$ make vagrantbox
		$ make install
		$ make clean

1. Prepare the environment: 

		$ make

1. Boot the master (Kerberos, LDAP & software repo)

		$ vagrant up master

1. Boot the nodes (prepare the exam on these)

		$ vagrant up node{1..2}

Each node box has:

- Minimal installation
- Working Yum repo already in place (served by `master` instance)
- `keytab` files in /etc
- kerberos authentication enabled
- selinux is enabled
- Additional network interfaces to practice the configuration of bond/team connections

Master node runs IPA services. Users: `user1`..`user5` with password `secretpassword`

IPA admin principal: `admin@RHCE.LOCAL` password: `rhcelocal`

# What do you need? (to prepara EX300)

Probably these:

- Working AD/LDAP
- HTTP server to serve:
	- SSH keys
	- kinit files
	- realm files
	- SSL certs

To get this setup, I'm using Vagrant + libvirt

# ISO

We need the RH/CentOS/SL ISO file to prepare a repo server in Master node. 

I used Scientific Linux 7 ISO, downloaded from [http://ftp1.scientificlinux.org/linux/scientific/7.0/x86_64/iso/](http://ftp1.scientificlinux.org/linux/scientific/7.0/x86_64/iso/). The provision script expects the ISO file to be located in `iso/SL-7-DVD-x86_64.iso`

	mkdir -p iso
	wget -O iso/SL-7-DVD-x86_64.iso http://ftp1.scientificlinux.org/linux/scientific/7.0/x86_64/iso/SL-7-x86_64-Everything-Dual-Layer-DVD.iso

or simply:

	make

# How? Show me!

Install FreeIPA (IPA Server) - [https://www.lisenet.com/2016/freeipa-server-on-rhel-7-centos-7/](https://www.lisenet.com/2016/freeipa-server-on-rhel-7-centos-7/)

	yum install ipa-server -y 
	echo "10.0.2.15 master.rhce.local ipa" | tee -a /etc/hosts
	hostnamectl set-hostname master.rhce.local
	ipa-server-install -U -r rhce.local -p rhcelocal -a rhcelocal
	firewall-cmd --permanent --add-service={http,https,ldap,ldaps,kerberos,dns,kpasswd,ntp}
	firewall-cmd --reload
	kinit admin
	ipa host-add --force nodeX.rhce.local
	ipa service-add --force nfs/nodeX.rhce.local
	kadmin.local ktadd nfs/nodeX.rhce.local
	ipa-getkeytab -s master.rhce.local -p nfs/nodeX.rhce.local -k ~/nodeX.keytab
	chmod o+r ~/nodeX.keytab

This is a general idea, you can find the actual steps in `files/Provisionfile-master.sh` file 

# Exam Ideas

(Work in progres...)

- Apache
	- Install 
	- Listen on alternate port
	- Create VHOST
	- Create other VHOST with SSL support

- Samba
	- Share folder with samba

- MariaDB
	- Install server on node2
	- Install MariaDB Client on node1 and query node2's DB remotely
	- Create users
	- Create database, tables and entries
	- Query them
	- Create dump/backup
	- Drop database
	- Restore database

- NFS
	- Share volume in node2 and mount it in node1 using Kerberos credentials

- DNS
	- Create DNS Caching resolver

- ISCI
	- Share file as block device
	- Export LUN and mount it on the other server

- Teaming
	- Create new team device using 2 physical devices on node1
	- Configure IPv6 and ping node2

- Firewalld
	- Masquerade traffic on interface #3

- Remote logging
	- Configure node1 logs to be forwarded to master

- Postfix
	- Configure postfix in node1 and node2
	- Send local mail from tom@node1 to shane@node1. Create a rule to forward it to shane@node2. 
	- Send mail to jane@node2 and get it forwarded to root@master
	- Send mail to tom@example.com and get it forwarded to tom@node2

# References

- [policorn/vagrant-sl7-libvirt](https://github.com/policorn/vagrant-sl7-libvirt) - Builds Scientific Linux 7 Vagrant box for libvirt provider
- [https://www.lisenet.com/tag/rhce/](https://www.lisenet.com/tag/rhce/) - Cool guides/nodes for RHCE preparation!

