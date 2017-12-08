NODE=$(hostname)

ip r flush 0/0

# mkdir -p /media/dvd
# mount -o loop,rw /vagrant/SL-7-DVD-x86_64.iso /media/dvd
# cp /vagrant/dvd.repo /etc/yum.repos.d/.

sed -i -e 's/enabled=1/enabled=0/g' /etc/yum.repos.d/*.repo
rm -f /etc/yum.repos.d/dvd-http.repo

# curl -o /etc/yum.repos.d/dvd-http.repo http://master/rhce/dvd-http.repo

cat<<EOF | sudo tee /etc/yum.repos.d/dvd-http.repo
[dvd-http]
name=Scientific Linux $slreleasever - $basearch on Master
baseurl=http://master/repo/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-sl file:///etc/pki/rpm-gpg/RPM-GPG-KEY-sl7
EOF

yum clean all
yum makecache fast

curl -o krb5.keytab http://master/rhce/${NODE}/krb5.keytab.${NODE}

cp krb5.keytab /etc/krb5.keytab

# sudo yum downgrade glibc-headers glibc glibc-common glibc-devel -y

yum install pam_krb5 -y nss-pam-ldapd
authconfig --update --ldapserver=master --enableldap --enableldapauth --ldapbasedn="ou=rhce,ou=local" --enablekrb5 --krb5kdc=master --krb5realm=RHCE.LOCAL --enablemkhomedir
