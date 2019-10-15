#!/usr/bin/env bash

# проверка группы

if groups $PAM_USER | grep -c  admin; then
    echo "You are in the admin_group group."
    exit 0
    else
    echo "You are not in the admin group."
fi

#проверка дня через API. В случае если день рабочий, вернет 0
if [[ $(curl -s https://isdayoff.ru/$(date +%y%m%d)) -eq 0 ]]; then
    exit 0
fi

echo "Login denied. Today is a day off!"
exit 1
