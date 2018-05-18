i-want-lightning: |\
    bitcoin-core_install\
    lnd_install\
    lncli-web_install\
    bitcoind_configs_install\
    lnd_configs_bitcoind_bundle_install\
    lncli-web_configs_install
	@touch $@

set-up-lightning: |\
    i-want-lightning\
    lnd_install\
    lnd_configs_bitcoind_bundle_install\
    $(HOME)/.bitcoin_aliases\
    lncli-web_configs_install\
    lnd_create_$(BITCOIN_NETWORK)_wallet_install\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lncli-web-start

export BITCOIN_KIT_LOCAL_IP PUBLIC_IP_ADDRESS

set-up-lightning-testnet:
	$(MAKE) set-up-lightning BITCOIN_NETWORK=testnet

set-up-lightning-mainnet:
	$(MAKE) set-up-lightning BITCOIN_NETWORK=mainnet

unexport
