#!/bin/bash

# Download VBoxGuestAdditions
wget http://download.virtualbox.org/virtualbox/LATEST-STABLE.TXT
VBOX_VERSION=$(cat LATEST-STABLE.TXT)
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso

#Install VBoxGuestAdditions
mount -o loop,ro VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run --nox11
umount /mnt
rm -rf VBoxGuestAdditions_$VBOX_VERSION.iso
rm -rf LATEST-STABLE.TXT
unset VBOX_VERSION