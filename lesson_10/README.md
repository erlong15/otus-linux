# Systemd

## Домашнее задание

```txt
Выполнить следующие задания и подготовить развёртывание результата выполнения с использованием Vagrant и Vagrant shell provisioner (или Ansible, на Ваше усмотрение):
1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig);
2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi);
3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами;
4*. Скачать демо-версию Atlassian Jira и переписать основной скрипт запуска на unit-файл.
```

### Установка ansible

```bash
cd lesson_10
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip inatsll -r requirements.txt
ansible-galaxy install -r requirements.yml
```

### Запуск стенда

```bash
ansible-galaxy install -r requirements.yml
vagrant up
ansible -v -i inventory/vagrant.yml -m ping all
ansible-playbook -i inventory/vagrant.yml playbooks/inatall_systemd.yml
```

### проверка

* запущен таймер

```txt
[vagrant@nginx ~]$ systemctl list-timers 
NEXT                         LEFT       LAST                         PASSED    UNIT                         ACTIVATES
Tue 2020-09-29 15:10:02 UTC  1s left    Tue 2020-09-29 15:09:32 UTC  28s ago   watchlog.timer               watchlog.service
```

* переписана служба с init.rd на systemd

```txt
[vagrant@nginx ~]$ systemctl status spawn-fcgi.service
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2020-09-29 14:59:06 UTC; 12min ago
 Main PID: 43698 (php-cgi)
    Tasks: 33 (limit: 1213)
   Memory: 16.6M
   CGroup: /system.slice/spawn-fcgi.service
           ├─43698 /usr/bin/php-cgi
           ├─43718 /usr/bin/php-cgi
           ├─43719 /usr/bin/php-cgi
```

* запущено два сервиса apache на разных порта

```txt
[vagrant@nginx ~]$ sudo ss -ltpn
State                    Recv-Q                   Send-Q                                     Local Address:Port                                       Peer Address:Port                                                                                                                                                                                                             
LISTEN                   0                        128                                              0.0.0.0:22                                              0.0.0.0:*                       users:(("sshd",pid=926,fd=5))                                                                                                                                                            
LISTEN                   0                        128                                                    *:8877                                                  *:*                       users:(("httpd",pid=44646,fd=4),("httpd",pid=44645,fd=4),("httpd",pid=44644,fd=4),("httpd",pid=44643,fd=4),("httpd",pid=44640,fd=4))                                                     
LISTEN                   0                        128                                                 [::]:22                                                 [::]:*                       users:(("sshd",pid=926,fd=7))                                                                                                                                                            
LISTEN                   0                        128                                                    *:8811                                                  *:*                       users:(("httpd",pid=44365,fd=4),("httpd",pid=44364,fd=4),("httpd",pid=44363,fd=4),("httpd",pid=44362,fd=4),("httpd",pid=44359,fd=4))                                                     
[vagrant@nginx ~]$ ^C                                               *:*       
```
