#!/bin/bash
yum install epel-release -y
yum install ssmtp -y

tee /etc/ssmtp/ssmtp.conf << EOF
UseSTARTTLS=YES
FromLineOverride=YES
root=otus@iudanet.com
mailhub=smtp.gmail.com:587
AuthUser=otus@iudanet.com
AuthPass=Pass321Pass
TLS_CA_File=/etc/pki/tls/certs/ca-bundle.crt
RewriteDomain=gmail.com
Hostname=localhost
UseTLS=YES
UseSTARTTLS=YES
AuthMethod=LOGIN
EOF

/vagrant/script.sh -x 10  -y 30 -f /vagrant/access.log -mail otus@iudanet.com