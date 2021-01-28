Настройка firewalld
=========

* запуск firewalld
* настройка зон на портах
* настройка разрешенных портов

Example Playbook
----------------

- hosts: all
  roles:
      - { role: firewalld }

License
-------

BSD
