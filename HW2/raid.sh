# !/bin/bash
#creating raid massive
sudo mdadm --create --verbose /dev/md0 -l 0 -n 5 /dev/sd{b,c,d,e,f}

cat /proc/mdstat > /home/vagrant/output_01


# creating mdadm config file for OS to remember raid settings
sudo mkdir /etc/mdadm/
sudo touch /etc/mdadm/mdadm.conf

sudo echo "DEVICE partitions" >> /etc/mdadm/mdadm.conf

sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

# creating a GPT partition on raid massive
sudo parted -s /dev/md0 mklabel gpt
#creating small partitions
sudo parted /dev/md0 mkpart primary ext4 0% 20%
sudo parted /dev/md0 mkpart primary ext4 20% 40%
sudo parted /dev/md0 mkpart primary ext4 40% 60%
sudo parted /dev/md0 mkpart primary ext4 60% 80%
sudo parted /dev/md0 mkpart primary ext4 80% 100%

# создание ФС на партициях
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done

# монтирование по каталогам
mkdir -p /raid/part{1,2,3,4,5}

for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done

ls -l /raid
