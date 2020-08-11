# Работа с LVM

## Домашнее заданее

запись работы с помошью программы ```script --timing=timing_script rec_script```

### уменьшить том под / до 8G

на имеющемся образе  
/dev/mapper/VolGroup00-LogVol00 38G 738M 37G 2% /

```bash
sudo su
yum install -y xfsdump
pvcreate /dev/sdb
vgcreate vg_root /dev/sdb
lvcreate -n lv_root -L 8G /dev/vg_root
mkfs.xfs /dev/vg_root/lv_root
mount /dev/vg_root/lv_root /mnt
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt

for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg

cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done
vi /boot/grub2/grub.cfg
exit
reboot

sudo su
lvremove /dev/VolGroup00/LogVol00
lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
mkfs.xfs /dev/VolGroup00/LogVol00
mount /dev/VolGroup00/LogVol00 /mnt
xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt

for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done

```

```bash
reboot
lvremove /dev/vg_root/lv_root
vgremove /dev/vg_root
pvremove /dev/sdb

```

### /var - сделать в mirror

```bash
pvcreate /dev/sde /dev/sdd
vgcreate vg_var /dev/sde /dev/sdd
lvcreate -L 950M -m1 -n lv_var vg_var
```

### выделить том под /var

```bash
mkfs.ext4 /dev/vg_var/lv_var
mount /dev/vg_var/lv_var /mnt
mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
```

### выделить том под /home

```bash
lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
mount /dev/VolGroup00/LogVol_Home /mnt/
cp -aR /home/* /mnt/
rm -rf /home/*
umount /mnt
mount /dev/VolGroup00/LogVol_Home /home/
echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
```

### /home - сделать том для снэпшотов

```bash
touch /home/file{1..20}
lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
rm -f /home/file{11..20}
umount /home
lvconvert --merge /dev/VolGroup00/home_snap
mount /home
```

### прописать монтирование в fstab

```bash
echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab

```

### попробовать с разными опциями и разными файловыми системами ( на выбор)

- сгенерить файлы в /home/
- снять снэпшот
- удалить часть файлов
- восстановится со снэпшота
- залоггировать работу можно с помощью утилиты script
