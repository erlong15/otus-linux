Что сделано:

1. Берем вагнантфайл из гитхаба
2. Добавляем в него настройку для пятого диска, в раздел MACHINES , :disks
````
:sata5 => {
:dfile => './sata5.vdi', # Путь, по которому будет создан файл диска
:size => 250, # Размер диска в мегабайтах
:port => 5 # Номер порта на который будет зацеплен диск
},
````
3. Поднимаем ВМ. На нее через провижинер shell устанавливается mdadm, smartmontools, hdparm, gdisk

4. Смотрим/Собираем RAID массив с помощью утилит
  * fdisk -l
  * lsblk
  * lshw
  * lsscsi

5. просмотр списка дисков. у нас блочные устройства /dev/sdb - /dev/sdf пять дисков одинакового объема, из них сделаем массив
 ````
sudo lshw -short | grep disk
sudo fdisk -l # подробнее


 ````
6. Занулим суперблоки
````
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
````

7. Создаем рейд - массив. /dev/md0 - куда он монтируется. -l 6 тип массива (raid 6), -n 5 - кол-во дисков, затем их перечисление
````
mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}
````

8. Проверим что RAID собрался нормально:
````
cat /proc/mdstat
# output
md0 : active raid6 sdf[4] sde[3] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]

mdadm -D /dev/md0

````

9. Создание конфигурационного файла mdadm.conf. Он нужен для того, чтобы ОС запомнила параметры создания RAID массива.
````
# проверка
sudo mdadm --detail --scan --verbose

# создание файлаб через редактор nano
sudo nano /etc/mdadm/mdadm.conf #добавляем строку DEVICE partitions
 mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >>
/etc/mdadm/mdadm.conf

# туда запишется следующая строка
ARRAY /dev/md0 level=raid6 num-devices=5 metadata=1.2 name=otuslinux:0 UUID=90daa6f2:04f6fd16:ff30ec46:dc514e06
````

10. Сломать и починить RAID. Сломаем, виртуально вытащив ("зафейлив") одно из блочных устройств.
````
# commnd to fail
mdadm /dev/md0 --fail /dev/sde

#check status
cat /proc/mdstat
# output
md0 : active raid6 sdf[4] sde[3](F) sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/4] [UUU_U]

mdadm -D /dev/md0
````
* удаление сломанного диска из массива
````
mdadm /dev/md0 --remove /dev/sde
````
* "починили" диск, вставляем обратно
````
mdadm /dev/md0 --add /dev/sde

#после этого быстро смотрим статус
cat /proc/mdstat
# видим результат - перестроение массива 
md0 : active raid6 sde[5] sdf[4] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/4] [UUU_U]
      [================>....]  recovery = 81.0% (206388/253952) finish=0.0min speed=29484K/sec
````
11. Создаем раздел GPT на RAID, пять партиций и смонтировать  их на диск
````
parted -s /dev/md0 mklabel gpt
#creating small partitions
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%


# создание ФС на партициях
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done

# монтирование по каталогам
mkdir -p /raid/part{1,2,3,4,5}

for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done
````
* в итоге получаем директорию /raid,  в ней каталоги /part1- part5 


### Дополнительное задание. Дописать vagrantfile, чтобы система запускалась сразу с подключенныйм рейдом

1. Допишем еще один провижжинер,скрипт shell из файла raid.sh

````
box.vm.provision "shell", path: "raid.sh"
````

2. Создаем массив с помощью mdadm. В этом случае будет массив RAID 0 из пяти дисков
````
#creating raid massive
sudo mdadm --create --verbose /dev/md0 -l 0 -n 5 /dev/sd{b,c,d,e,f}

cat /proc/mdstat > /home/vagrant/output_01

````

3. Создание файла mdadm.conf
````
 creating mdadm config file for OS to remember raid settings
sudo mkdir /etc/mdadm/
sudo touch /etc/mdamd/mdadm.conf

sudo echo "DEVICE partitions" >> /etc/mdadm/mdadm.conf

sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
````

4. Создание раздела, монтирование ФС, в директорию /raid
````
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
cat /proc/mdstat
````

#### Результат
* получаем ВМ с уже готовым массивом raid0, смонтированным в пяти директориях в /raid. Целесообразности в таком массиве из 5 дисков нет, сделано для примера. 

* прописал файл конфигурации mdadm.conf

* ради интереса, можно попробовать поломать весь массив, зафейлив/вытащив один диск

````
mdadm /dev/md0 --fail /dev/sde
mdadm /dev/md0 --remove /dev/sde
````
* интересно - на обе команды система отвечает отказом:
````
mdadm: set device faulty failed for /dev/sdd:  Device or resource busy
mdadm: hot remove failed for /dev/sde: Device or resource busy
````