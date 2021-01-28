Установка barman
=========

* barman - ПО для бекапа и восстановления postgres
* Устанавливает на  barman и производит настройку


Example Playbook
----------------

- hosts: backup server
  roles:
      - { role: barman_install }

License
-------

BSD
