#!/bin/sh

# The lnd v0.5.1 has other locations for wallet & macaroon files. Before it has these files not related with chain directory.
# This update unifies locations because some third-party utilities (ln-rebalance for examnple and lnwallet use standard paths)

set -e

LND_DIR=$HOME/.lnd

[[ -f $HOME/.testnet-lnd.pid ]] && kill -0 `cat $HOME/.testnet-lnd.pid` &>/dev/null && echo "You must to stop testnet lnd before update!" && exit 1
[[ -f $HOME/.mainnet-lnd.pid ]] && kill -0 `cat $HOME/.mainnet-lnd.pid` &>/dev/null && echo "You must to stop mainnet lnd before update!" && exit 2

# $1 - mainnet|testnet
update_network () {
    local network=$1

    rsync -a $LND_DIR/data-${network}/* $LND_DIR/data/ && sed -ri -e 's#/data-'${network}'/#/data/#g' $LND_DIR/lnd-${network}.conf
    if [ -f $LND_DIR/data/macaroons.db ]; then mv $LND_DIR/data/macaroons.db $LND_DIR/data/chain/bitcoin/${network}/; fi
    [ -f $LND_DIR/admin-${network}.macaroon ] &&
	mv $LND_DIR/admin-${network}.macaroon $LND_DIR/data/chain/bitcoin/${network}/admin.macaroon &&\
	sed -ri -e 's#admin-'${network}'\.macaroon#data/chain/bitcoin/'${network}'/admin.macaroon#g' $LND_DIR/lnd-${network}.conf
    [ -f $LND_DIR/invoice-${network}.macaroon ] &&
	mv $LND_DIR/invoice-${network}.macaroon $LND_DIR/data/chain/bitcoin/${network}/invoice.macaroon &&
	sed -ri -e 's#invoice-'${network}'\.macaroon#data/chain/bitcoin/'${network}'/invoice.macaroon#g' $LND_DIR/lnd-${network}.conf
    [ -f $LND_DIR/readonly-${network}.macaroon ] &&
	mv $LND_DIR/readonly-${network}.macaroon $LND_DIR/data/chain/bitcoin/${network}/readonly.macaroon &&
	sed -ri -e 's#readonly-'${network}'\.macaroon#data/chain/bitcoin/'${network}'/readonly.macaroon#g' $LND_DIR/lnd-${network}.conf
    if [ "${network}" == "mainnet" ]; then
	sed -ri -e 's#debughtlc=true#debughtlc=false#g' $LND_DIR/lnd-${network}.conf
    fi
    if grep -q zmqpath $LND_DIR/lnd-${network}.conf; then
	sed -ri -e $'/bitcoind\\.zmqpath/d' $LND_DIR/lnd-${network}.conf
	grep zmq configs/lnd/bitcoind/lnd-${network}.conf >>$LND_DIR/lnd-${network}.conf
    fi
}

if [ ! -d $LND_DIR/data ]; then
    # No data dir - we use old version of bitcoin-ket-makefile
    mkdir -p $LND_DIR/data
    if [ -d $LND_DIR/data-mainnet ]; then
	update_network mainnet
	rm -rf $LND_DIR/data-mainnet
    fi
    if [ -d $LND_DIR/data-testnet ]; then
	update_network testnet
	rm -rf $LND_DIR/data-testnet
    fi
else
    echo "No update of macaroon files to be needed!"
fi
