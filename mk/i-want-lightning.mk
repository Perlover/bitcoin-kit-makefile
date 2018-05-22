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
    $(HOME)/bin/$(BITCOIN_NETWORK)-bitcoind-start\
    $(HOME)/bin/$(BITCOIN_NETWORK)-bitcoind-stop\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lnd-start\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lnd-stop\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lncli-web-start\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lncli-web-stop\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lightning-start\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lightning-stop\
    $(HOME)/.bitcoin_aliases\
    $(HOME)/.lnd/data-$(BITCOIN_NETWORK)/chain/bitcoin/$(BITCOIN_NETWORK)/wallet.db

$(HOME)/bin/$(BITCOIN_NETWORK)-lightning-start: configs/bin/lightning/$(BITCOIN_NETWORK)-lightning-start | \
    $(HOME)/bin/$(BITCOIN_NETWORK)-bitcoind-start\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lnd-start\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lncli-web-start
	cp -f $< $@ && chmod 755 $@

$(HOME)/bin/$(BITCOIN_NETWORK)-lightning-stop: configs/bin/lightning/$(BITCOIN_NETWORK)-lightning-stop | \
    $(HOME)/bin/$(BITCOIN_NETWORK)-bitcoind-stop\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lnd-stop\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lncli-web-stop
	cp -f $< $@ && chmod 755 $@

export BITCOIN_KIT_LOCAL_IP PUBLIC_IP_ADDRESS

set-up-lightning-testnet:
	$(MAKE) set-up-lightning BITCOIN_NETWORK=testnet

set-up-lightning-mainnet:
	$(MAKE) set-up-lightning BITCOIN_NETWORK=mainnet

unexport
