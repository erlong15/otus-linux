#!/bin/bash

if [[ $(lsblk -f | grep -E 'sdb|sdc|sdd|sde' | wc -l ) -eq 4 ]]; then
        # Проверка, что RAID еще не создан
	sudo mdadm -d /dev/md0 > /dev/null 2>&1
        if [ $? -gt 0 ]; then
	   # создание RAID
           echo YES!
           # Обнуление суперблоков:
           echo sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e}
           # Создание RAID 10 на 4 устройствах:
           echo sudo mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}
        fi

	# Создание конфигурационного файла mdadm.conf
	FILE=/etc/mdadm/mdadm.conf
	if [ ! -f "$FILE" ]; then
		sudo mkdir -p /etc/mdadm
		sudo touch /etc/mdadm/mdadm.conf
		sudo chmod 666 /etc/mdadm/mdadm.conf
		sudo echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
		sudo mdadm --detail --scan --verbose | awk '/ARRAY/{print}' >> /etc/mdadm/mdadm.conf
	if

else
        echo NO
fi

