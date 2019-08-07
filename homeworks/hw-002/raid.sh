#!/bin/bash

echo "Start script..."

echo "Creating RAID"
mdadm -C -v /dev/md0 -l 10 -n 4 /dev/sd[bcde]

mdadm --detail --scan >> /etc/mdadm.conf

mdadm -D /dev/md0

if [ $? -eq 0 ]; then
  echo "RIAD succesfuly created..."
else
  echo "RAID creation failed..."
  exit 1
fi

echo "Creating partitions"
for i in {1..5}
do
gdisk /dev/md0 << EOF
n


+100M

w
Y
EOF
  if [ $? -eq 1 ]; then
    continue # gdisk возвращает exit code 1
  fi
done

echo "Creating filesystems"
for i in {1..5}
do
  sudo mkdir -p /raid/part$i;
  sudo mkfs.ext4 /dev/md0p$i;
  echo `sudo blkid /dev/md0p$i | awk '{print $2}'` /raid/part$i ext4 defaults 0 0 >> /etc/fstab
done


echo "Mounging partitions"
mount -a

echo "End script..."
exit 0

