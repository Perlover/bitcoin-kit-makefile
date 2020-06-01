i-want-lightning: |\
    bitcoin-core_install\
    lnd_install\
    bitcoind_configs_install\
    lnd_configs_bitcoind_bundle_install
	@touch $@

set-up-lightning: |\
    i-want-lightning\
    $(HOME)/bin/$(BITCOIN_NETWORK)-bitcoind-start\
    $(HOME)/bin/$(BITCOIN_NETWORK)-bitcoind-stop\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lnd-start\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lnd-debug-start\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lnd-stop\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lightning-start\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lightning-stop\
    $(HOME)/.bitcoin_aliases\
    $(HOME)/.lnd/tls.cert\
    $(HOME)/.lnd/tls.key\
    $(HOME)/.lnd/data/chain/bitcoin/$(BITCOIN_NETWORK)/wallet.db\
    $(HOME)/.lnd/data/chain/bitcoin/$(BITCOIN_NETWORK)/admin.macaroon

$(HOME)/.lnd/tls.cert $(HOME)/.lnd/tls.key: | $(HOME)/.lnd/data/chain/bitcoin/$(BITCOIN_NETWORK)/wallet.db

$(HOME)/bin/$(BITCOIN_NETWORK)-lightning-start: configs/bin/lightning/$(BITCOIN_NETWORK)-lightning-start | \
    $(HOME)/bin\
    $(HOME)/bin/$(BITCOIN_NETWORK)-bitcoind-start\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lnd-start\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lnd-debug-start
	cp -f $< $@ && chmod 755 $@

$(HOME)/bin/$(BITCOIN_NETWORK)-lightning-stop: configs/bin/lightning/$(BITCOIN_NETWORK)-lightning-stop | \
    $(HOME)/bin\
    $(HOME)/bin/$(BITCOIN_NETWORK)-bitcoind-stop\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lnd-stop
	cp -f $< $@ && chmod 755 $@

export BITCOIN_KIT_LOCAL_IP PUBLIC_IP_ADDRESS

set-up-lightning-testnet:
	$(MAKE) set-up-lightning BITCOIN_NETWORK=testnet

set-up-lightning-mainnet:
	$(MAKE) set-up-lightning BITCOIN_NETWORK=mainnet

unexport
