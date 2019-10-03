Домашняя работа №3

1. Выполнил домашнюю работу, файл лога положил в директорию hw-3/file.log

Домашняя работа №2

1. Создал файл mdadm.conf в директории hw-2/
2. Изменил конфигурацию файла Vagrant. 
- Добавил подключение 5го диска
- Добавил строки инициализации RAID 5
3. Для создания RAID 5 и создания партиций код ниже: 

	mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}  
	mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}  
	echo "yes i" | parted -s /dev/md0 mklabel gpt  
	echo "yes i" | parted /dev/md0 mkpart primary ext4 0% 20%  
	echo "yes i" | parted /dev/md0 mkpart primary ext4 20% 40%  
	echo "yes i" | parted /dev/md0 mkpart primary ext4 40% 60%  
	echo "yes i" | parted /dev/md0 mkpart primary ext4 60% 80%  
	echo "yes i" | parted /dev/md0 mkpart primary ext4 80% 100%  
	for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done  
	mkdir -p /raid/part{1,2,3,4,5}  
	for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done  

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
