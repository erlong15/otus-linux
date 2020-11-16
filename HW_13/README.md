# SELinux

## Домашнее задание

```txt
Цель: Тренируем умение работать с SELinux: диагностировать проблемы и модифицировать политики SELinux для корректной работы приложений, если это требуется.
1. Запустить nginx на нестандартном порту 3-мя разными способами:
- переключатели setsebool;
- добавление нестандартного порта в имеющийся тип;
- формирование и установка модуля SELinux.
К сдаче:
- README с описанием каждого решения (скриншоты и демонстрация приветствуются).

2. Обеспечить работоспособность приложения при включенном selinux.
- Развернуть приложенный стенд
https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems
- Выяснить причину неработоспособности механизма обновления зоны (см. README);
- Предложить решение (или решения) для данной проблемы;
- Выбрать одно из решений для реализации, предварительно обосновав выбор;
- Реализовать выбранное решение и продемонстрировать его работоспособность.
К сдаче:
- README с анализом причины неработоспособности, возможными способами решения и обоснованием выбора одного из них;
- Исправленный стенд или демонстрация работоспособной системы скриншотами и описанием.
Критерии оценки:
Обязательно для выполнения:
- 1 балл: для задания 1 описаны, реализованы и продемонстрированы все 3 способа решения;
- 1 балл: для задания 2 описана причина неработоспособности механизма обновления зоны;
- 1 балл: для задания 2 реализован и продемонстрирован один из способов решения;
Опционально для выполнения:
- 1 балл: для задания 2 предложено более одного способа решения;
- 1 балл: для задания 2 обоснованно(!) выбран один из способов решения.

```

## Описание работы

### 1. Запустить nginx на нестандартном порту 3-мя разными способами

1. разершить всем использовать любые порты (стенд nginx01)

    ```bash
    setsebool -P nis_enabled 1
    ```

    ```bash
    [vagrant@nginx01 ~]$ sudo ss -ltpn | grep nginx
    LISTEN     0      128          *:5199                     *:*                   users:(("nginx",pid=3258,fd=6),("nginx",pid=3257,fd=6))
    LISTEN     0      128       [::]:5199                  [::]:*                   users:(("nginx",pid=3258,fd=7),("nginx",pid=3257,fd=7))
    ```

1. добавить конкретный порт в контекст прав nginx (стенд nginx02)

    ```bash
    semanage port -a -t http_port_t -p tcp {{ nginx_port }}
    ```

    ```bash
    [vagrant@nginx02 ~]$ sudo ss -ltpn | grep nginx
    LISTEN     0      128          *:5199                     *:*                   users:(("nginx",pid=7504,fd=6),("nginx",pid=7503,fd=6))
    LISTEN     0      128       [::]:5199                  [::]:*                   users:(("nginx",pid=7504,fd=7),("nginx",pid=7503,fd=7))
    ```

1. создать и добавить модуль из аудит логов. Предварительно выключаем SElinux (```setenforse 0```) и создаем модуль правил из аудит логов. Полсде подключения модуля включаем SELinux (стенд nginx03)

    ```bash
    audit2allow -M httpd_t --debug  < /var/log/audit/audit.log
    # checkmodule -M -m -o httpd_t.mod httpd_t.te
    # semodule_package -o httpd_tp.pp -m httpd_t.mod
    semodule -i httpd_t.pp
    ```

    ```bash
    [vagrant@nginx03 ~]$ sudo ss -ltpn | grep nginx
    LISTEN     0      128          *:5199                     *:*                   users:(("nginx",pid=7765,fd=6),("nginx",pid=7764,fd=6))
    LISTEN     0      128       [::]:5199                  [::]:*                   users:(("nginx",pid=7765,fd=7),("nginx",pid=7764,fd=7))
    ```

Все способы реализованы на стенде из 3 виртуальных машин (на каждый способ по машине), для запуска стенда:

```bash
cd HW_13/nginx_selinux
vagran up
```

### 2. Обеспечить работоспособность приложения при включенном selinux

* Развернуть приложенный стенд

    ```bash
    cd HW_13/selinux_dns_problems
    vagran up
    ```

