### Практика к уроку 3. LVM 

Домашнее задание
На имеющемся образе:
/dev/mapper/VolGroup00-LogVol00 38G 738M 37G 2% /

1. Уменьшить том под "/" до 8G
2. Выделить том под /home
3. Выделить том под /var - сделать в mirror
4. /home - сделать том для снэпшотов
5. Прописать монтирование в fstab. Попробовать с разными опциями и разными
файловыми системами ( на выбор)

Работа со снапшотами:
- сгенерить файлы в /home/
- снять снапшот
- удалить часть файлов
- восстановится со снапшота
- залоггировать работу можно с помощью утилиты script

* ДОП ЗАДАНИЕ * на нашей куче дисков попробовать поставить btrfs/zfs - с кешем, снапшотами -
разметить здесь каталог /opt


### выполнение
* переключаемся сразу на root, чтоб не мучаться

* воспользуемся lsblk для просмотра списка блочных устройств
  * используем sdb, sdc для общей практики и снапшотов; sdd, sde - для lvm-mirror

* lvmdiskscan - замена lsblk


1. создадим PV для дальнейшего использования LVM
```
pvcreate /dev/sdb
```
2. создаем первый VG -  уровень абстракции
````
vgcreate otus /dev/sdb
````
3. создаем Logical Volume (далее = LV)
````
lvcreate -l+80%FREE -n sunduk otus  # sunduk - name of LV, otus - name of VG, +80% free- free space
````
4. просмотр информации о созданном VG, LV
````
vgs # общий список
vgdisplay otus # подробно о указанном VG
vgdisplay -v otus | grep 'PV Name' # просмотр подробного списка  / выборка параметра - список дисков в PV

lvs # just a list of short info
lvdisplay /dev/otus/sunduk # full info

````

5. создадим еще один LV , с испльзованием параметра - абсолютного значения в Мб
```
lvcreate -L100M -n mailbox otus # -L100M = size 100Mb; -n = name
```
6. создание на LV файловой системы и монтирование 
````
mkfs.ext4 /dev/otus/sunduk

# монтирование
mkdir /data
mount /dev/otus/sunduk /data/   # монтируем наш LV в папку /data

mount | grep /data # команда mount без аргумента выдает мегаподробную информацию о всех точках монтирвоания. А нас интересует только /data

````

7. расширение LVM
   * расширим файловую систему на LV /dev/otus/sunduk засчет нового блочного устройства /dev/sdc
    ```` # создадим PV
        pvcreate /dev/sdc

        # расширение VG 
        vgextend otus /dev/sdc

        # check that new disk is added
        vgdisplay -v otus | grep 'PV Name'

        # check that space is now 12 Gb
        vgs
    ````
    * Сымитируем занятое место с помощью команды dd для большей наглядности
    ````
    #dd - побайтовое копирование, /dev/zero - нулевые байты, в рандомный файл /data/*, кусками по 1Мб, 8к раз
    dd if=/dev/zero of=/data/test.log bs=1M count=8000 status=progress
    ````
#### Problem?? -> solved
   * после копирования видим, что /data/test.log записывается в LV VolGroup00, которая смонтирована в /

   * вариант:- попробовать смонтировать заново в /
        ```` mount /dev/VolGroup00/LogVol00 / 
        # ошибка, уже смонтировано туда
        ````
    * решение: не смонтировался LV "sunduk" из-за опечатки, монтируем еще раз в /data, все в порядке 


 *  производим расширение командой lvextend
 ````
lvextend -l+80%FREE /dev/otus/sunduk
# STDOUT:
 Size of logical volume otus/sunduk changed from <8.00 GiB (2047 extents) to <11.12 GiB (2846 extents).
  Logical volume otus/sunduk successfully resized.

  lvs # проверяем изменения
 ````

 * изменим файловую систему (resize2fs)
 ```
resize2fs /dev/otus/sunduk

#check
df -Th /data

# теперь появились дополнительные 2.6 гб
 ```

 8. Уменьшение LV
  * используем команду lvreduce
  * NB! перед этим необходимо отмонтировать ФС, проверить на ошибки, уменьшить размер
```
umount /data

e2fsck -fy /dev/otus/sunduk
# ключи -fy ??
resize2fs /dev/otus/test 10G
# параметры - где меняем и насколько
```
* теперь можно использовать lvreduce
```
lvreduce /dev/otus/sunduk -L 10G

mount /dev/otus/sunduk /data/

df -Th /data/

lvs /dev/otus/sunduk
```

### Снепшоты LVM
* создается командой lvcreate -s, флаг -s указывает на создание снимка
```
lvcreate -L 500M -s -n test-snap /dev/otus/sunduk
#проверяем параметры созданного тома
vgs -o +lv_size,lv_name | grep test

#смотрим на изменения в выдаче команды lsblk
lsblk

# otus-sunduk-real - оригинальный LV

# otus-test -- snap (10Gb) - это снапшот. 

# otus-test-snap-cow (500Mb) - сюда пишутся изменения, copy on write
```

* монтируем снапшот, как обычную LV
```
mkdir /data-snap

mount /dev/otus/test-snap /data-snap/

ll /data-snap/
```

#### откат\восстановление с помощью снпашота
1. удалим лог файл
2. размонтируем целевую директорию : umount /data

3. используем утилиту lvconvert
```
lvconvert --merge /dev/otus/test-snap
```
4. Монтируем обратно ФС в директорию /data. Проверяем, что тестовый файл опять на месте
```

mount /dev/otus/sunduk /data

ll /data
```
### LVM Mirroring
* создаем два PV из двух блочных устройств
* создаем из них группу VG
* создаем LV с ключом -m1, что значит mirror 1
```

```