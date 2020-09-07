#!/bin/bash

get_pids(){
    ls /proc | grep -e "^[0-9]" | sort -n 
    # echo 1142
}

get_proces() {
    foo=$(test -f /proc/$1/cmdline && cat /proc/$1/cmdline)
    if [ -z "$foo" ]
    then
       if [ -z "$(get_proces_status_name $1)" ]
       then
        echo ""
       else
        echo "[$(get_proces_status_name $1)]"
       fi
    else
        echo ${foo}
    fi
}

get_proces_status_name () {
    test -f /proc/$1/status  &&  cat /proc/$1/status | grep "^Name:" | awk '{print $2}'
}

get_tty() {
    echo 1
}

get_stat() {
    test -f  /proc/$1/stat &&  awk '{print $3}'   /proc/$1/stat
}

get_time_cpu() {
     test -f  /proc/$1/stat && awk '{print $14 + $15 + $16 + $17}' /proc/$1/stat 
}
get_tty() {
    test -f  /proc/$1/stat && awk '{print  $7}' /proc/$1/stat
}

main(){
    echo "PID   TTY   STAT  TIME  COMMAND"
    for i in $(get_pids)
    do
        PID=${i}
        TTY=$(get_tty ${i})
        STAT=$(get_stat ${i})
        TIME=$(get_time_cpu ${i})
        COMMAND=$(get_proces "${i}")
       
        if [ -z "$STAT" ]
        then
            continue
        else 
            echo "${PID}    ${TTY}    ${STAT}     ${TIME}    ${COMMAND}"
        fi
    done
    }


main  2>/dev/null | column 
# get_proces 30000
# get_pids