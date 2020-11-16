# ZFS

## Домашнее задание

### install

```bash
yum install -y yum-utils
gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
yum install http://download.zfsonlinux.org/epel/zfs-release.el8_2.noarch.rpm
yum-config-manager --enable zfs-kmod
yum-config-manager --disable zfs
yum repolist --enabled | grep zfs && echo ZFS repo enabled
yum install -y zfs
```

### Определить алгоритм с наилучшим сжатием


```bash
wget -O /home/vagrant/War_and_Peace.txt http://www.gutenberg.org/files/2600/2600-0.txt
cd /mnt
echo disk{1..6} | xargs -n 1 fallocate -l 500M
zpool create raid raidz1 $PWD/disk[1-5]


zfs create raid/lz4
zfs create raid/lzjb
zfs create raid/zle
zfs create raid/gzip

zfs set compression=gzip raid/gzip
zfs set compression=zle raid/zle
zfs set compression=lzjb raid/lzjb
zfs set compression=lz4 raid/lz4

cp /home/vagrant/War_and_Peace.txt /raid/gzip
cp /home/vagrant/War_and_Peace.txt /raid/lz4
cp /home/vagrant/War_and_Peace.txt /raid/lzjb
cp /home/vagrant/War_and_Peace.txt /raid/zle
```
zfs
Для текста лучше gzip

```bash
[root@zfs mnt]# zfs list
NAME        USED  AVAIL     REFER  MOUNTPOINT
raid       9.10M  1.66G     41.5K  /raid
raid/gzip  1.26M  1.66G     1.26M  /raid/gzip
raid/lz4   2.03M  1.66G     2.03M  /raid/lz4
raid/lzjb  2.43M  1.66G     2.43M  /raid/lzjb
raid/zle   3.24M  1.66G     3.24M  /raid/zle
```

### Определить настройки pool’a

```bash
[root@zfs vagrant]# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

        otus                                 ONLINE
          mirror-0                           ONLINE
            /home/vagrant/zpoolexport/filea  ONLINE
            /home/vagrant/zpoolexport/fileb  ONLINE
[root@zfs vagrant]# zpool import -d zpoolexport/ otus
[root@zfs vagrant]# zpool list
NAME   SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus   480M  2.09M   478M        -         -     0%     0%  1.00x    ONLINE  -
raid  2.25G  11.4M  2.24G        -         -     0%     0%  1.00x    ONLINE  -

[root@zfs vagrant]# zfs list
NAME             USED  AVAIL     REFER  MOUNTPOINT
otus            2.04M   350M       24K  /otus
otus/hometask2  1.88M   350M     1.88M  /otus/hometask2
raid            9.11M  1.66G     41.5K  /raid
raid/gzip       1.26M  1.66G     1.26M  /raid/gzip
raid/lz4        2.03M  1.66G     2.03M  /raid/lz4
raid/lzjb       2.43M  1.66G     2.43M  /raid/lzjb
raid/zle        3.24M  1.66G     3.24M  /raid/zle

```

- размер хранилища 350M

```bash
[root@zfs vagrant]# zfs list
NAME             USED  AVAIL     REFER  MOUNTPOINT
otus            2.04M   350M       24K  /otus
otus/hometask2  1.88M   350M     1.88M  /otus/hometask2

```

- тип pool ``` mirror-0 ```

```bash
[root@zfs vagrant]# zpool status otus
  pool: otus
 state: ONLINE
  scan: none requested
config:

        NAME                                 STATE     READ WRITE CKSUM
        otus                                 ONLINE       0     0     0
          mirror-0                           ONLINE       0     0     0
            /home/vagrant/zpoolexport/filea  ONLINE       0     0     0
            /home/vagrant/zpoolexport/fileb  ONLINE       0     0     0
```

- значение recordsize ```128K```

```bash
[root@zfs vagrant]# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local
```

- какое сжатие используется ```zle```

```bash
[root@zfs vagrant]# zfs get compression otus
NAME  PROPERTY     VALUE     SOURCE
otus  compression  zle       local
```

- какая контрольная сумма используется

```bash
[root@zfs vagrant]# zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
```

Конфигурация pool

```bash
zpool create otus mirror /home/vagrant/zpoolexport/filea /home/vagrant/zpoolexport/fileb
zfs create otus/hometask2
zfs set recordsize=128K otus
zfs set checksum=sha256 otus
zfs set compression=zle otus
```

### Найти сообщение от преподавателей

**https://github.com/sindresorhus/awesome**

```bash
zfs create  otus/storage
zfs receive  -F otus/storage < otus_task2.file
zfs list
    NAME             USED  AVAIL     REFER  MOUNTPOINT
    otus            4.94M   347M       25K  /otus
    otus/hometask2  1.88M   347M     1.88M  /otus/hometask2
    otus/storage    2.83M   347M     2.83M  /otus/storage
    raid            9.11M  1.66G     41.5K  /raid
    raid/gzip       1.26M  1.66G     1.26M  /raid/gzip
    raid/lz4        2.03M  1.66G     2.03M  /raid/lz4
    raid/lzjb       2.43M  1.66G     2.43M  /raid/lzjb
    raid/zle        3.24M  1.66G     3.24M  /raid/zle

find . -name 'secret_message'
    ./task1/file_mess/secret_message


cat ./task1/file_mess/secret_message
    https://github.com/sindresorhus/awesome
```
