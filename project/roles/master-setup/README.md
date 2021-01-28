Настройка master postgres
=========

* конфигурация для запуска мастера postgres

Example Playbook
----------------

- hosts: db1
  roles:
      - { role:master-setup  }

License
-------

BSD
