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

3. Создан сркипт /opt/watchlog.sh. Не забыть прописать ему право на исполнение!
````
#!/bin/bash
WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
    # logger sends log to system journal
    logger "$DATE: Keyword was found!"
else
    exit 0
fi
````

4. Создаем unit-файл watchlog.service в /etc/systemd/system/. Он описывает непосредствено сам сервис - описание, что запускать, откуда брать конфиг
````
[Unit]
Description=My watchlog service
[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
````

5. Создаем unit файл для таймера. /etc/systemd/system/watchlog.timer. 
Он описывает зависимости (wantedBy) и параметры запуска (секция [Timer] )
* * возможные ошибки с запуском сервиса (сервис не запускается через таймер с первого раза, а только после запуска руками)
решаются добавлением параметра OnActiveSec=0
* точность запуска скрипта раз в 30 сек определяется параметром AccuracySec=0
````
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnActiveSec=0
OnUnitActiveSec=30
AccuracySec=0
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
````

6. Запускаем таймер watchlog-а. 
````
systemctl start watchlog.timer

#просмотр системного журнала:
tail -f /var/log/messages
````

* смотрим статус
````
systemctl status watchlog.service

# смотрим журнал systemd
journalctl -xe
````
результат работы (/var/log/messages)
````
Dec  8 20:04:35 localhost systemd: Starting My watchlog service...
Dec  8 20:04:35 localhost root: Sun Dec  8 20:04:35 UTC 2019: Keyword was found!
Dec  8 20:04:35 localhost systemd: Started My watchlog service.
Dec  8 20:05:05 localhost systemd: Starting My watchlog service...
Dec  8 20:05:05 localhost systemd: Started My watchlog service.
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
OPTIONS=-f conf/first.conf
# for second
OPTIONS=-f conf/second.conf
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

* в вагрантфайле дополнен провижинер SHELL - устанавливаются все нужные пакеты для spawn-fcgi, httpd

* провижинер file копирует на ВМ всю директорию files с целевыми файлами

* третий провижинер запускает скрипт HW5/start.sh, который автоматизирует вышеуказанные задания
   * раскидывает unit-файлы и конфиги по нужным директориям
   * в конфиге spawn-fcgi раскомментирует строки с параметрами (утилита sed)
   * копирует файл httpd.conf и добавляет необходимые параметры в конфиг второго экземпляра
   * добавляет два файла конфига /etc/sysconfig/httpd-first, httpd-second

* проверка работы - на созданной ВМ остается только запустить сервисы , проверить записи в /var/log/messages, проверить статус сервиса и открытые порты

* протокол в файле vag_auto.log