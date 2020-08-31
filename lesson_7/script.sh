#!/bin/bash

# написать скрипт для крона
# который раз в час присылает на заданную почту
# - X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
# - Y запрашиваемых адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
# - список всех кодов возврата с указанием их кол-ва с момента последнего запуска
# в письме должно быть прописан обрабатываемый временной диапазон
# должна быть реализована защита от мультизапуска
# Критерии оценки:
# трапы и функции, а также sed и find +1 балл
LOGFILE="./access.log"
IP_COUNT="10"
HOST_COUNT="10"
LINE_OLD="500"


return_top_ip(){
head -$IP_COUNT
}

return_top_host(){
head -$HOST_COUNT
}

mail_send()   {
 echo 1
}
# access_log_all_status() {
#     declare -A status_array
#     access_status_all=$(awk '{print $9}' < $LOGFILE | sort)
#     for status in $access_status_all
#     do
#         # echo $status
#         status_array+=([$status]=$(expr ${status_array[$status]} + 1))
#     done
#     for key in "${!status_array[@]}"
#     do
#      echo "Code $key: ${status_array[$key]}"
#     done
# }
ip_address(){
    awk '{print $1}'
}

access_code(){
    awk '{print $9}'
}

line_count(){
    wc -l < $LOGFILE | awk '{ print $1}'
}
line_filetr(){
    sed -ne "$LINE_OLD,$(line_count)p"
}
url(){
    awk '{print $7}'
}

wordcount(){
    sort | uniq -c
}

sort_desc(){
    sort -rn
}

get_top_all_access_code() {
    echo ""
    echo "stat line $LINE_OLD stop line $(line_count) "
    echo "Top all access code:"
    echo "=================================================="
    cat $LOGFILE  |line_filetr| access_code | wordcount | sort_desc
    echo ""
}

get_top_ip_address() {
    echo ""
    echo "stat line $LINE_OLD stop line $(line_count) "
    echo "Top $IP_COUNT ip address:"
    echo "=================================================="
    cat $LOGFILE |line_filetr| ip_address | wordcount | sort_desc | return_top_ip
    echo ""

}

get_top_url() {
    echo ""
    echo "stat line $LINE_OLD stop line $(line_count) "
    echo "Top $IP_COUNT  URL:"
    echo "=================================================="
    cat $LOGFILE |line_filetr| url | wordcount | sort_desc | return_top_ip
    echo ""

}

get_top_all_access_code

get_top_ip_address

get_top_url