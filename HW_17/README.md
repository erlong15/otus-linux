# Резервное копирование

## Домашнее задание

```txt
Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client
Настроить удаленный бекап каталога /etc c сервера client при помощи borgbackup. Резервные копии должны соответствовать следующим критериям:
- Директория для резервных копий /var/backup. Это должна быть отдельная точка монтирования. В данном случае для демонстрации размер не принципиален, достаточно будет и 2GB.
- Репозиторий дле резервных копий должен быть зашифрован ключом или паролем - на ваше усмотрение
- Имя бекапа должно содержать информацию о времени снятия бекапа
- Глубина бекапа должна быть год, хранить можно по последней копии на конец месяца, кроме последних трех. Последние три месяца должны содержать копии на каждый день. Т.е. должна быть правильно настроена политика удаления старых бэкапов
- Резервная копия снимается каждые 5 минут. Такой частый запуск в целях демонстрации.
- Написан скрипт для снятия резервных копий. Скрипт запускается из соответствующей Cron джобы, либо systemd timer-а - на ваше усмотрение.
- Настроено логирование процесса бекапа. Для упрощения можно весь вывод перенаправлять в logger с соответствующим тегом. Если настроите не в syslog, то обязательна ротация логов
Запустите стенд на 30 минут. Убедитесь что резервные копии снимаются. Остановите бекап, удалите (или переместите) директорию /etc и восстановите ее из бекапа. Для сдачи домашнего задания ожидаем настроенные стенд, логи процесса бэкапа и описание процесса восстановления.
```

## Описание

### Запуск стенда

```bash
cd HW_17
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
vagrant up
```

Используется [роль borg](https://github.com/fiaasco/borgbackup)

### Отчет

- Диск создается на сервере , монитруется и настраивается в качесте репозитория

    ```bash
    [vagrant@server ~]$ df -h
    Filesystem      Size  Used Avail Use% Mounted on
    devtmpfs        111M     0  111M   0% /dev
    tmpfs           118M     0  118M   0% /dev/shm
    tmpfs           118M  4.5M  114M   4% /run
    tmpfs           118M     0  118M   0% /sys/fs/cgroup
    /dev/sda1        40G  3.0G   37G   8% /
    /dev/sdb1       2.0G   16M  1.9G   1% /var/backup
    tmpfs            24M     0   24M   0% /run/user/1000
    ```

- Бекапы создаются с меткой времени

    ```bash
    [root@client ~]# borg-backup list
    Archives on server :
    Using a pure-python msgpack! This will result in lower performance.
    Remote: Using a pure-python msgpack! This will result in lower performance.
    20201118-0837                        Wed, 2020-11-18 08:37:07 [086a2c98fdf75a8e75b008ba98783da1e9dae3c7d19df69cc6e476e7bda3f1c8]
    20201118-0840                        Wed, 2020-11-18 08:40:05 [7adebece4539add65004879f3f04be73ab99f9a729fc0e71cc6bbbadbe457d3a]
    20201118-0845                        Wed, 2020-11-18 08:45:03 
    [0b1081aeae37a119bf775f24037b9bef6e1f992267ebb1978a1e1011135c812c]
    20201118-0850                        Wed, 2020-11-18 08:50:04 [80e667b78a65a67f3bf5710227a206adb4ef18d7c633c1761083eaedaf817041]
    ```

- используется скрипт для резервного копирования, он запускается каждые 5 минут с помошью cron.

    ```bash
    [root@client ~]# cat /etc/cron.d/borg-backup 
    #Ansible: borg-backup
    */5 * * * * root /usr/local/bin/borg-backup backup
    ```

- процесс восстановления

```bash
# смотрим листинг бекапов
[root@client ~]# borg-backup list
Archives on server :
Using a pure-python msgpack! This will result in lower performance.
Remote: Using a pure-python msgpack! This will result in lower performance.
20201118-0837                        Wed, 2020-11-18 08:37:07 [086a2c98fdf75a8e75b008ba98783da1e9dae3c7d19df69cc6e476e7bda3f1c8]
20201118-0840                        Wed, 2020-11-18 08:40:05 [7adebece4539add65004879f3f04be73ab99f9a729fc0e71cc6bbbadbe457d3a]
20201118-0845                        Wed, 2020-11-18 08:45:03 [0b1081aeae37a119bf775f24037b9bef6e1f992267ebb1978a1e1011135c812c]
20201118-0850                        Wed, 2020-11-18 08:50:04 [80e667b78a65a67f3bf5710227a206adb4ef18d7c633c1761083eaedaf817041]
20201118-0855                        Wed, 2020-11-18 08:55:03 [30a2f6c4faf5aeab4f186b09dd6f688e0859db9095a0fbada931563a04d43f11]

# монтируем конкретный бекап по имени
[root@client ~]# borg-backup mount 20201118-0855 server /mnt/

[root@client ~]# ls -lah /mnt
total 0
drwxr-xr-x.  1 root root   0 Nov 18 08:58 .
dr-xr-xr-x. 17 root root 240 Apr 30  2020 ..
drwxr-xr-x.  1 root root   0 Nov 18 08:19 etc
drwxr-xr-x.  1 root root   0 Apr 30  2020 home
drwxr-xr-x.  1 root root   0 Apr 11  2018 opt
dr-xr-x---.  1 root root   0 Nov 18 08:38 rootvim /usr/local/bin/borg-backup

# Удаляем данные из /etc
[root@client ~]# rm -rf /etc/*
[root@client ~]# ls -lah /etc
total 4.0K
drwxr-xr-x.  2 0 0  39 Nov 18 09:06 .
dr-xr-xr-x. 17 0 0 240 Apr 30  2020 ..
-rw-------.  1 0 0   0 Apr 30  2020 .pwd.lock
-rw-r--r--.  1 0 0 163 Apr 30  2020 .updated

# восстанавливаем из резерва
[root@client ~]# rsync -a /mnt/etc/ /etc
[root@client ~]# ls -lah /etc
total 1.1M
drwxr-xr-x. 78 root root   8.0K Nov 18 08:19 .
dr-xr-xr-x. 17 root root    240 Apr 30  2020 ..
-rw-r--r--.  1 root root     16 Apr 30  2020 adjtime
-rw-r--r--.  1 root root   1.5K Apr  1  2020 aliases
-rw-r--r--.  1 root root    12K Nov 18 08:18 aliases.db
drwxr-xr-x.  2 root root   4.0K Apr 30  2020 alternatives
-rw-------.  1 root root    541 Aug  8  2019 anacrontab
drwxr-x---.  3 root root     43 Apr 30  2020 audisp
...

```

- политика очистки

```bash
/usr/local/bin/borg prune -v  --keep-last 10 -H 2 -d 93 -w 12 -m 12 -y 1 $REPOSITORY
```
