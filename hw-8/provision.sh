#!/bin/bash

#task-1

cp /vagrant/watchlog /etc/sysconfig/
cp /vagrant/watchlog.log /var/log/
cp /vagrant/watchlog.sh /opt/ 
cp /vagrant/watchlog.service /etc/systemd/system/
cp /vagrant/watchlog.timer /etc/systemd/system/
chmod +x /opt/watchlog.sh

systemctl daemon-reload
systemctl enable watchlog.timer
systemctl enable watchlog.service
systemctl start watchlog.timer
systemctl start watchlog.service


#task-2

yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y

sed -i 's/#SOCKET/SOCKET/' /etc/sysconfig/spawn-fcgi
sed -i 's/#OPTIONS/OPTIONS/' /etc/sysconfig/spawn-fcgi

cp /vagrant/spawn-fcgi.service /etc/systemd/system/spawn-fcgi.service

systemctl daemon-reload
systemctl enable spawn-fcgi
systemctl start spawn-fcgi

#task-3

cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service

sed -i '/^EnvironmentFile/ s/$/-%I/' /etc/systemd/system/httpd@.service
echo "OPTIONS=-f conf/httpd-1.conf" > /etc/sysconfig/httpd-1

echo "OPTIONS=-f conf/httpd-2.conf" > /etc/sysconfig/httpd-2

cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd-1.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd-2.conf

mv /etc/sysconfig/httpd /etc/sysconfig/httpd.backup

sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd-2.conf
sed -i '/ServerRoot "\/etc\/httpd"/a PidFile \/var\/run\/httpd-2.pid' /etc/httpd/conf/httpd-2.conf

systemctl disable httpd
systemctl daemon-reload
systemctl start httpd@1
systemctl start httpd@2
