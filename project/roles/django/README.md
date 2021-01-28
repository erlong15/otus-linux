Деплой приложения django healthchecks
=========

* установка зависимостей
* клонирование проекта
* создание venv
* запуск миграций
* запуск в systemd

Example Playbook
----------------

- hosts: apps
  roles:
      - { role: django }

License
-------

BSD
