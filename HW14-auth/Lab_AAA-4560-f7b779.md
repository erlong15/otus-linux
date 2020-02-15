## Оформление ответов по лабораторной работе
* Создать репозиторий на github.com или gitlab.com
* приложить в репозиторий  README.md с ответами и скриншотами экрана
* Задания отмеченные (*) являются дополнительными для самостоятельного разбора

---
## Базовые утилиты для работы с пользователями и правами
```bash
useradd
passwd
usermod
userdel
groupadd
groupdel
groupmod
groups
id
newgrp
gpasswd
chgrp
chown
chmod
```
* Самоятельно посмотрите man по каждой
---

## Создаем пользователей

```bash
man useradd
useradd -m -s /bin/bash user1
useradd -m -s /bin/bash user2 
```
* В результате у вас создадуться два пользователя
* Какие UID создались у пользователей?
    * посмотреть можно с помощью команды id или в файле /etc/passwd
* Что означают опции -m и -s
* Ответы приложить в README.md

---

## Создаем группу и добавляем туда пользователей

```bash
man groupadd
man gpasswd
groupadd admins
gpasswd -a user1 admins
gpasswd -a user2 admins
id user1
id user2
```
* Результаты команды id добавить в README.md
* (*) Через usermod сделайте группу admins основной для  user1. Результат id приложить в README.md

---

## Создать каталог от рута и дать права группе admins туда писать

```bash
mkdir /opt/upload
chmod 770 /opt/upload
chgrp admins /opt/upload
```
* что означают права 770 ?
* создать по файлу от пользователей user1 и user2 в каталоге /opt/uploads
* проверьте с какой группой создались файлы от каждого пользователя. Как думаете - почему?
* (*) попробуйте сменить текущую группу пользователя  ```newgrp admins``` у пользователя user2 и создайте еще файл
* приложить ```ls -l /opt/upload```  в  README.md

---

## Создать пользователя user3 и дать ему права писать в /opt/uploads

* Создайте пользователя user3
* Попробуйте записать из под него файл в /opt/uploads. Должны получить ошибку
* Считайте acl с каталога. Добавьте черерз  setfacl права на запись в каталог.
```bash
man getfacl
man setfacl
getfacl /opt/upload
setfacl -m u:user3:rwx /opt/upload
su - user3
touch /opt/upload/user3_file
ls -l /opt/upload/user3_file
```
* приложить ```ls -l /opt/upload```  в  README.md
* приложить финишный acl  директории в README.md
---

## Установить GUID флаг на директорию /opt/uploads

_текущие версии Linux игнорируют установку SUID на диреторию, также игнорируется выставление SUID на shell скрипт_

```bash
chmod g+s /opt/upload
su - user3
touch /opt/upload/user3_file2
ls -l /opt/upload/user3_file2
```
* Приложить ```ls -l /opt/upload```  в  README.md
* Объяснить почему изменилась группа при создании

---
## Установить  SUID  флаг на выполняемый файл

_текущие версии Linux игнорируют выставление SUID на shell скрипт (проеврка на shebang)_

* Установим suid бит на просмотрщик cat 
* В начале  попробуйте прочитать cat /etc/shadow  из под пользователя user3
* Установить suid /bin/cat и прочитайте снова из под user3
* В README.md добавьте оба результат
* Объясните почему

---
 
 
##  Сменить владельца  /opt/uploads  на user3 и добавить sticky bit
```bash
chown user3 /opt/upload
chmod +t /opt/upload
su - user1
touch /opt/upload/user1_file_test
ls -l /opt/upload/user1_file_test
su - user3
rm -f  /opt/upload/user1_file_test
```
* Объясните почему user3 смог удалить файл, который ему не принадлежит
* Создайте теперь файл от user1 и удалите его пользователем user1
* Объясните результат

---

## Записи в sudoers
* попробуйте из под user3 выполнить ```sudo ls -l /root```
* для редактирования sudoers используйте  visudo
* почему у вас не получилось?
```bash
vi /etc/sudoers.d/user3
user3	ALL=NOPASSWD:/bin/ls
```

* добавьте запись в /etc/sudoers.d/admins разрешающий группе admins любые команды с вводом пароля

