Домашнее задание
PAM
 Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников


Проще всего можно было бы это реализовать с помощью модуля pam_time, но синтаксис файла /etc/secirity/time.conf не позволяет ставить логический оператор '!' перед обозначением группы
иначе строка *;*;!admins;!Wd и включение pam_time для sshd решило бы проблему


1. Добавим в /etc/pam.d/sshd строку, включающую модуль pam_exec со ссылкой на скрипт weekend_check.sh. 
```
account    required     pam_exec.so  /usr/local/bin/weekend_check.sh
```


2. сам скрипт. Вывод echo не работает вместе с PAM, использовался для отладки (для использования без PAM, $PAM_USER поменять на $USER).
```
#!/bin/bash
Day=`date +%u`

if [[ '67' == *"$Day"* ]]; then
   
  if [[ `grep $PAM_USER  /etc/group | grep 'admins'` ]]; then
   echo "You are allowed to login at weekend" && exit 0
  else 
   echo "return on workday" && exit 1
  fi

 else 
  echo "today is workday, welcome!" && exit 0
fi
```

3. добавление пользователя night в группу admins и присвоение ей статуса основной
```
gpasswd -a night admins
usermod -g admins night
```

 Теперь в субботу и воскресенье можем залогиниться только пользователем night