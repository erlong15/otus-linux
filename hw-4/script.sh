#!/bin/bash

#variables
LOCK=/var/tmp/lockfile
LOGFILE=./access-4560-644067.log
RESULTFILE=./result

# Numbers of IP-adress and request IPs
x=10
y=10

#multi-lock detect
if [ -f $LOCK ]
then
        echo "File is busy"
        exit 1
else
        touch $LOCK
        trap 'rm -f $LOCK; exit $?' INT TERM EXIT
fi

#Function body
logging() {
        FTARGETFILE=$1
        FRESULTFILE=$2
        MINTIME=`head -n 1 $1 |awk '{print $4}'`
        MAXTIME=`tail -n 1 $1 |awk '{print $4}'`
        echo "" >> $2
        echo "Log start from $MINTIME to $MAXTIME" >> $2
        echo "" >> $2
        echo "$x IP addresses (with the largest number of requests) indicating the number of requests since the last time the script was run" >> $2
        cat $1 |awk '{print $1}' |sort |uniq -c |sort -rn| tail -$x >> $2
        echo "" >> $2
        echo "$y requested addresses (with the largest number of requests) indicating the number of requests since the last time the script was run" >> $2
        cat $1 |awk '{print $7}' |sort |uniq -c |sort -rn| tail -$y >> $2
        echo "" >> $2
        echo "All errors since the last launch" >> $2
        cat $1 |awk '{print $9}' |grep -E "[4-5]{1}[0-9][0-9]" |sort |uniq -c |sort -rn >> $2
        echo "" >> $2
        echo "A list of all return codes indicating their number since the last launch" >> $2
        cat $1 |awk '{print $9}' |sort |uniq -c |sort -rn >> $2
        echo "" >> $2
}

#Start function
logging $LOGFILE $RESULTFILE

#Sending mail to admin-linux@otus.ru
cat $RESULTFILE | mail -s "Logging NGINX" admin-linux@otus.ru

#Delete result file logs
rm -f $RESULTFILE
