Цель: Часто в задачи администратора входит не только установка пакетов, но и сборка и поддержка собственного репозитория. Этим и займемся в ДЗ.
1) создать свой  (можно взять свое приложение, либо собрать к примеру апач с определенными опциями)
2) создать свой репо и разместить там свой 
реализовать это все либо в вагранте, либо развернуть у себя через  и дать ссылку на репо

* реализовать дополнительно пакет через 
Критерии оценки: 5 - есть репо и рпм
+1 - сделан еще и докер образ



Выполнение

Ставим необходимые пакеты для сборки:

	yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils
	yum groupinstall 'Development Tools'

создаем пользователя и даем ему права sudo:

	adduser builder
	passwd builder
	sudo usermod -a -G wheel builder

Качаем SRPM пакет NGINX и начинаем с ним работать:

	wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
	rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm

Качаем исходники для openssl:

	wget https://www.openssl.org/source/latest.tar.gz
	tar -xvf latest.tar.gz

Ставим зависимости:

	sudo yum-builddep rpmbuild/SPECS/nginx.spec

Правим spec файл и собираем RPM 

	rpmbuild -bb rpmbuild/SPECS/nginx.spec
