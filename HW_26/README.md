#

## Домашнее задание

```txt
Домашнее задание
развернуть стенд с веб приложениями в vagrant
Варианты стенда
nginx + php-fpm (laravel/wordpress) + python (flask/django) + js(react/angular)
nginx + java (tomcat/jetty/netty) + go + ruby
можно свои комбинации

Реализации на выбор
- на хостовой системе через конфиги в /etc
- деплой через docker-compose

Для усложнения можно попросить проекты у коллег с курсов по разработке

К сдаче примается
vagrant стэнд с проброшенными на локалхост портами
каждый порт на свой сайт
через нжинкс
```

## Описание

Используются проекты

* [https://github.com/iudanet/react-redux-realworld-example-app] (React)
* [https://github.com/iudanet/flask-realworld-example-app] (Python / Flask )
* wordpress (php / php-fpm)

Проэкты разворачиваются через docker-compose

На хостовой машине:

* [http://localhost:8080] - Wordpres
* [http://localhost:8081] - React + Flask

### Установка Ansible

```bash
cd HW_26
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### Запуск проекта

```bash
source venv/bin/activate # Окружение с Ansible
make up # Запуск загранта и провижинига
```

* [http://localhost:8080] - Wordpres
* [http://localhost:8081] - React + Flask
