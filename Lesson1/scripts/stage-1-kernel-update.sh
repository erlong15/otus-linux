#!/bin/bash

# Установка репозитория elrepo
sudo yum install -y http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm 

# Установка нового ядра из репозитория elrepo-kernel
sudo yum --enablerepo elrepo-kernel install kernel-ml -y

# Обновление параметров GRUB
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo grub2-set-default 0
echo "Grub update done."

# Перезагрузка ВМ
sudo shutdown -r now
