Настройка master postgres
=========

* конфигурация для запуска реплики postgres
* Запускается базовый бекап с мастера перед стартом

Example Playbook
----------------

- hosts: db1
  roles:
      - { role:slave-setup  }

License
-------

BSD
