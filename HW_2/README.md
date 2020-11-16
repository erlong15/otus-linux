# Дисковая подсистема

## Домашнее задание

Создан Vagranfile который:

* Создает RAID10 из 6 дисков
* сохраняет конфигурацию рейда в файл ```/etc/mdadm/mdadm.conf```
* Создает 5 партиций  с переменным объемом
* Создает на партициях файловую систему
* Монтирует партиции в систему
* добавляет записи в ```/etc/fstab``` для автомонтирования при загрузке
* в файле [typescript_fail_remove_raid10](typescript_fail_remove_raid10) запись из программы ```script``` поломки/починки Raid10

Запуск:

```bash
cd HW_2
vagrant up
```

## Описание работы поломки/восстановления

* Проверяем что рейд работает

```bash
cat /proc/mdstat
mdadm -D /dev/md0
lsblk
```

* Вызываем сбой диска

```bash
mdadm /dev/md0 --fail /dev/sdf
```

* Смотрим Что диск отключился

```bash
cat /proc/mdstat
mdadm -D /dev/md0
```

* Удфляем сбойный диск

```bash
mdadm /dev/md0 --remove /dev/sdf
```

* Добавляем новыйдиск в рейд

```bash
mdadm --zero-superblock --force /dev/sdh
mdadm /dev/md0 --add /dev/sdh
```

* Проверяем

```bash
cat /proc/mdstat
mdadm -D /dev/md0
```
