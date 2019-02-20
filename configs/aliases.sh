alias testnet-lncli="lncli --macaroonpath $HOME/.lnd/data/chain/bitcoin/testnet/admin.macaroon --rpcserver localhost:10010"
alias mainnet-lncli="lncli --macaroonpath $HOME/.lnd/data/chain/bitcoin/mainnet/admin.macaroon --rpcserver localhost:10009"
alias l="mainnet-lncli"
alias lt="testnet-lncli"

# loc - mainnet
# ltoc - testnet
# Here is universal function
# loc_or_ltoc <name> <l|lt> other_parameters...
function loc_or_ltoc () {
    host_port=${3//*@}
    pubkey=${3//@*}

    if [[ "$host_port" == "" ]]; then
	echo "$1: please use the following format: $1 pubkey@host:port amount"
	return 1
    fi
    if [[ "$pubkey" == "" ]]; then
	echo "$1: please use the following format: $1 pubkey@host:port amount"
	return 1
    fi
    if [[ "$4" == "" ]]; then
	echo "$1: please use the following format: $1 pubkey@host:port amount"
	return 1
    fi
    # test pubkey before - if we already have an openned channel or pending one - don't open a channel
    if l pendingchannels|grep $pubkey &>/dev/null; then
	echo "$1: the node $pubkey already has a pending channel - ignoring"
	return 1
    fi
    if l listchannels|grep $pubkey &>/dev/null; then
	echo "$1: the node $pubkey already has a openning channel - ignoring"
	return 1
    fi
    $2 openchannel --connect $host_port $pubkey $4
}

function loc () {
    loc_or_ltoc loc "lncli --macaroonpath $HOME/.lnd/data/chain/bitcoin/mainnet/admin.macaroon --rpcserver localhost:10009" $*
}

function ltoc () {
    loc_or_ltoc ltoc "lncli --macaroonpath $HOME/.lnd/data/chain/bitcoin/testnet/admin.macaroon --rpcserver localhost:10010" $*
}
