#!/bin/bash

#download source-packages
sudo su
cd /root
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm

rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm

wget https://www.openssl.org/source/latest.tar.gz
tar -xvf latest.tar.gz

yum-builddep rpmbuild/SPECS/nginx.spec

# building package
rpmbuild -bb rpmbuild/SPECS/nginx.spec

#install nginx from local file
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
systemctl start nginx
systemctl status nginx


# create repo
mkdir /usr/share/nginx/html/repo
# copying packages to repo
cp rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm

createrepo /usr/share/nginx/html/repo/

# modify nginx config
sed -i 's|index.htm;|index.htm;\n        autoindex on;|' /etc/nginx/conf.d/default.conf
nginx -t

nginx -s reload

curl -a http://localhost/repo/

cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo/
gpgcheck=0
enabled=1
EOF

yum repolist enabled | grep otus

yum install percona-release
