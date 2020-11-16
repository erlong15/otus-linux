# Ansible

## Домашнее задание

```txt
Первые шаги с Ansible
Подготовить стенд на Vagrant как минимум с одним сервером. На этом сервере используя Ansible необходимо развернуть nginx со следующими условиями:
- необходимо использовать модуль yum/apt
- конфигурационные файлы должны быть взяты из шаблона jinja2 с перемененными
- после установки nginx должен быть в режиме enabled в systemd
- должен быть использован notify для старта nginx после установки
- сайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible

Домашнее задание считается принятым, если:
- предоставлен Vagrantfile и готовый playbook/роль ( инструкция по запуску стенда, если посчитаете необходимым )
- после запуска стенда nginx доступен на порту 8080
- при написании playbook/роли соблюдены перечисленные в задании условия
```

Установка ansible

```bash
cd HW_11/ansible
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip inatsll -r requirements.txt
```

создание роли

```bash
ansible-galaxy init roles/nginx
```

Запуск стенда

```bash
vagrant up
ansible -v -i inventory/vagrant.yml -m ping all
ansible-playbook -i inventory/vagrant.yml playbooks/inatall_nginx.yml
```
