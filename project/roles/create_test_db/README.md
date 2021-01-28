Подготовка Базы к работе
=========

* Создает базу
* создает пользователя для базы
* создает пользователя для репилкации


Example Playbook
----------------

- hosts: postgres-master
  roles:
      - { role: create_test_db }

License
-------

BSD
