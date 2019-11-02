## Отчет о домашней работе №1

* скачан репозиторий manual_kernel_update

* запустил VM с базовым Centos/7, провел обновление ядра вручную, используя следующие команды:

 * подключение репозитория
 ````
  sudo yum install -y http:///www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
 ````
 * установка последней версии ядра
 ````
 sudo yum --enablerepo elrepo-kernel install kernel-ml

 ````
 * обновил конфигурацию загрузчика и выбрал загрузку по умолчанию с новым ядром
 ````
 sudo grub2-mkconfig -o /boot/grub2/grub.cfg # 
 sudo grub2-set -default 0
  ````
  
* с помощью шаблона packer/centos.json создан файл-образ Centos-7.7.1908-kernel-5-x86_64-Minimal.box

  *  при создании этого образа были использованы bash скрипты, обновляющие ядро

* вопрос - в centos.json указан образ по URL, скачивание гигабайта занимает большой объем времени. Возможно ли заменить ссылку на образ с URL на box Centos/7 , уже скачанный вагрантом на локальную машину?

* образ добавлен в список для vagrant
````
vagrant box add --name centos7-5 centos Centos-7.7.1908-kernel-5-x86_64-Minimal.box
````
* запустили образ в папке test (ее не коммитил). Автоматически создался vagrantfile
````
vagrant init centos-7-5
````

  * при запуске возникла ошибка создания virtualbox shared folders. Нужно подправить vagrantfile, чтобы устранить. В ПРОЦЕССЕ
    * в логах вагрант ругается на невозможность создать расшаренные папки на VM. Недоступна файловая система "vboxsf"
     * для установки нужен специализированный модуль ядра и VirtualBox Kernel Additions

     * нужно прокатать это на руками запущенной VM, затем создать скрипт, прописать ссылку на него в .json шаблоне

* при запуске VM из нового образа, проверил версию ядра
````

uname -r
````

* ядро обновлено до весрии 5.3.8.1

* первая версия vagrantfile скопирована в свой репозиторий ветка homework1, изначальные vagrantfile (откуда у меня их два??) скопированы в папку default_vagrantfiles

* образ выгружен в Vagrant Cloud. Доступен по ссылке https://app.vagrantup.com/max89k/boxes/centos-7-5



# Инструкции

* [Как начать Git](git_quick_start.md)
* [Как начать Vagrant](vagrant_quick_start.md)

## otus-linux

Используйте этот [Vagrantfile](Vagrantfile) - для тестового стенда.
