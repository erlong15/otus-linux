#/bin/bash

chmod 644 /home/vagrant/files/*
chmod 755 /home/vagrant/files/watchlog.sh

mv /home/vagrant/files/watchlog /etc/sysconfig/
mv /home/vagrant/files/watchlog.log /var/log/
mv /home/vagrant/files/watchlog.sh /opt/
mv /home/vagrant/files/* /etc/systemd/system/

sed -i 's/#SOCKET/SOCKET/' /etc/sysconfig/spawn-fcgi
sed -i 's/#OPTIONS/OPTIONS/' /etc/sysconfig/spawn-fcgi

echo 'OPTIONS=-f conf/first.conf' > /etc/sysconfig/httpd-first
echo 'OPTIONS=-f conf/second.conf' > /etc/sysconfig/httpd-second
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf

sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/second.conf
echo "PidFile /var/run/httpd-second.pid" >> /etc/httpd/conf/second.conf
