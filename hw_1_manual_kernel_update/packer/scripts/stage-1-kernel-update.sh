#!/bin/bash

# Install elrepo
yum install -y http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
# Install new kernel
yum --enablerepo elrepo-kernel install kernel-ml -y
# Remove older kernels (Only for demo! Not Production!)
rm -f /boot/*3.10*
# Update GRUB
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
echo "Grub update done."
# Reboot VM
shutdown -r now