* Выяснить причину неработоспособности механизма обновления зоны (см. README)
  * Отключил selinux на ns01
  * с клиента обновил зону
  * проверил аудит лог на сервере

    ```bash
    root@ns01 vagrant]# setenforce 0
    [root@ns01 vagrant]# sestatus  
    SELinux status:                 enabled
    SELinuxfs mount:                /sys/fs/selinux
    SELinux root directory:         /etc/selinux
    Loaded policy name:             targeted
    Current mode:                   permissive
    Mode from config file:          enforcing
    Policy MLS status:              enabled
    Policy deny_unknown status:     allowed
    Max kernel policy version:      31
    [root@ns01 vagrant]# audit2why < /var/log/audit/audit.log
    [root@ns01 vagrant]# audit2why < /var/log/audit/audit.log
    type=AVC msg=audit(1602106932.251:2359): avc:  denied  { create } for  pid=8105 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=1

            Was caused by:
                    Missing type enforcement (TE) allow rule.

                    You can use audit2allow to generate a loadable module to allow this access.

    type=AVC msg=audit(1602106932.251:2359): avc:  denied  { write } for  pid=8105 comm="isc-worker0000" path="/etc/named/dynamic/named.ddns.lab.view1.jnl" dev="sda1" ino=67149894 scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=1

            Was caused by:
                    Missing type enforcement (TE) allow rule.

                    You can use audit2allow to generate a loadable module to allow this access.

    ```

  * логи показали что для выполнения обновления зоны требуется контекст с правами на создание и запись в файлы каталога /etc/named
  * есть 2 пути решения проблемы
    1. создать модуль с правилами

        ```bash
        [root@ns01 vagrant]# audit2allow  < /var/log/audit/audit.log


        #============= named_t ==============

        #!!!! WARNING: 'etc_t' is a base type.
        allow named_t etc_t:file { create write };
        [root@ns01 vagrant]# audit2allow -M named_t --debug  < /var/log/audit/audit.log
        ******************** IMPORTANT ***********************
        To make this policy package active, execute:

        semodule -i named_t.pp

        [root@ns01 vagrant]# semodule -i named_t.pp
        [root@ns01 vagrant]# cat named_t.te

        module named_t 1.0;

        require {
                type etc_t;
                type named_t;
                class file { create write };
        }

        #============= named_t ==============

        #!!!! WARNING: 'etc_t' is a base type.
        allow named_t etc_t:file { create write };
        ```

    1. выставить верный контекст на файлы в папке /etc/named, из подходящего по правам это ```named_zone_t```

        ```bash
        [root@ns01 named]# semanage fcontext  -l | grep named | grep etc
        /etc/rndc.*                                        regular file       system_u:object_r:named_conf_t:s0
        /etc/unbound(/.*)?                                 all files          system_u:object_r:named_conf_t:s0
        /etc/named\.rfc1912.zones                          regular file       system_u:object_r:named_conf_t:s0
        /var/named/chroot/etc(/.*)?                        all files          system_u:object_r:etc_t:s0
        /var/named/chroot/etc/pki(/.*)?                    all files          system_u:object_r:cert_t:s0
        /var/named/chroot/etc/named\.rfc1912.zones         regular file       system_u:object_r:named_conf_t:s0
        /etc/named\.conf                                   regular file       system_u:object_r:named_conf_t:s0
        /etc/named\.root\.hints                            regular file       system_u:object_r:named_conf_t:s0
        /etc/rc\.d/init\.d/named                           regular file       system_u:object_r:named_initrc_exec_t:s0
        /etc/rc\.d/init\.d/unbound                         regular file       system_u:object_r:named_initrc_exec_t:s0
        /etc/rc\.d/init\.d/named-sdb                       regular file       system_u:object_r:named_initrc_exec_t:s0
        /var/named/chroot/etc/rndc\.key                    regular file       system_u:object_r:dnssec_t:s0
        /var/named/chroot/etc/localtime                    regular file       system_u:object_r:locale_t:s0
        /var/named/chroot/etc/named\.conf                  regular file       system_u:object_r:named_conf_t:s0
        /etc/named\.caching-nameserver\.conf               regular file       system_u:object_r:named_conf_t:s0
        /var/named/chroot/etc/named\.root\.hints           regular file       system_u:object_r:named_conf_t:s0
        /var/named/chroot/etc/named\.caching-nameserver\.conf regular file       system_u:object_r:named_conf_t:s0
        /etc/named(/.*)?                                   all files          system_u:object_r:named_zone_t:s0
        ```

  * в текущем стенде реализовано добавление контекста к папке, так как это дает меньше прав для приложения нежели модуль дающий права писать в любую папку /etc. Добавленный код для деплоя стенда  ниже.(выставляем новый контекст всем файлам в папке /etc/named и применяем изменения на текущих файлах )

    ```yaml
    - hosts: ns01 # server ns01 provision
      become: true
      tasks:
        - name: set new context named
          command: semanage fcontext -a -t named_zone_t "/etc/named(/.*)?"
        - name: restore context
          command: restorecon -R /etc/named
    ```
