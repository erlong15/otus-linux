# VPN

## Домашнее Задание

```txt
VPN
1. Между двумя виртуалками поднять vpn в режимах
- tun
- tap
Прочуствовать разницу.

2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку

3*. Самостоятельно изучить, поднять ocserv и подключиться с хоста к виртуалке 
```

## установка Ansible

```bash
cd HW_22
python3.8 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
    ```

## Режим tun

### Настройка стенда

```bash
source venv/bin/activate
make install-tun
```

```bash
[vagrant@client ~]$ iperf3 -c 10.10.10.1 -p 5001 -i 2 -t 10
Connecting to host 10.10.10.1, port 5001
[  4] local 10.10.10.2 port 44468 connected to 10.10.10.1 port 5001
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-2.00   sec  44.1 MBytes   185 Mbits/sec   23    525 KBytes       
[  4]   2.00-4.01   sec  48.3 MBytes   202 Mbits/sec    0    626 KBytes       
[  4]   4.01-6.01   sec  48.7 MBytes   204 Mbits/sec    1    505 KBytes       
[  4]   6.01-8.00   sec  45.3 MBytes   191 Mbits/sec  456    314 KBytes       
[  4]   8.00-10.00  sec  47.8 MBytes   200 Mbits/sec    0    410 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec   234 MBytes   196 Mbits/sec  480             sender
[  4]   0.00-10.00  sec   233 MBytes   195 Mbits/sec                  receiver

iperf Done.
[vagrant@client ~]$ ip link show 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:d4:97:46 brd ff:ff:ff:ff:ff:ff
8: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN mode DEFAULT group default qlen 100
    link/none 
```

## Режим tap

* Настройка стенда

```bash
source venv/bin/activate
make install-tap
```

```bash
[vagrant@client ~]$ iperf3 -c 10.10.10.1 -p 5001 -i 2 -t 10
Connecting to host 10.10.10.1, port 5001
[  4] local 10.10.10.2 port 44464 connected to 10.10.10.1 port 5001
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-2.01   sec  45.3 MBytes   189 Mbits/sec    0    884 KBytes       
[  4]   2.01-4.01   sec  48.4 MBytes   203 Mbits/sec    0    884 KBytes       
[  4]   4.01-6.01   sec  49.0 MBytes   205 Mbits/sec    0    884 KBytes       
[  4]   6.01-8.00   sec  48.8 MBytes   205 Mbits/sec    0    884 KBytes       
[  4]   8.00-10.00  sec  45.1 MBytes   189 Mbits/sec    0    884 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec   237 MBytes   198 Mbits/sec    0             sender
[  4]   0.00-10.00  sec   236 MBytes   198 Mbits/sec                  receiver
iperf Done.
[vagrant@client ~]$ ip link show 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:d4:97:46 brd ff:ff:ff:ff:ff:ff
7: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN mode DEFAULT group default qlen 100
    link/ether ba:d4:43:f9:78:43 brd ff:ff:ff:ff:ff:ff
```

## Заметная разница

* Видна разницу в количестеве retray. Для tap режима ровно нулю.
* TAP эмулирует Ethernet устройство и работает на канальном уровне модели OSI, оперируя кадрами Ethernet.
* TUN (сетевой туннель) работает на сетевом уровне модели OSI, оперируя IP пакетами. TAP используется для создания сетевого моста, тогда как TUN для маршрутизации.


## easy-rsa

