#!/bin/bash

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function log {
    COLOR=$(if [[ "$1" == "ERROR" ]]; then echo $RED; else echo $BLUE; fi)
    printf "${COLOR}[%12s][%5s] %s\n${NC}" "$(date '+%F %T')" "$1" "$2"
}

function retry {
    # retry 5 times
    ( eval $1 ) \
    || ( log ERROR "retrying..." && eval $1 ) \
    || ( log ERROR "retrying..." && eval $1 ) \
    || ( log ERROR "retrying..." && eval $1 ) \
    || ( log ERROR "retrying..." && eval $1 )
}