## Домашнее задание №3
На имеющемся образе:

1. Уменьшить том под "/" до 8G
2. Выделить том под /home
3. Выделить том под /var - сделать в mirror
4. /home - сделать том для снэпшотов
5. Прописать монтирование в fstab. Попробовать с разными опциями и разными
файловыми системами ( на выбор)

Работа со снапшотами:
- сгенерить файлы в /home/
- снять снапшот
- удалить часть файлов
- восстановится со снапшота
- залоггировать работу можно с помощью утилиты script

* ДОП ЗАДАНИЕ * на нашей куче дисков попробовать поставить btrfs/zfs - с кешем, снапшотами -
разметить здесь каталог /opt

### Выполнение
* создали ВМ заново, установил lvm2 , xfsdump
* включил запись утилитой script
1. Уменьшить том под "/" до 8G
  * надо размонтировать ФС на / , это не так то просто

  * подготовим временный том для / раздела

```
pvcreate /dev/sdb

vgcreate vg_root /dev/sdb

lvcreate -n lv_root -l +100%FREE /dev/vg_root

```
  * Создадим на нем файловую систему и смонтируем его, чтобы перенести туда данные:
```
mkfs.xfs /dev/vg_root/lv_root
mount /dev/vg_root/lv_root /mnt
```
  * Копируем все данные с / раздела в /mnt:
```
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
```

* Затем переконфигурируем grub для того, чтобы при старте перейти в новый /
   Сымитируем текущий root -> сделаем в него chroot и обновим grub:

```
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg
```

* Обновим образ initrd.
```
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done
```

* для того, чтобы при загрузке был смонтирован нужны root нужно в файле
/boot/grub2/grub.cfg заменить 
```

rd.lvm.lv=VolGroup00/LogVol00 >>>  rd.lvm.lv=vg_root/lv_root

```

* Теперь нам нужно изменить размер старой VG и вернуть на него рут. Для этого удаляем
старый LV размеров в 40G и создаем новый на 8G:
```
lvremove /dev/VolGroup00/LogVol00

lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
```

* создаем ФС на новом LV LogVol00, монтируем на него /mnt
```
mkfs.xfs /dev/VolGroup00/LogVol00
mount /dev/VolGroup00/LogVol00 /mnt
```
* используем утилиту xfsdump для переноса всех файлов из LV lv_root
```
xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
```

* переконфигурируем grub, НО праавить /etc/grub2/grub.cfg не надо
```
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg

cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done
```

* Пока не перезагружаемся и не выходим из под chroot - мы можем заодно перенести /var


2. Выделить том под /var в зеркало
* На свободных дисках создаем зеркало, c именем lv_var:
```
pvcreate /dev/sdc/ /dev/sdd

vgcreate vg_var /dev/sdc /dev/sdd

lvcreate -L 950M -m1 -n lv_var vg_var
```
* Создаем на нем ФС и перемещаем туда /var:
```
mkfs.ext4 /dev/vg_var/lv_var

mount /dev/vg_var/lv_var /mnt
cp -aR /var/* /mnt/    # rsync -avHPSAX /var/ /mnt/

```
* На всякий случай сохраняем содержимое старого var
```
mkdir /tmp/oldvar && mv /var/* /tmp/oldvar

```
* монтируем новый var в каталог /var
```
umount /mnt
mount /dev/vg_var/lv_var /var
```

* Правим fstab для автоматического монтирования /var:
```
echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
```

* теперь можно успешно перезагружаться в новый (уменьшенный root) и удалять
временную Volume Group:

```
lvremove /dev/vg_root/lv_root
vgremove /dev/vg_root
pvremove /dev/sdb
```

3. Выделить том под /home

```
lvcreate -n LogVol_Home -L 2G /dev/VolGroup00

mkfs.xfs /dev/VolGroup00/LogVol_Home
mount /dev/VolGroup00/LogVol_Home /mnt/
cp -aR /home/* /mnt/
rm -rf /home/*
umount /mnt
mount /dev/VolGroup00/LogVol_Home /home/
# Правим fstab для автоматического монтирования /home
echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
```

4. /home сделать томом для снапшотов

* сгенерировать файлы в /home
```
touch  /home/file{1..20}
```
* снять снапшот
```
lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
```
* Удалить часть файлов:
```
rm -f /home/file{11..20}
```
* Процесс восстановления со снапшота:
```
umount /home
lvconvert --merge /dev/VolGroup00/home_snap
mount /home
```
* 
```

```
* 
```

```