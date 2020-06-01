#!/bin/bash

# The lnd v0.5.1 has other locations for wallet & macaroon files. Before it has these files not related with chain directory.
# This update unifies locations because some third-party utilities (ln-rebalance for examnple and lnwallet use standard paths)

set -e

LND_DIR=$HOME/.lnd

[[ -f $HOME/.testnet-lnd.pid ]] && kill -0 `cat $HOME/.testnet-lnd.pid` &>/dev/null && echo "You must to stop testnet lnd before update!" && exit 1
[[ -f $HOME/.mainnet-lnd.pid ]] && kill -0 `cat $HOME/.mainnet-lnd.pid` &>/dev/null && echo "You must to stop mainnet lnd before update!" && exit 2
[[ -f $HOME/.testnet-lncli-web.pid ]] && kill -0 `cat $HOME/.testnet-lncli-web.pid` &>/dev/null && echo "You must to stop testnet lncli-web before update!" && exit 1
[[ -f $HOME/.mainnet-lncli-web.pid ]] && kill -0 `cat $HOME/.mainnet-lncli-web.pid` &>/dev/null && echo "You must to stop mainnet lncli-web before update!" && exit 2

if [[ `openssl x509 -in $LND_DIR/tls.cert -text -noout |grep 'lnd autogenerated cert'` == "" ]]; then
    # Need to update!
    rm -f $LND_DIR/tls.cert
    rm -f $LND_DIR/tls.key
    if [[ -d $HOME/opt/lncli-web && -f $HOME/opt/lncli-web/lnd.cert ]]; then
	rm -f $HOME/opt/lncli-web/lnd.cert
	# Now tls.cert file doesn't exist but it will be recreated after lnd start
	ln -s $LND_DIR/tls.cert $HOME/opt/lncli-web/lnd.cert
    fi
fi
