Домашняя работа №2


Домашняя работа №1

	# uname -r
	3.10.0-1062.1.1.el7.x86_64

	yum update
	shutdown -r now
	yum install wget
	uname -r
	wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.19.66.tar.xz
	tar -xvf linux-4.19.66.tar.xz -C /usr/src/
	cd /usr/src/linux-4.19.66/
	yum groupinstall -y "Development Tools"
	yum install -y ncurses-devel openssl-devel bc elfutils-libelf-devel
	cp -v /boot/config-3.10.0-957.27.2.el7.x86_64 /usr/src/linux-4.19.66/.config
	cp -v /boot/config-3.10.0-957.12.2.el7.x86_64 /usr/src/linux-4.19.66/.config
	make oldconfig
	make
	make modules_install install
	vi /etc/default/grub
   	Меняем значение на GRUB_DEFAULT=0
	grub2-mkconfig -o /boot/grub2/grub.cfg
	uname -r
	shutdown -r now

	# uname -r
	4.19.66

Файл yum.log лежит в hw-1/yum.log

# Инструкции

* [Как начать Git](git_quick_start.md)
* [Как начать Vagrant](vagrant_quick_start.md)

## otus-linux

Используйте этот [Vagrantfile](Vagrantfile) - для тестового стенда.
