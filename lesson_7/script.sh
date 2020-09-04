#!/bin/bash

while [ -n "$1" ]
do
case "$1" in
-x) if [ "$2" -eq "$2" ]
    then
        IP_COUNT="$2"
    fi
;;
-y) if [ "$2" -eq "$2" ]
    then
        HOST_COUNT="$2"
    fi
;;
-f) if [ -e "$2" ]
    then
        LOGFILE="$2"
    fi
;;
-mail) OTUS_EMAIL="$2"

;;
esac
shift
done
lockfile=/tmp/log_parser.loc
tmp_file=/tmp/log_parser.tmp

return_top_ip(){
    head -$IP_COUNT
}

return_top_host(){
    head -$HOST_COUNT
}

mail_subject() {
    echo "Subject: Otus access log statistics"
}

mail_send()   {
    ssmtp $OTUS_EMAIL 
}

ip_address(){
    awk '{print $1}'
}

access_code(){
     cut -d '"' -f3 | awk '{print $1}'
}

line_count(){
    wc -l < $LOGFILE | awk '{ print $1}'
}
line_filetr(){
    if [ "$LINE_OLD" -ne "${LINE_COUNT}" ]
    then
        sed -ne "$LINE_OLD,${LINE_COUNT}p"
    fi
}
url(){
    cut -d '"' -f2 | awk '{print $2}'
}

wordcount(){
    sort | uniq -c
}

sort_desc(){
    sort -rn
}

start_date(){
   cat $LOGFILE |line_filetr| awk '{print $4 $5}'| head -n 1
}
stop_date(){
   cat $LOGFILE |line_filetr| awk '{print $4 $5}' | tail -n 1
}

read_line_tmp() {
    if [ -e $tmp_file ]
    then
       cat $tmp_file
    else
       echo "1"
    fi
}

save_line_tmp(){
    echo $LINE_COUNT > $tmp_file
}
get_top_error_access_code(){
    echo ""
    echo "stat line $LINE_OLD stop line $LINE_COUNT "
    echo "Top error access code:"
    echo "=================================================="
    cat $LOGFILE  |line_filetr| access_code | wordcount | sort_desc | grep -v "[2-3][0-9][0-9]"
    echo ""
}

get_top_all_access_code() {
    echo ""
    echo "stat line $LINE_OLD stop line $LINE_COUNT "
    echo "Top all access code:"
    echo "=================================================="
    cat $LOGFILE  |line_filetr| access_code | wordcount | sort_desc
    echo ""
}

get_top_ip_address() {
    echo ""
    echo "stat line $LINE_OLD stop line $LINE_COUNT "
    echo "Top $IP_COUNT ip address:"
    echo "=================================================="
    cat $LOGFILE |line_filetr| ip_address | wordcount | sort_desc | return_top_ip
    echo ""

}

get_top_url() {
    echo ""
    echo "stat line $LINE_OLD stop line $LINE_COUNT "
    echo "Top $IP_COUNT  URL:"
    echo "=================================================="
    cat $LOGFILE |line_filetr| url | wordcount | sort_desc | return_top_host
    echo ""

}

get_data_range() {
    echo ""
    echo "Start $(start_date)"
    echo "Stop $(stop_date)"   
}

get_all_top() {
    LINE_COUNT=$(line_count)
    LINE_OLD=$(read_line_tmp)
    if [ "$LINE_OLD" -ne "${LINE_COUNT}" ]
    then
        mail_subject   
        get_data_range
        get_top_error_access_code
        get_top_all_access_code
        get_top_ip_address
        get_top_url
        save_line_tmp
    else
        mail_subject
        echo "No new logs"
    fi
}

main() {
    if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null;
    then
        trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
        ################
        get_all_top  |  mail_send
        ################
        rm -f "$lockfile"
        trap - INT TERM EXIT
    else
        echo "Failed to acquire lockfile: $lockfile."
        echo "Held by $(cat $lockfile)"
    fi

}

main
