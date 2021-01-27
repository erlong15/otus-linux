# Проект

## ТЗ

```txt
Проект
Цель: Создание рабочего проекта
веб проект с развертыванием нескольких виртуальных машин
должен отвечать следующим требованиям
- включен https
- основная инфраструктура в DMZ зоне
- файрвалл на входе
- сбор метрик и настроенный алертинг
- везде включен selinux
- организован централизованный сбор логов
```

## Запуск проекта

## Описсание

### Веб приложение

* https
* Описание приложения
* домены
  * [http://hc.otus.iudanet.com]

### база данных

### мониторинг

* Развернут стек prometheus - alertmanager - grafana
* домены
  * [http://grafana.otus.iudanet.com]
  * [http://prom.otus.iudanet.com]
  * [http://alerts.otus.iudanet.com]
* На хостах установлен  node_exporter  для сбора метрик
* в grafana длбавлен дашборд для метрик node_exporter
* Алерты шлются в канал slak

### Фаервол

* на всех хостах включен firewalld
* хост nginx имеет 2 интерфейса
  * зона `dmz` для подключений внешних пользоваталей
    * 80/tcp nginx http
    * 443/tcp nginx https
  * зона `work` для локальной доверенной сети
* Остальные хосты имеют 1 интерфейс с зоной `work`
* на всех хостах в зоне `work` разрешено
  * 9100/tcp node_exporter
  * 22/tcp sshd
* хосты app1 и app2
  * 8000/tcp django
* Хосты db1 и db2
  * 5432/tcp postgres
* хост log
  * 514/tcp rsyslog
  * 514/udp rsyslog
* хост monitoring
  * 9090/tcp prometheus web
  * 3000/tcp grafana web
  * 9093/tcp alertmanager web



### резервное копирование

* для бекапов файлов используется ```borgbackup```
* для бекапов postgres используется ```barman``` в режиме стриминга

### Логирование

* Используется rsyslog
* Вселоги с хостов из syslog и journald передаетюся через rsyslog на сервер ```log```
* сервер log принимает логи и раскладывает их по шаблону ```/var/log/rsyslog/%FROMHOST-IP%/%$year%-%$month%-%$day%/%PROGRAMNAME%.log```
* Postgres пишет логи в локальный syslog
* nginx пишет логи локально и в удаленный syslog server