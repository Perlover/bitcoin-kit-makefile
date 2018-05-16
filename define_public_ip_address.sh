#!/bin/bash

{
    public_ip=`wget http://ipinfo.io/ip -qO -`

    strstr() { [ "${1#*$2*}" = "$1" ] && return 1; return 0; }

    echo 'Your PUBLIC IP address was defined as '$public_ip
    echo -n "Is this IP address is correct? (Y)es/(N)o [Y] "
    read answer
    echo $answer
} >&2


if strstr $"yY" "$answer" || [ "$answer" = "" ] ; then
    echo $public_ip
else
    exit 1;
fi
