Настрокай клиентов rsyslog
=========

* Клиенты настраиваются для отправки логов из syslog и journald на сервер log
* Необходимо для централизованного хранения логов

Example Playbook
----------------

- hosts: all
  roles:
      - { role: rsyslog-client }

License
-------

BSD
