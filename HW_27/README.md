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
