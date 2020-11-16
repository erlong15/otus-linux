# PAM

## Домашнее задание

```txt
1. Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников
* дать конкретному пользователю права работать с докером
и возможность рестартить докер сервис
```

## Описание

### Установка ansible

```bash
cd HW_12
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip inatall -r requirements.txt
```

### Запуск стенда

```bash
vagrant up
ansible -v -i inventory/vagrant.yml -m ping all
ansible-playbook -i inventory/vagrant.yml playbooks/inatall_pam.yml
```

### Прицип действия

* На стенде присутствует 4 ползователя: ```admin,user1,user2,vagrant```
* user2 не в группе admin
* при логине по ssh модуль pam_exec.so запускает [баш скрипт](template/test_admin.sh)
* На основе присутствия в группе admin а затем по номеру текущего дня недели происходит решение о входе в систему.
