## Отчет о домашней работе №1
* директория HW1
* скачан репозиторий manual_kernel_update

* запустил VM с базовым Centos/7, провел обновление ядра вручную, используя следующие команды:

 * подключение репозитория
 ````
  sudo yum install -y http:///www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
 ````
 * установка последней версии ядра
 ````
 sudo yum --enablerepo elrepo-kernel install kernel-ml

 ````
 * обновил конфигурацию загрузчика и выбрал загрузку по умолчанию с новым ядром
 ````
 sudo grub2-mkconfig -o /boot/grub2/grub.cfg # 
 sudo grub2-set -default 0
  ````
  
* с помощью шаблона packer/centos.json создан файл-образ Centos-7.7.1908-kernel-5-x86_64-Minimal.box

  *  при создании этого образа были использованы bash скрипты, обновляющие ядро

* вопрос - в centos.json указан образ по URL, скачивание гигабайта занимает большой объем времени. Возможно ли заменить ссылку на образ с URL на box Centos/7 , уже скачанный вагрантом на локальную машину?

* образ добавлен в список для vagrant
````
vagrant box add --name centos7-5 centos Centos-7.7.1908-kernel-5-x86_64-Minimal.box
````
* запустили образ в папке test (ее не коммитил). Автоматически создался vagrantfile
````
vagrant init centos-7-5
````

  * при запуске возникла ошибка создания virtualbox shared folders. Нужно подправить vagrantfile, чтобы устранить. В ПРОЦЕССЕ
    * в логах вагрант ругается на невозможность создать расшаренные папки на VM. Недоступна файловая система "vboxsf"
     * для установки нужен специализированный модуль ядра и VirtualBox Kernel Additions

     * нужно прокатать это на руками запущенной VM, затем создать скрипт, прописать ссылку на него в .json шаблоне

* при запуске VM из нового образа, проверил версию ядра
````

uname -r
````

* ядро обновлено до весрии 5.3.8.1

* первая версия vagrantfile скопирована в свой репозиторий ветка homework1, изначальные vagrantfile (откуда у меня их два??) скопированы в папку default_vagrantfiles

* образ выгружен в Vagrant Cloud. Доступен по ссылке https://app.vagrantup.com/max89k/boxes/centos-7-5



## Homework № 2. Создание RAID массивов
директория HW2,  в ней свой vagrantfile. файл скрипта - raid.sh
отчет о работе (отдельный) - HW2/log.md
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


## Отчет о домашней работе №3
Работа проведена на ВМ 'lvm', директория HW3
Что сделано:
1. Уменьшен том под "/" до 8G
2. Выделен том под /home
3. Выделен том под /var - сделать в mirror
4. Том для снэпшотов - /home 
5. Прописано монтирование в fstab. 

6. Работа со снапшотами:
- сгенерить файлы в /home/
- снять снапшот
- удалить часть файлов
- восстановится со снапшота

Работа описана в файле HW3/hw3.md
Ввод-вывод командной строки запротоколирован командой script , находится в HW3/script_log

### Отчет о домашней работе №4
Что сделано:
1. Опробовано три способа попасть в систему без пароля  - через init=/bin/sh,  init=/sysroot/bin/sh, rd.break 
2. В системе с LVM,  переименовать VG и исправить конфигурационные файлы, чтобы она загружалась (/etc/fstab /etc/default/grub, /boot/grub2/grub.cfg )
3. Добавить модуль в initrd (используем доп. модуль dracut)

Работа описана в файле HW4/hw4.md
Ввод-вывод командной строки запротоколирован командой script , находится в HW4/script_log

### Отчет о домашней работе №5
Что сделано:
1. Написан сервис, который раз в 30 секунд мониторит лог файл на
предмет наличия ключевого слова. Файл и слово задаются в
/etc/sysconfig
2. Из epel установлен spawn-fcgi и переписан init-скрипт на unit-файл.

3. Дополнен юнит-файл apache httpd с возможностью запустить
несколько инстансов сервера с разными конфигами

Работа описана в файле HW5/hw5.md
Ввод-вывод командной строки запротоколирован командой script , находится в HW5/script.log (только ч.2 и ч.3)