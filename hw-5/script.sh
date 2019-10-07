#!/bin/bash

function process_1()
{
    echo $(date) "Start first process with nice 10" 
    nice -n 10 gzip -c /boot /var /usr > /tmp/process_1.gz > /dev/null 2>&1
}

function process_2()
{
    echo $(date) "Start second process with nice -20"
    nice -n -20 gzip -c /boot /var /usr > /tmp/process_2.gz > /dev/null 2>&1
}

time process_1
time process_2
