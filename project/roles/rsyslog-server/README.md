Настрокай серверв rsyslog
=========

* настраивается коллектор логов
* логи будут хранится по пути ```/var/log/rsyslog/%FROMHOST-IP%/%$year%-%$month%-%$day%/%PROGRAMNAME%.log```


Example Playbook
----------------

- hosts: log
  roles:
      - { role: rsyslog-server }

License
-------

BSD
