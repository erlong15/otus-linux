#!/bin/bash

set -e

pid=""
tty=""


printf "%6s\t%s\t%s\t%s\t%.35s\n\n" PID TTY STAT TIME COMMAND

for filename in `ls -v /proc/`; do
 pid=$(echo $filename | cut -d"/" -f3)


if [ ! -e /proc/$pid/status ]; then
  continue
fi 

if [ -n "$pid" ] && [ "$pid" -eq "$pid" ] 2>/dev/null; then
  if [ -e "/proc/$pid/fd/0" ]; then
    tty=$(readlink -f /proc/$pid/fd/0 | cut -d"/" -f'3 4')
    if [ "$tty" = "null" ] ; then tty="?"; fi
  else
    tty="?"
  fi 

  is_lock=$(grep -w "VmLck:" /proc/$pid/status | awk -F "( *)" '{print $2}')
  
  if [[ $is_lock > 0 ]]; then 
    is_lock="L" 
  else
    is_lock="" 
  fi

  is_thread=$(grep -w "Threads:" /proc/$pid/status | awk -F " " '{print $2}')

  if [[ $is_thread > 1 ]]; then
    is_thread="l"
  else
    is_thread=""
  fi

  is_leader=$(cat /proc/$pid/stat | awk '{print $(NF-46)}')

  if [[ $is_leader -eq $pid ]]; then
    is_leader="s"
  else
    is_leader=""
  fi

  is_foreground=$(cat /proc/$pid/stat | awk '{print $(NF-44)}')

  if [[ $is_foreground -gt 0 ]]; then
    is_foreground="+"
  else
    is_foreground=""
  fi

  cmd=$(cat /proc/$pid/cmdline | xargs -0 echo)

  if [[ ! -n "$cmd" ]]; then
    cmd=$(grep -w "Name:" /proc/$pid/status | awk -F " " '{print "["$2"]"}')
  fi

  time=$(cat /proc/$pid/stat | awk '{print ($(NF-38)/100 + $(NF-37)/100)}')

  time="$(awk -v a="$time" 'BEGIN { printf "%d\n", (a/60) }'):$(awk -v a="$time" 'BEGIN { printf "%d\n", (a%60) }')"

  stat="$(cat /proc/$pid/stat | awk '{print $(NF-49)}')$(cat /proc/$pid/stat | awk '{if($(NF-33) < 0) {print "<";} else if($(NF-33) > 0) print "N"}')$is_lock$is_leader$is_thread$is_foreground"

  printf "%6s\t%s\t%s\t%s\t%.35s\n\n" $pid "$tty" $stat $time "$cmd"
 fi
done
