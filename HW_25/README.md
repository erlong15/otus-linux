# LDAP

```txt
LDAP
1. Установить FreeIPA;
2. Написать Ansible playbook для конфигурации клиента;
3*. Настроить аутентификацию по SSH-ключам;
4**. Firewall должен быть включен на сервере и на клиенте.

В git - результирующий playbook. 
```

## Описание

* Используемая роль [https://github.com/freeipa/ansible-freeipa]
* [https://medium.com/netdef/using-vagrants-ansible-provisioner-to-build-a-freeipa-server-1007fbafd595]

## Описание работы

### установка ansible

```bash
cd HW_25
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### Запуск стенда

```bash
make install
```

### Примечания

* запуск через Makefile скачивает нужный репозиторий с ролью из github
* Ansible настраивает IPA сервер и клиента.
* Для проверки IPA можно прописать в /etc/hosts ```192.168.50.9 ipaserver.test.local```  и перейти в браузере по [https://ipaserver.test.local]
