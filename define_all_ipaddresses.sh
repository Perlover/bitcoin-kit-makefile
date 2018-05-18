#!/bin/bash

echo -n $'











	PLEASE TURN OFF NOW SOME OpenVPN, VPN services if you have

	It'\'$'s needed for correct definition of your network IP addresses (public IP, UPnP
	public IP and etc.)

	Please press ENTER when you will do it!


        Waiting..... '; read -s; echo " OK"

UPNPC_RUN=${UPNPC_RUN:-LD_LIBRARY_PATH=./upnp/lib ./upnp/bin/upnpc}

# LOCAL LISTEN IP ADDRESS
{ if [ `/sbin/ifconfig | awk '/inet addr/{print substr($2,6)}'|grep -vE '^127\.'|wc -l` -gt 1 ]; then /sbin/ifconfig | awk '/inet addr/{print substr($2,6)}'|grep -vE '^127\.'|awk 'BEGIN{a=1}{print a") "$1; a++}' > $$.tmp; echo $'Choose your listen IP address for services: \n\n'; cat $$.tmp; read number; listen_ip=`grep $number') ' $$.tmp|sed -e 's#'$number') ##'`; rm -f $$.tmp; else listen_ip=`/sbin/ifconfig | awk '/inet addr/{print substr($2,6)}'|grep -vE '^127\.'`; fi; } >&2

UPNPC_RUN="${UPNPC_RUN} -m $listen_ip"

{
 upnp_public_ip=$(eval $UPNPC_RUN -s|grep 'ExternalIPAddress = '|sed -e 's#ExternalIPAddress = ##')
} &>/dev/null

# REAL PUBLIC IP address through ipinfo.io site
{
    public_ip=`wget http://ipinfo.io/ip -qO -`

    strstr() { [ "${1#*$2*}" = "$1" ] && return 1; return 0; }

    if [ "x$upnp_public_ip" != "x" -a "$upnp_public_ip" != $public_ip ]; then
	    echo "PLEASE ATTENTION!"
	    echo "You have UPnP enabled in your router"
	    echo "External IP address of your router: $upnp_public_ip"
	    echo "But real IP address for the service 'ipinfo.io' is $public_ip"
	    echo "So you are behind router and your router doesn't have real IP address"
	    echo "You will not be able to use UPnP port forwarding for bitcoin services"
	    public_ip=0.0.0.0
    elif [ "x$upnp_public_ip" == "x" -o "x$upnp_public_ip" != "x$public_ip" ]; then
	public_ip=0.0.0.0
    fi
} >&2

echo "Summary of IP auto-detection:"
echo "The listen IP: $listen_ip"
[ $public_ip == '0.0.0.0' ] && echo "You don't have real public IP" || echo "The real public IP: $public_ip and you can use incoming connections"
[ "x$upnp_public_ip" != "x" ] && echo "You have UPnP enabled in router and external IP address is $upnp_public_ip"
