#!/bin/bash

# Install packages
yum update -y && yum group install -y "Development tools" && yum install -y wget ncurses-devel openssl-devel elfutils-libelf-devel bc epel-release

# Install new kernel
cd /usr/src/kernels/
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.3.8.tar.xz && tar -xvf linux-5.3.8.tar.xz
rm -rf linux-5.3.8.tar.xz
cd linux-5.3.8/
cp /boot/config-`uname -r` .config
"" | make oldconfig

make bzImage -j $(nproc)
make modules -j $(nproc)
make -j $(nproc)
make modules_install -j $(nproc)
make install -j $(nproc)
echo "all make task done"

# Update GRUB
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
echo "Grub update done."

# Reboot VM
shutdown -r now