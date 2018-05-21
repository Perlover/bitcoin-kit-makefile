#!/bin/bash

make_cwd=`pwd`

if [ ! -d ./upnp ]; then
	mkdir ./upnp
fi

if [ ! -f ./upnp/bin/upnpc ]; then
	cd ./upnp && cwd=`pwd` && cd .. &&
	cd external/miniupnp/miniupnpc && {
		INSTALLPREFIX=$cwd make install && make clean && echo "miniUPnP client FOR THIS MAKE was installed - OK"; \
	} &> make_out.txt
fi

cd $make_cwd

{
echo -n $'









PLEASE TURN OFF some OpenVPN/VPN services if you have!
It will help to define correct network configuration.

Now your IP addresses will be defined. UPnP support will be tested. Your real
public and router IP addresses will be defined.

Are you ready?

Please press ENTER when you will be ready! Waiting your answer..... '; read -s; echo " OK"

UPNPC_RUN=${UPNPC_RUN:-LD_LIBRARY_PATH=./upnp/lib ./upnp/bin/upnpc}

# LOCAL LISTEN IP ADDRESS
if [ `/sbin/ifconfig | awk '/inet addr/{print substr($2,6)}'|grep -vE '^127\.'|wc -l` -gt 1 ]; then /sbin/ifconfig | awk '/inet addr/{print substr($2,6)}'|grep -vE '^127\.'|awk 'BEGIN{a=1}{print a") "$1; a++}' > $$.tmp; echo $'\n\nYou have some network interfaces not one.\nPlease choose your local IP address of interface for future bitcoin services: \n\n'; cat $$.tmp; echo -n 'Your choose? [1, 2, ...] '; read number; listen_ip=`grep $number') ' $$.tmp|sed -e 's#'$number') ##'`; rm -f $$.tmp; else listen_ip=`/sbin/ifconfig | awk '/inet addr/{print substr($2,6)}'|grep -vE '^127\.'`; fi

BITCOIN_KIT_LOCAL_IP=$listen_ip

UPNPC_RUN="${UPNPC_RUN} -m $listen_ip"

echo -n $'\nPlease wait ...'

{
 upnp_public_ip=$(eval $UPNPC_RUN -s|grep 'ExternalIPAddress = '|sed -e 's#ExternalIPAddress = ##')
} &>/dev/null

echo

[ "x$upnp_public_ip" != "x" ] && BITCOIN_KIT_UPNP_SUPPORT='Yes' || BITCOIN_KIT_UPNP_SUPPORT='No'

[ "x$BITCOIN_KIT_UPNP_SUPPORT" == "xYes" ] && BITCOIN_KIT_EXTERNAL_ROUTER_IP=$upnp_public_ip || BITCOIN_KIT_EXTERNAL_ROUTER_IP='Unknown'

# REAL PUBLIC IP address through ipinfo.io site
public_ip=`wget http://ipinfo.io/ip -qO -`

BITCOIN_KIT_REAL_PUBLIC_IP=$public_ip

if [ "x$upnp_public_ip" != "x" -a "$upnp_public_ip" != $public_ip ]; then
	public_ip=0.0.0.0
elif [ "x$upnp_public_ip" == "x" -o "x$upnp_public_ip" != "x$public_ip" ]; then
    public_ip=0.0.0.0
fi

[ $listen_ip == $public_ip ] && BITCOIN_KIT_BEHIND_ROUTER='No' || BITCOIN_KIT_BEHIND_ROUTER='Yes'

BITCOIN_KIT_SHOULD_CONFIGURE_ROUTER_PORT_FORWARDING='No'

[ $BITCOIN_KIT_BEHIND_ROUTER == 'No'  ] && BITCOIN_KIT_POSSIBLE_INCOMING_CONNECTIONS='Yes'

[ $BITCOIN_KIT_BEHIND_ROUTER == 'Yes' \
  -a \
  $BITCOIN_KIT_UPNP_SUPPORT == 'Yes' \
  -a \
  $BITCOIN_KIT_EXTERNAL_ROUTER_IP == $BITCOIN_KIT_REAL_PUBLIC_IP \
] && { BITCOIN_KIT_POSSIBLE_INCOMING_CONNECTIONS='Yes'; BITCOIN_KIT_NOTICES=$BITCOIN_KIT_NOTICES$'* Incoming connections will be available by auto\n  through UPnP service of your router\n'; }

[ $BITCOIN_KIT_BEHIND_ROUTER == 'Yes' \
  -a \
  $BITCOIN_KIT_UPNP_SUPPORT == 'Yes' \
  -a \
  $BITCOIN_KIT_EXTERNAL_ROUTER_IP != $BITCOIN_KIT_REAL_PUBLIC_IP \
] && BITCOIN_KIT_POSSIBLE_INCOMING_CONNECTIONS='No'

[ $BITCOIN_KIT_BEHIND_ROUTER == 'Yes' \
  -a \
  $BITCOIN_KIT_UPNP_SUPPORT == 'No' \
] && { \
BITCOIN_KIT_POSSIBLE_INCOMING_CONNECTIONS="Maybe"; \
BITCOIN_KIT_NOTICES=$BITCOIN_KIT_NOTICES$'* Incoming connections may be available\n  if external IP of router is '$BITCOIN_KIT_REAL_PUBLIC_IP$'\n  and you can configure it for port forwarding to '$BITCOIN_KIT_LOCAL_IP$'\n'; \
BITCOIN_KIT_SHOULD_CONFIGURE_ROUTER_PORT_FORWARDING='Maybe'; \
}

{
    echo "
Summary table:

UPnP support at router ............................: $BITCOIN_KIT_UPNP_SUPPORT
Local IP address ..................................: $BITCOIN_KIT_LOCAL_IP
Real public IP address ............................: $BITCOIN_KIT_REAL_PUBLIC_IP
External router IP address ........................: $BITCOIN_KIT_EXTERNAL_ROUTER_IP
To be behind router ...............................: $BITCOIN_KIT_BEHIND_ROUTER
Possible incoming connections .....................: $BITCOIN_KIT_POSSIBLE_INCOMING_CONNECTIONS
Should you configure router for port forwarding? ..: $BITCOIN_KIT_SHOULD_CONFIGURE_ROUTER_PORT_FORWARDING

Recomendations:

$BITCOIN_KIT_NOTICES"

} > $2

cat $2

{
    echo "
BITCOIN_KIT_UPNP_SUPPORT := $BITCOIN_KIT_UPNP_SUPPORT
BITCOIN_KIT_LOCAL_IP := $BITCOIN_KIT_LOCAL_IP
BITCOIN_KIT_REAL_PUBLIC_IP := $BITCOIN_KIT_REAL_PUBLIC_IP
BITCOIN_KIT_EXTERNAL_ROUTER_IP := $BITCOIN_KIT_EXTERNAL_ROUTER_IP
BITCOIN_KIT_BEHIND_ROUTER := $BITCOIN_KIT_BEHIND_ROUTER
BITCOIN_KIT_POSSIBLE_INCOMING_CONNECTIONS := $BITCOIN_KIT_POSSIBLE_INCOMING_CONNECTIONS
BITCOIN_KIT_SHOULD_CONFIGURE_ROUTER_PORT_FORWARDING := $BITCOIN_KIT_SHOULD_CONFIGURE_ROUTER_PORT_FORWARDING
"
    if [ $BITCOIN_KIT_POSSIBLE_INCOMING_CONNECTIONS == 'Yes' ]; then
	echo "BITCOIN_KIT_LND_CONFIG_EXTERNALIP_MAINNET := externalip=$BITCOIN_KIT_REAL_PUBLIC_IP\\\\n"
	echo "BITCOIN_KIT_LND_CONFIG_EXTERNALIP_TESTNET := externalip=$BITCOIN_KIT_REAL_PUBLIC_IP:9736\\\\n"
	echo "BITCOIN_KIT_BITCOIND_CONFIG_EXTERNALIP_MAINNET := externalip=$BITCOIN_KIT_REAL_PUBLIC_IP\\\\n"
	echo "BITCOIN_KIT_BITCOIND_CONFIG_EXTERNALIP_TESTNET := externalip=$BITCOIN_KIT_REAL_PUBLIC_IP\\\\n"
    elif [ $BITCOIN_KIT_POSSIBLE_INCOMING_CONNECTIONS == 'Maybe' ]; then
	echo "BITCOIN_KIT_LND_CONFIG_EXTERNALIP_MAINNET := \\# You need configure router for port forwarding\\\\n\\# externalip=$BITCOIN_KIT_REAL_PUBLIC_IP\\\\n"
	echo "BITCOIN_KIT_LND_CONFIG_EXTERNALIP_TESTNET := \\# You need configure router for port forwarding\\\\n\\# externalip=$BITCOIN_KIT_REAL_PUBLIC_IP:9736\\\\n"
	echo "BITCOIN_KIT_BITCOIND_CONFIG_EXTERNALIP_MAINNET := \\# You need configure router for port forwarding\\\\n\\# externalip=$BITCOIN_KIT_REAL_PUBLIC_IP\\\\n"
	echo "BITCOIN_KIT_BITCOIND_CONFIG_EXTERNALIP_TESTNET := \\# You need configure router for port forwarding\\\\n\\# externalip=$BITCOIN_KIT_REAL_PUBLIC_IP\\\\n"
    else
	echo "BITCOIN_KIT_LND_CONFIG_EXTERNALIP_MAINNET :="
	echo "BITCOIN_KIT_LND_CONFIG_EXTERNALIP_TESTNET :="
	echo "BITCOIN_KIT_BITCOIND_CONFIG_EXTERNALIP_MAINNET :="
	echo "BITCOIN_KIT_BITCOIND_CONFIG_EXTERNALIP_TESTNET :="
    fi

} > $1

} >&2
