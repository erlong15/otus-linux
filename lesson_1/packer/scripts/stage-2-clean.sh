#!/bin/bash

# clean all
yum update -y
yum clean all

HOME_DIR="${HOME_DIR:-/home/vagrant}";

# INstall VBoxLinuxAdditions
case "$PACKER_BUILDER_TYPE" in
virtualbox-iso|virtualbox-ovf)
    VER="`cat $HOME_DIR/.vbox_version`";
    ISO="VBoxGuestAdditions_$VER.iso";
    yum install bzip2 -y
    mkdir -p /tmp/vbox;
    mount -o loop $HOME_DIR/$ISO /tmp/vbox;
    sh /tmp/vbox/VBoxLinuxAdditions.run \
        || echo "VBoxLinuxAdditions.run exited $? and is suppressed." \
            "For more read https://www.virtualbox.org/ticket/12479";
    umount /tmp/vbox;
    rm -rf /tmp/vbox;
    rm -f $HOME_DIR/*.iso;
    ;;
esac

# Enable shared folders
mkdir -p /vagrant
echo "vboxguest" >> /etc/modules-load.d/virtualbox.conf
echo "vboxsf" >> /etc/modules-load.d/virtualbox.conf
echo "vboxvideo"  >> /etc/modules-load.d/virtualbox.conf

grub2-set-default 0

# Install vagrant default key
mkdir -pm 700 /home/vagrant/.ssh
curl -sL https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -o /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh


# Remove temporary files
rm -rf /tmp/linux-*
rm -rf /tmp/*
rm  -f /var/log/wtmp /var/log/btmp
rm -rf /var/cache/* /usr/share/doc/*
rm -rf /var/cache/yum
rm -rf /vagrant/home/*.iso
rm  -f ~/.bash_history
rm -rf /root/rpmbuild
history -c

rm -rf /run/log/journal/*

# Fill zeros all empty space
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
sync

grub2-set-default 0
echo "###   Hi from secone stage" >> /boot/grub2/grub.cfg
