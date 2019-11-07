# **Установка**
установлен `Vagrant`
```
➜  otus-linux git:(manual_kernel_update) ✗ vagrant --version
Vagrant 2.2.6
```
установлен `Packer`
```
➜  otus-linux git:(manual_kernel_update) ✗ packer --version
1.4.4
```
запуск виртуальной машины
```
vagrant up
vagrant ssh
sudo -i
```
---
# **Задание со `*`: Сборка ядра из сходников**.
доустановлены необходимые пакеты
```
yum update -y && yum group install -y "Development tools" && yum install -y wget ncurses-devel openssl-devel elfutils-libelf-devel bc
```
скачаны исходники последней стабильной на текущий момент версии ядра
```
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.3.8.tar.xz && tar -xvf linux-5.3.8.tar.xz
cd linux-5.3.8/
```
подготовлен конфигурационный файл для сборки ядра
```
cp /boot/config-`uname -r` .config
make menuconfig
```
скомпилировано ядро
```
make bzImage -j $(nproc)
make modules -j $(nproc)
make -j $(nproc)
make modules_install -j $(nproc)
make install -j $(nproc)
```
обновлена конфигурация загрузчика
```
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
reboot
```
проверка
```
[root@otuslinux ~]# uname -r
5.3.8
```
## **Packer**

сборка ядра добавлена в скрипт [stage-1-kernel-update.sh](../manual_kernel_update/packer/scripts/stage-1-kernel-update.sh)

---

# **Задание с `**`: добавление работоспособности VirtualBox Shared Folders**.
установлен `VirtualBox Guest Additions`
```
mount -r /dev/cdrom /media
cd /media/
./VBoxLinuxAdditions.run 
```
проверка
```
[root@otuslinux media]# lsmod | grep vboxguest
vboxguest             380928  2 vboxsf
```
монтируем папку из рабочей машины и смотрим логи
```
[root@otuslinux ~]# cat /var/log/messages  |grep automount
Nov  4 12:53:11 localhost systemd: Unset automount Arbitrary Executable File Formats File System Automount Point.
Nov  4 12:53:11 localhost systemd: Set up automount Arbitrary Executable File Formats File System Automount Point.
Nov  4 14:34:27 otuslinux kernel: 14:34:27.606517 automount vbsvcAutomounterMountIt: Successfully mounted 'manual_kernel_update' on '/sharefolder'
```
## **Packer**

установка `VirtualBox Guest Additions` добавлена в скрипт [stage-2-vbox-add.sh](../manual_kernel_update/packer/scripts/stage-2-vbox-add.sh)

---

# **Создание своего образа системы**
создан образ виртульной машины с помощью `Packer`
```
cd manual_kernel_update/packer/
packer build centos.json
```
проверка работоспособности
```
vagrant box add --name centos-7-5 centos-7.7.1908-kernel-5-x86_64-Minimal.box
vagrant box list
cd ..
vagrant up
vagrant ssh
vagrant destroy
vagrant box remove centos-7-5
```
---
# **Vagrant cloud**
опубликован собранный образ в Vagrant cloud
```
vagrant cloud auth login
vagrant cloud publish --release SOMikhaylov/centos-7-5 1.0 virtualbox centos-7.7.1908-kernel-5-x86_64-Minimal.box
```