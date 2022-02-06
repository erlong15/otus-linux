# ДЗ 1. Обновление ядра Linux.

1. Установить VirtualBox
2. Установить Vagrant
3. Установить Packer
4. Настроить GitHub
5. Обновить ядро linux
6. Создать образ с обновленным ядром
7. Загрузить образ в Vagrant Cloud

## Домашнее задание выполнено на MacOS Monterey 12.1

## Установка VirtualBox

VirtualBox 6.1 уже был на компьютере, не пришлось устанавливать.

## Установка Vagrant

Vagrant 2.2.10 уже был на компьютере, не пришлось устанавливать.

## Установка Packer

Packer 1.7.10 был поставлен по инструкции из офицальной документации с помощью brew. Никаких проблем не возникло.

## Настройка GitHub

GitHub уже был настоен. Пропустил этот шаг.

## Обновления ядра.

1. Сделал fork `https://github.com/dmitry-lyutenko/manual_kernel_update` и склонировал `https://github.com/raymanovg/manual_kernel_update`.
2. Сдела fork `https://github.com/erlong15/otus-linux` и склонировал `https://github.com/raymanovg/otus-linux`
3. Создал директорию hw_1-manual_kernal_update в слонированном проекте otus-linux
4. Скопировал содержимое склонированного проекта manual_kernel_update в hw_1-manual_kernal_update.
5. Зашел в директорию hw_1-manual_kernal_update и запустил `vagrant up`. Виртуалка поднялась без каких либо проблем.
6. Зашел на виртуалку с помощью `vagrant ssh`.
7. Набрал команду `uname -r` и увидел версию ядра `3.10.0-1127.el7.x86_64`.
8. Подключил репозиторий из которого можно взять нужную версию ядра командой `sudo yum install -y http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm`
9. Поставил последнию версию ядра командой `sudo yum --enablerepo elrepo-kernel install kernel-ml -y`. Установка прошла без ошибок.
10. Обновил конфигурцию загрузчика командой `sudo grub2-mkconfig -o /boot/grub2/grub.cfg`.
11. Выбрал загрузку с новым ядром по-умолчанию `sudo grub2-set-default 0`.
12. Перезагрузил виртуалку командо `sudo reboot`.
13. После перезагрузки ssh соеденение отвалилось, зашел обратно на виртуалку `vagrant ssh`
14. Проверил версию ядра командой `uname -r` и увидел `5.16.7-1.el7.elrepo.x86_64`. Версия ядра обновилась.

## Создание образа с обновленным ядром.

1. Перешел в директорию `packer` и в ней выполнил команду `packer build centos.json` и получил ошибку 
>Error: Failed to prepare build: "centos-7.7"
>
>1 error occurred:
>	* Deprecated configuration key: 'iso_checksum_type'. Please call `packer fix`
>against your template to update your template to be compatible with the current
>version of Packer. Visit https://www.packer.io/docs/commands/fix/ for more
>detail.
>
>==> Wait completed after 9 microseconds
>
>==> Builds finished but no artifacts were created.

2. Решил проблему выполнив команду `packer fix centos.json > centos-fix.json` и создав новый исправленный конфиг.
3. Запустил команду `packer build centos-fix.json` и сбора завершилась успешно. Сборка заняла `19 мин и 37 сек`.
4. Протестировал образ
    -  Сделал импорт образа в vagrant командой `vagrant box add --name centos-7-5 centos-7.7.1908-kernel-5-x86_64-Minimal.box`. 
    - Проверил появился ли образ в списке
        >`vagrant box list`
        >
        >centos-7-5           (virtualbox, 0)

        Нужный образ появился в списке.
    - Создал новую директорию test и перешел в него.
    - Скопировал уже существующий Vagrantfile в эту директория. Поменял `:box_name => "centos/7"` на `:box_name => "centos-7-5"`.
    - Запустил виртуалку `vagrant up` и подключился к ней `vagrant ssh`
    - Проверил версию ядро
        >[vagrant@kernel-update ~]$ uname -r
        > 
        >5.16.7-1.el7.elrepo.x86_64
    Версия ядра новая.
    - Удалил тестовый образ из локального хранилища `vagrant box remove centos-7-5`.

## Загрузка образа в Vagrant Cloud.

1. Создал учетную запись в Vagrant Cloud.
2. Авторизовался с помощью команды `vagrant cloud auth login`.
3. Попытался опубликовать собранный образ с помощью команды `vagrant cloud publish --release raymanovg/centos-7-5 1.0 virtualbox centos-7.7.1908-kernel-5-x86_64-Minimal.box`, но появилась ошибка:
    >/opt/vagrant/embedded/lib/ruby/2.6.0/net/protocol.rb:44:in `connect_nonblock': SSL_connect returned=1 errno=0 state=error: tlsv1 alert protocol version (OpenSSL::SSL::SSLError)
4. Написал в общий чат и выснил проблема из-за старой `tls`. Обновил `vagrant` до версии `2.2.19`
5. Запустил еще раз команду для публикации образа и все прошло успешно. Cсылка на бокс https://app.vagrantup.com/raymanovg/boxes/centos-7-5.



