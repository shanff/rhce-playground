#!/bin/bash

NAME="master"              # IPA Server hostname
DOMAIN="rhce.local"        # IPA/KRB Domain
IPAPASS="rhcelocal"        # IPA/Kerberos Admin Password
USERXPASS="secretpassword" # user1..5 password

set -x

mkdir -p /media/dvd
mount -o loop,rw /vagrant/iso/SL-7-DVD-x86_64.iso /media/dvd
semanage fcontext -a -t httpd_sys_content_t "/media/dvd(/.*)?"
restorecon -R /media/dvd
sed -i -e '#/media/dvd#/d' /etc/fstab
echo "/vagrant/iso/SL-7-DVD-x86_64.iso /media/dvd iso9660 ro,relatime,nofail 0 0" | tee -a /etc/fstab
sed -i -e 's/enabled=1/enabled=0/g' /etc/yum.repos.d/*.repo
cp -f /vagrant/files/dvd.repo /etc/yum.repos.d/.

systemctl reload dbus
systemctl restart dbus

systemctl enable NetworkManager
systemctl enable firewalld

systemctl stop NetworkManager
systemctl start NetworkManager

IFACE=eth0
IP=$(ip -o -4 a s dev $IFACE | awk '{print $4}' | awk -F/ '{print $1}') 
sed -i -e "/$NAME\.$DOMAIN/d" /etc/hosts
echo "$IP $NAME.$DOMAIN $NAME" | tee -a /etc/hosts
hostnamectl set-hostname $NAME.$DOMAIN

yum downgrade krb5-libs gssproxy nfs-utils -y
yum install ipa-server -y
yum install bind-dyndb-ldap ipa-server-dns -y

ipa-server-install --unattended --realm=$DOMAIN --ds-password="$IPAPASS" --admin-password="$IPAPASS" --setup-dns --no-forwarders

systemctl restart firewalld
firewall-cmd --permanent --add-service={http,https,ldap,ldaps,kerberos,dns,kpasswd,ntp}
firewall-cmd --reload

echo "$IPAPASS" | kinit admin

for node in node{1..2}; do 
  mkdir -p /rhce/${node}
  ipa host-add --force ${node}.$DOMAIN
  ipa service-add --force nfs/${node}.$DOMAIN
  kadmin.local ktadd nfs/${node}.$DOMAIN
  ipa-getkeytab -s ipa.rhce.local -p nfs/${node}.$DOMAIN -k /rhce/${node}/${node}.keytab
  chmod o+r /rhce/${node}/${node}.keytab
  /etc/ssl/certs/make-dummy-cert ${node}.pem
  kadmin.local -q "addprinc -randkey host/${node}.$DOMAIN"
  kadmin.local -q "ktadd –k /etc/krb5.keytab.${node} host/${node}.$DOMAIN"
done

mkdir -p /rhce/$NAME
cp -f /vagrant/files/dvd-http.repo /rhce/.
semanage fcontext -a -t httpd_sys_content_t "/rhce(/.*)?"
restorecon -R /rhce

cp -f /vagrant/files/httpd-conf.d-repo.conf /etc/httpd/conf.d/repo.conf
cp -f /vagrant/files/httpd-conf.d-rhce.conf /etc/httpd/conf.d/rhce.conf
yum install httpd-manual -y

systemctl reload httpd

# KRB5 users and hosts

DOMAINUPPER=$(echo $DOMAIN | tr a-z A-Z)
sed -i "s/EXAMPLE\.COM/$DOMAINUPPER/g" /var/kerberos/krb5kdc/kadm5.acl
systemctl restart kadmin

for user in user{1..5}; do
  ipa user-add $user \
    --shell=/bin/bash \
    --first=$user \
    --last=Rhce \
    --cn=$user \
    --displayname=$user
  kadmin.local -q "change_password -pw $USERXPASS $user"
done

