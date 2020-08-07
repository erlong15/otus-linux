#!/bin/bash
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y mdadm smartmontools hdparm gdisk vim

#Создаем рейд 10
DISKS_ARRY=""
for i in $(lsblk -p | grep 250M | awk '{print $1}'); do DISKS_ARRY="$DISKS_ARRY $i" ; done

echo "$DISKS_ARRY"
mdadm --ze  ro-superblock --force $DISKS_ARRY
echo "$DISKS_ARRY"
mdadm --create --verbose /dev/md0 -l 10 -n 6 $DISKS_ARRY
echo "$DISKS_ARRY"

cat /proc/mdstat

# Сохраняем конфигурацию рейда
mkdir /etc/mdadm

echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf


#Создаем логические тома

parted -s /dev/md0 mklabel gpt

parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 35%
parted /dev/md0 mkpart primary ext4 35% 55%
parted /dev/md0 mkpart primary ext4 55% 87%
parted /dev/md0 mkpart primary ext4 87% 100%

#Создаем ФС
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done

#Монтируем каталоги
mkdir -p /raid/part{1,2,3,4,5}

for i in $(seq 1 5); do echo "/dev/md0p$i        /raid/part$i    ext4    defaults    1 2" >> /etc/fstab; done
mount -a


