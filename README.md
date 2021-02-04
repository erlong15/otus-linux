# Вначале в Vagrat file был добавлен еще один Sata disk

:sata5 => {
 :dfile => './sata5.vdi',
 :size => 250, 
 :port => 5 
},

## по методичке запустила команды для  просмотра дисков, все запустилось

sudo lshw -short | grep disk
sudo fdisk -l

## команда mdadm 
mdadm --zero-superblock --force /dev/sd{b,c,d,e}

##  Создала raid array 1 для 4х дисков b, c, d, e
mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e}

## Проверила raid
cat /proc/mdstat
mdadm -D /dev/md0

## Создала mdadm.config, сложность заключалась в том, что данного файла и подраздела не было в системе.
## В интернете нашла, что в Centos данного подраздела и нет и совет создать вручную. Создала вручную
## Также была ошибка с правами, перешла в sudo su

echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
 mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
 
##  Искусственно сломала два диска e and b. Вначале ошибка была, что он занят, потом заработало
mdadm /dev/md0 --fail /dev/sde

## починила Raid
mdadm /dev/md0 --remove /dev/sde
mdadm /dev/md0 --remove /dev/sdb
mdadm /dev/md0 --add /dev/sde
mdadm /dev/md0 --add /dev/sdb

##Создала GPT раздел 
parted -s /dev/md0 mklabel gpt

parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 100%

for i in $(seq 1 4); do sudo mkfs.ext4 /dev/md0p$i; done

mkdir -p /raid/part{1,2,3,4}
for i in $(seq 1 4); do mount /dev/md0p$i /raid/part$i; done






