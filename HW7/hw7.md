### Homework 7. ССоздание своего rpm-пакета

Все скрипты выполняются при запуске вагранта
1. устанавливаются пакеты (помимо тех, что уже были прописаны в вагрантфайле) redhat-lsb-core openssl-devel pcre-devel, zlib-devel
без них сборка не проходила

2. загрузка srpm пакета nginx (rpm пакет с исходниками)
````
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm

````

3. из под рута устанавливаем пакет, ставится в домашнюю директорию текущего пользователя (проверял сдругим  пользователем, распаковывать в /home/vagrant, но в итоге пакет все равно соберется только рутом и в /root, так что лучше все сразу там делать)
````
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
````

4. скачивание и распаковка исходников openssl
```
wget https://www.openssl.org/source/latest.tar.gz

tar -xvf latest.tar.gz
```
5. установка всех зависимых пакетов. Зависимости прописаны в spec- файле, в /root/rpmbuild/SPECS/nginx.spec
````
yum-builddep rpmbuild/SPECS/nginx.spec
````


6. правка файла nginx.spec c помощью утилиты sed (меняем "ненужную" строку --with-debug на нужную нам). в учебных материалах сделано так же. 
```
sed -i 's|--with-debug|--with-openssl=/home/vagrant/openssl-1.1.1d|' rpmbuild/SPECS/nginx.spec
```
7. сама сборка rpm-пакета

````
rpmbuild -bb rpmbuild/SPECS/nginx.spec
````

8. пакет должен появиться в /root/rpmbuild/RPMS/x86_64. можно проверить это с помощью ll 

9. локальная установка пакета (на всякий случай можно перед этим удалить случайно заранее установленный)
````
yum remove -y nginx
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
systemctl start nginx
systemctl status nginx

````

10. создание своего репозитория. у этого сервера по умолчанию папка для статичных файлов /usr/share/nginx/html. Создать там папку repo, скопировать созданный пакет, и  какой-ниубдь сторонний
````
mkdir /usr/share/nginx/html/repo
cp rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/

wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm

````

11. инициализация репозитория - команда createrepo

```
createrepo /usr/share/nginx/html/repo/
```

12. Добавили директиву autoindex on; в кофниг nginx /etc/nginx/conf.d/default.conf. проверка синтакиса и перезапуск сервера

```
sed -i 's|index.htm;|index.htm;\n        autoindex on;|' /etc/nginx/conf.d/default.conf

nginx -t

nginx -s reload
```

13. просмотр репозитория 

```
curl -a http://localhost/repo/
```

14. добавление в список репозиториев менеджера yum

```
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
```

15. проверка списокв репозиториев yum и установка percona-release из своего репозитория
````
yum repolist enabled | grep otus

yum install percona-release-noarch
````

16. 