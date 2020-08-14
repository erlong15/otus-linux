# Работа с NFS

## Домашнее задание

```txt
Vagrant стенд для NFS или SAMBA
NFS или SAMBA на выбор:

vagrant up должен поднимать 2 виртуалки: сервер и клиент
на сервер должна быть расшарена директория
на клиента она должна автоматически монтироваться при старте (fstab или autofs)
в шаре должна быть папка upload с правами на запись
- требования для NFS: NFSv3 по UDP, включенный firewall
```

## Решение

### Запуск

Для запуска стенда требуется установленные ```Ansible``` и ```Vagrant```

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
vagrant up
```

### Описание

На стенде настраивается:

1. nfs сервер
1. шара папки
1. порты в FirewallD
1. Клиент монтируется шару через fstab
1. Параметры монтирования ```vers=3,rsize=8192,wsize=8192,timeo=14,intr,proto=udp```
