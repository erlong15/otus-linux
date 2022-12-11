#!/bin/bash

# Количество дисков в RAID
DISKS_NUMBER=6
# Размер каждого диска созданного для RAID
DISK_SIZE="100M"

# Отбираем только созданные диски размером DISK_SIZE
DISKS=$(lsblk | awk '{if ($4 == $DISK_SIZE) print "/dev/"$1;}' ORS=" ")
echo $DISKS

# Подсчитываем количество дисков
FOUND_DISKS_NUMBER=$(echo $DISKS | tr -dc ' ' | awk '{ print length+1; }')
echo "Number of disks: '$FOUND_DISKS_NUMBER'" 

# Проверка, что все диски на месте. Только тогда создаем RAID
if [ $FOUND_DISKS_NUMBER=$DISKS_NUMBER ]; then
        echo "Проверка, что RAID еще не создан"
	sudo mdadm -D /dev/md0 > /dev/null 2>&1
        if [ $? -gt 0 ]; then
	   # создание RAID
           echo 'RAID creation ...'
           # Обнуление суперблоков:
	   echo "sudo mdadm --zero-superblock --force " $DISKS
	   sudo mdadm --zero-superblock --force $DISKS
           # Создание RAID 10 на $DISKS_NUMBER устройствах:
           sudo mdadm --create --verbose /dev/md0 -l 10 -n $DISKS_NUMBER -q -f $DISKS <<< y
	   if [ $? -gt 0 ]; then
		# Если RAID создан
                # Создание конфигурационного файла mdadm.conf, если он не существует.
                FILE=/etc/mdadm/mdadm.conf
                if [ ! -f "$FILE" ]; then
                	sudo mkdir -p /etc/mdadm
                	sudo touch /etc/mdadm/mdadm.conf
                	sudo chmod 666 /etc/mdadm/mdadm.conf
                	sudo echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
                	sudo mdadm --detail --scan --verbose | awk '/ARRAY/{print}' >> /etc/mdadm/mdadm.conf
                fi
		# Создание раздела GPT на RAID
		sudo parted -s /dev/md0 mklabel gpt
		# Создание партиций
		sudo parted -s -a optimal /dev/md0 mkpart primary ext4 0% 20%
		sudo parted -s -a optimal /dev/md0 mkpart primary ext4 20% 40%
		sudo parted -s -a optimal /dev/md0 mkpart primary ext4 40% 60%
		sudo parted -s -a optimal /dev/md0 mkpart primary ext4 60% 80%
		sudo parted -s -a optimal /dev/md0 mkpart primary ext4 80% 100%
		# Создание файловых систем
		for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
		# Монтирование партиций по каталогам
		sudo mkdir -p /raid/part{1,2,3,4,5}
		for i in $(seq 1 5); do 
			sudo mount /dev/md0p$i /raid/part$i; 
			# Формирование записей в fstab
			echo "check md0p$i in fstab"
			if sudo grep -Fxq "md0p$i" /etc/fstab
			then
			   echo "md0p$i exists in fstab"
		   	else 
			   echo `blkid /dev/md0p$i | awk '{print$2}' | sed -e 's/"//g'` /raid/part$i   xfs   defaults,noatime   0   0 | tee -a /etc/fstab > /dev/null
			fi
		done
	   fi
	   parted -s /
        fi
else
        echo 'RAID cannot be created.'
fi

echo 'Done.'

