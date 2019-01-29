# Vagrant quick start

1. Устанавливаете Vagrant: <https://www.vagrantup.com/downloads.html>  
2. Устанавливаете VirtualBox: <https://www.tecmint.com/install-virtualbox-on-redhat-centos-fedora>
3. Клонируете репозиторий со стендом и запускаете виртуальную машину:
    ```bash
    git clone git@github.com:erlong15/otus-linux.git  
    cd otuslinux  
    vagrant up  
    vagrant ssh otuslinux  
    ```

Полезные ссылки:  
<https://www.vagrantup.com/intro/getting-started/>
<https://www.shellhacks.com/ru/vagrant-tutorial-for-beginners/>

## Tips and FAQs

1. Почему у меня внезапно выросло занимаемое место в виртуальной машине развернутой с помощью Vagrant?

    Скорее всего вы добавили дополнительное блочное устройство и оно лежит в одной директории
    с Vagrantfile. Vagrant в свою очередь при `Vagrant up` делает rsync всего, что есть рядом с
    Vagrantfile в директорию виртуальной машины `/vagrant/`

2. Как добавить дополнительные диски с помощью Vagrantfile

    ```ruby
    home = ENV['HOME'] # Используем глобальную переменную $HOME

    MACHINES = {
    :otuslinux => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.101',
    :disks => {
        :sata1 => {
            :dfile => home + '/VirtualBox VMs/sata1.vdi', # Указываем где будут лежать файлы наших дисков
            :size => 8192,
            :port => 1
        },
        :sata2 => {
            :dfile => home + '/VirtualBox VMs/sata2.vdi',
            :size => 1024, # Megabytes
            :port => 2
        },
        :sata3 => {
            :dfile => home + '/VirtualBox VMs/sata3.vdi',
            :size => 1024,
            :port => 3
        }
    }
    },
    }
    ```
