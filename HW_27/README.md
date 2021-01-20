# Postgresql

```txt
репликация postgres
- Настроить hot_standby репликацию с использованием слотов
- Настроить правильное резервное копирование

Для сдачи работы присылаем ссылку на репозиторий, в котором должны обязательно быть
- Vagranfile (2 машины)
- плейбук Ansible
- конфигурационные файлы postgresql.conf, pg_hba.conf и recovery.conf,
- конфиг barman, либо скрипт резервного копирования.

Команда "vagrant up" должна поднимать машины с настроенной репликацией и резервным копированием.
Рекомендуется в README.md файл вложить результаты (текст или скриншоты) проверки работы репликации и резервного копирования.

пример плейбука:
---
- name: Установка postgres11
hosts: master, slave
become: yes
roles:
- postgres_install

- name: Настройка master
hosts: master
become: yes
roles:
- master-setup

- name: Настройка slave
hosts: slave
become: yes
roles:
- slave-setup

- name: Создание тестовой БД
hosts: master
become: yes
roles:
- create_test_db

- name: Настройка barman
hosts: barman
become: yes
roles:
- barman_install
tags:
- barman
```

## Описание работы

### установка ansible

```bash
cd HW_27
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### Запуск стенда

```bash
make install
```

### Проверка

* Файлы для проверки лежат в каталоге ```files```

* на реплике есть база otus с мастера

```txt
vagrant ssh slave 
Last login: Wed Jan 20 21:13:15 2021 from 10.0.2.2
[vagrant@slave ~]$ sudo su postgres
bash-4.2$ psql
could not change directory to "/home/vagrant": Permission denied
psql (11.10)
Type "help" for help.

postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 otus      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(4 rows)
```

* barman настроен в режиме wall streaming
* тест barman проходит

```txt
[vagrant@barman ~]$ sudo su barman
bash-4.2$ barman check streaming
Server streaming:
        PostgreSQL: OK
        superuser or standard user with backup privileges: OK
        PostgreSQL streaming: OK
        wal_level: OK
        replication slot: OK
        directories: OK
        retention policy settings: OK
        backup maximum age: OK (no last_backup_maximum_age provided)
        compression settings: OK
        failed backups: OK (there are 0 failed backups)
        minimum redundancy requirements: OK (have 0 backups, expected at least 0)
        pg_basebackup: OK
        pg_basebackup compatible: OK
        pg_basebackup supports tablespaces mapping: OK
        systemid coherence: OK (no system Id stored on disk)
        pg_receivexlog: OK
        pg_receivexlog compatible: OK
        receive-wal running: OK
        archiver errors: OK
```

* бекапы создаются

```txt
bash-4.2$ barman backup streaming
Starting backup using postgres method for server streaming in /var/lib/barman/streaming/base/20210120T212046
Backup start at LSN: 0/6000140 (000000010000000000000006, 00000140)
Starting backup copy via pg_basebackup for 20210120T212046
Copy done (time: less than one second)
Finalising the backup.
This is the first backup for server streaming
WAL segments preceding the current backup have been found:
        000000010000000000000004 from server streaming has been removed
        000000010000000000000005 from server streaming has been removed
Backup size: 30.0 MiB
Backup end at LSN: 0/8000000 (000000010000000000000007, 00000000)
Backup completed (start time: 2021-01-20 21:20:46.284773, elapsed time: less than one second)
Processing xlog segments from streaming for streaming
        000000010000000000000006
        000000010000000000000007
bash-4.2$ 
```

* статус репликации

```
bash-4.2$ barman replication-status streaming
Status of streaming clients for server 'streaming':
  Current LSN on master: 0/80000C8
  Number of streaming clients: 2

  1. Async standby
     Application name: postgresnode1
     Sync stage      : 5/5 Hot standby (max)
     Communication   : TCP/IP
     IP Address      : 192.168.50.20 / Port: 60200 / Host: -
     User name       : postgres
     Current state   : streaming (async)
     WAL sender PID  : 3240
     Started at      : 2021-01-20 21:04:55.549112+00:00
     Sent LSN   : 0/80000C8 (diff: 0 B)
     Write LSN  : 0/80000C8 (diff: 0 B)
     Flush LSN  : 0/80000C8 (diff: 0 B)
     Replay LSN : 0/80000C8 (diff: 0 B)

  2. Async WAL streamer
     Application name: barman_receive_wal
     Sync stage      : 3/3 Remote write
     Communication   : TCP/IP
     IP Address      : 192.168.50.30 / Port: 45710 / Host: -
     User name       : barman
     Current state   : streaming (async)
     Replication slot: barman
     WAL sender PID  : 3442
     Started at      : 2021-01-20 21:07:02.777750+00:00
     Sent LSN   : 0/80000C8 (diff: 0 B)
     Write LSN  : 0/80000C8 (diff: 0 B)
     Flush LSN  : 0/8000000 (diff: -200 B)
```