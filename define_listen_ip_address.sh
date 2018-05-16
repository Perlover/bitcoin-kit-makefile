#!/bin/bash

{ if [ `/sbin/ifconfig | awk '/inet addr/{print substr($2,6)}'|grep -vE '^127\.'|wc -l` -gt 1 ]; then /sbin/ifconfig | awk '/inet addr/{print substr($2,6)}'|grep -vE '^127\.'|awk 'BEGIN{a=1}{print a") "$1; a++}' > $$.tmp; echo $'Choose your listen IP address for services: \n\n'; cat $$.tmp; read number; ipaddress=`grep $number') ' $$.tmp|sed -e 's#'$number') ##'`; rm -f $$.tmp; else ipaddress=`/sbin/ifconfig | awk '/inet addr/{print substr($2,6)}'|grep -vE '^127\.'`; fi; } >&2; echo $ipaddress
