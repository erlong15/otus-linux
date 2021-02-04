mdadm --zero-superblock --force /dev/sd{b,c,d,e}

# create RAID1 with 4 disks
mdadm --create --verbose /dev/md0 -l 1 -n 4 /dev/sd{b,c,d,e}

echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf