

* в файле ~/rpmbuild/SPECS/nginx.spec
смотрим раздел %build, добавляем строку --with-openssl=/root/openssl-1.1.1a

соответственно, разархивируем архив с опенссл туда, в /root

попытка сборки проваливалась, ошибка на 28 строке. Переменная на 27 строке не определялась, команда lsb_release не работала

Установил пакет redhat_lsb

Затем при сборке не хватает пакетов openssl-devel, pcre-devel, zlib-devel

замена строки в файле nginx.spec с помощью скрипта - меняем --with-debug на --with-openssl
sed -i 's|--with-debug|--with-openssl=/home/vagrant/openssl-1.1.1d|' rpmbuild/SPECS/nginx.spec 

rpm пакет устанавливается успешно ( правда, нужно снести nginx который в вагранте прописан)


осталось создать свой репозиторий (с.9)
скрипт для добавления строки autoindex on в конфиг nginx
sed -i 's|index.htm;|index.htm;\n        autoindex on;|' /etc/nginx/conf.d/default.conf