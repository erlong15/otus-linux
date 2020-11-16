# Работа с RPM

## Домашнее задание

### Запуск

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
vagrant up
```

### Описание

Собран свой rpm nginx c фичами:

```bash
    --with-http_geoip_module \
    --with-openssl=/root/openssl-1.1.1g \
    --with-http_secure_link_module
```

* Затем установлен на систему и создан репозиторий. 
* Для проверки, из репозитория установлен ```percona-release```

## Задание со звездочкой

Собранный RPM покет упакован в Docker лежит в Docker hub с именем ```iudanet/nginx-otus:v1```

пример запуска

```bash
docker run --rm -d --name iudanet-nginx-otus -p 8080:80 iudanet/nginx-otus:v1
```
