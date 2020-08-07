#!/bin/bash

set -e
cd /tmp
yum install perl rsync rpm-build ncurses-devel make gcc bc bison flex elfutils-libelf-devel openssl-devel grub2 -y
curl https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.7.11.tar.xz -o linux-5.7.11.tar.xz
tar xvf  linux-5.7.11.tar.xz
cd linux-5.7.11
cp /boot/config-3.10.0-1127.el7.x86_64 .config
make olddefconfig
make rpm-pkg
rpm -iUv ~/rpmbuild/RPMS/x86_64/*.rpm
# make
# make modules_install
# make install
# rm -rf linux-5.7.11

# Install elrepo
# yum install -y http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
# Install new kernel
# yum --enablerepo elrepo-kernel install kernel-ml -y
# Remove older kernels (Only for demo! Not Production!)
rm -f /boot/*3.10*
# Update GRUB
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
echo "Grub update done."
# Reboot VM
shutdown -r now