```txt
[root@server ~]# mkdir -p /etc/openvpn/easy-rsa/keys
[root@server ~]# cp -rf /usr/share/easy-rsa/3 /etc/openvpn/easy-rsa
[root@server ~]# cd /etc/openvpn/easy-rsa/
[root@server easy-rsa]# touch vars
[root@server easy-rsa]# vi vars 
[root@server easy-rsa]# chmod +x vars
[root@server easy-rsa]# ./easyrsa init-pki

Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/vars

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /etc/openvpn/easy-rsa/pki


[root@server easy-rsa]# ./easyrsa build-ca

Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017

Enter New CA Key Passphrase: 
Re-Enter New CA Key Passphrase: 
Generating RSA private key, 4096 bit long modulus
...................................................................++
.......++
e is 65537 (0x10001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/etc/openvpn/easy-rsa/pki/ca.crt


[root@server easy-rsa]# 

[root@server easy-rsa]# ./easyrsa gen-req srv-openvpn nopass

Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating a 4096 bit RSA private key
.................................................................++
..............................................................................................................................................++
writing new private key to '/etc/openvpn/easy-rsa/pki/easy-rsa-4295.EA9Gag/tmp.SlELZM'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [srv-openvpn]:

Keypair and certificate request completed. Your files are:
req: /etc/openvpn/easy-rsa/pki/reqs/srv-openvpn.req
key: /etc/openvpn/easy-rsa/pki/private/srv-openvpn.key


[root@server easy-rsa]# ./easyrsa sign-req server srv-openvpn

Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a server certificate for 3650 days:

subject=
    commonName                = srv-openvpn


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from /etc/openvpn/easy-rsa/pki/easy-rsa-4322.Ym2afq/tmp.TLwLQP
Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key:
140281193863056:error:28069065:lib(40):UI_set_result:result too small:ui_lib.c:831:You must type in 4 to 1023 characters
Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key:
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'srv-openvpn'
Certificate is to be certified until Dec 20 08:12:35 2030 GMT (3650 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /etc/openvpn/easy-rsa/pki/issued/srv-openvpn.crt

[root@server easy-rsa]# openssl verify -CAfile pki/ca.crt pki/issued/srv-openvpn.crt
pki/issued/srv-openvpn.crt: OK
[root@server easy-rsa]# 
```

### создаем клиента

```txt
[root@server easy-rsa]# ./easyrsa gen-req client-01 nopass

Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating a 4096 bit RSA private key
......++
..........................................++
writing new private key to '/etc/openvpn/easy-rsa/pki/easy-rsa-4396.pnjXPm/tmp.qSTAtI'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [client-01]:

Keypair and certificate request completed. Your files are:
req: /etc/openvpn/easy-rsa/pki/reqs/client-01.req
key: /etc/openvpn/easy-rsa/pki/private/client-01.key


[root@server easy-rsa]# ./easyrsa sign-req client client-01

Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a client certificate for 3650 days:

subject=
    commonName                = client-01


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from /etc/openvpn/easy-rsa/pki/easy-rsa-4423.5XVxbj/tmp.vx7JQL
Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key:
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'client-01'
Certificate is to be certified until Dec 20 08:14:28 2030 GMT (3650 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /etc/openvpn/easy-rsa/pki/issued/client-01.crt


[root@server easy-rsa]# openssl verify -CAfile pki/ca.crt pki/issued/client-01.crt
pki/issued/client-01.crt: OK
[root@server easy-rsa]# 
```

### дополнительная натсрйока

```txt
[root@server easy-rsa]# ./easyrsa gen-dh

Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating DH parameters, 4096 bit long safe prime, generator 2
This is going to take a long time
.....

DH parameters of size 4096 created at /etc/openvpn/easy-rsa/pki/dh.pem

[root@server easy-rsa]# ./easyrsa gen-crl

Note: using Easy-RSA configuration from: /etc/openvpn/easy-rsa/vars
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Using configuration from /etc/openvpn/easy-rsa/pki/easy-rsa-4489.LQcAvx/tmp.K7TeMQ
Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key:

An updated CRL has been created.
CRL file: /etc/openvpn/easy-rsa/pki/crl.pem


```

## Натсройка RAS

* Настройка стенда

```bash
source venv/bin/activate
make install-ras
```

* запуск подключения к витуалке

```bash
make openvpn-client-start
```
