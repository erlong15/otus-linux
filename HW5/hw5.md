### Домашнее задание №5 - systemD
1. Задача - написать сервис, который будет раз в 30 секунд мониторить лог на
предмет наличия ключевого слова. Файл и слово должны задаваться в
/etc/sysconfig

2. Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл.
Имя сервиса должно называться также

3. Дополнить юнит-файл apache httpd возможностью запустить
несколько инстансов сервера с разными конфигами
4.  (*). Скачать демо-версию Atlassian Jira и переписать основной скрипт
запуска на unit-файл

### выполнение
#### задание 1
1. создан файл с конфигурацией для сервиса в /etc/sysconfig. Из этого файла сервис будет брать переменные

2. Создан файл, который будет проверяться. /var/log/watchlog.log. Он заполнен текстом, есть ключевое слово ALERT

3. Создан сркипт /opt/watchlog.sh
````
#!/bin/bash
WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
    # logger sends log to system journal
    logger "$DATE: I found word, Comrade!"
else
    exit 0
fi
````

4. Создаем unit-файл watchdog.service в /etc/systemd/system/. Он описывает непосредствено сам сервис - описание, что запускать, откуда брать конфиг
````
[Unit]
Description=My watchlog service
[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchdog
ExecStart=/opt/watchlog.sh $WORD $LOG
````

5. Создаем unit файл для таймера. /etc/systemd/system/watchdog.timer. 
Он описывает зависимости (wantedBy) и параметры запуска (секция [Timer] )
````
[Unit]
Description=Run watchlog script every 30 second
[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service
[Install]
WantedBy=multi-user.target
````

6. Запускаем таймер watchlog-а. 
````
systemctl start watchlog.timer

просмотр системного журнала:
tail -f /var/log/messages
````
* обнаружена ошибка - сервис не запущен, не запускается даже руками по команде systemctl start watchlog.service

* смотрим статус
````
systemctl status watchlog.service
# статус disabled

# смотрим журнал systemd
journalctl -xe
# видим результат - фейл на этапе EXEC /opt/watchlog.sh
````
* причина найдена - забыл прописать исполняемость скрипту /opt/watchlog.sh . исаправляем

* после повтороного запуска таймера сервис запустился. 
````
Dec  4 08:32:53 otuslinux systemd: Starting My watchlog service...
Dec  4 08:32:53 otuslinux root: Wed Dec  4 08:32:53 UTC 2019: Ifound word, Comrade!
Dec  4 08:32:53 otuslinux systemd: Started My watchlog service.
````

#### задание 2  (протоколируем командой script)
1. установлены spawn fcgi и все зависимые пакеты- epel-release, php, php-cli mod_fcgid, httpd

2. раскомментированы строки с переменными в /etc/sysconfig/spawn-fcgi
  * раскомментируем строки SOCKET и OPTIONS

3. Создан юнит файл /etc/systemd/system/spawn-fcgi.service
````
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target
[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process
[Install]
WantedBy=multi-user.target
````

4. запуск и проверка
````
systemctl start spawn-fcgi

systamctl status spawn-fcgi
#вывод - active(running), и доп. информация
````


### задание 3 Дополнить юнит-файл apache httpd возможностью запустить несколько
инстансов сервера с разными конфигами

1. Создан файл юнит файл /etc/systemd/system/httpd.service
````
[Unit]
After=network.target remote-fs.target nss-lookup.target
# запуск после инициализации сети

[Service]
EnvironmentFile=/etc/sysconfig/httpd-%I 
# используется шаблон в указании файла окружения, для запуска нескольких экземпляров сервиса

````

2. созданы два файла окружения, в них прописана опция для запуска сервера с нужным конфиг файлом
````
OPTIONS=-f conf/{first\second}.conf
````

3. в директории  конфигами httpd созданы first.conf second.conf
* в нашей ОС конфиг файлы этого сервиса находятся в /etc/httpd/conf

* добавялем параметры во второй
````
PidFile  /var/run/httpd-second.pid

Listen 8080
````
* unit файл /httpd.service  переименован - название httpd@.service превращает его в шаблон. 
* попытука запуска сервиса закончилась успешно
````
systemctl start httpd@first
systemctl start httpd@second
````

* проверка работы
````
systemctl status httpd@second

# смотрим открытые порты, и в выдаче ищем упоминание нашего сервиса
ss -tnulp | grep httpd
````

* в вагрантфайле дополнен стартовый скрипт - устанавливаются все нужные пакеты для spawn-fcgi, httpd

* также запсукается скрипт из файла test.sh. Он создает юнит файлы, скрипт watchlog, и запускает таймер. 
    * можно сделать несколько красивее - использовать провижинер file и загружать готовый файлики на ВМ, вместо echo