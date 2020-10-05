#!/bin/bash

VALID_GROUP_NAME=admin
NUMBER_DAY=$(date +%u)


if getent group $VALID_GROUP_NAME | grep -q "\b${PAM_USER}\b"; then
    exit 0
# elif [ ${PAM_USER} == "vagrant" ]; then
#     exit 0
else
    if [ $NUMBER_DAY == "6" ]; then
        exit 1
    elif [ $NUMBER_DAY == "7" ]; then
        exit 1
    # elif [ $NUMBER_DAY == "1" ]; then
    #     exit 1    
    else
        exit 0
    fi
fi
