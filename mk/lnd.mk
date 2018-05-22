lnd_install: |\
    golang_install
	go get -d github.com/lightningnetwork/lnd &&\
	cd $$GOPATH/src/github.com/lightningnetwork/lnd &&\
	$(MAKE) && $(MAKE) install
	@touch $@

btcd_install: |\
    lnd_install
	cd $$GOPATH/src/github.com/lightningnetwork/lnd &&\
	make btcd
	@touch $@

####################### CONFIGS ###################################

MAKE_DIRS +=  build/lnd/bitcoind

$(HOME)/.lnd/lnd-testnet.conf: build/lnd/bitcoind/lnd-testnet.conf

$(HOME)/.lnd/lnd-mainnet.conf: build/lnd/bitcoind/lnd-mainnet.conf

$(eval $(call COPY_FILE,$(HOME)/.lnd,077))

build/lnd/bitcoind/lnd-testnet.conf :\
    $(NETWORK_MK_FILE)\
    configs/lnd/bitcoind/lnd-testnet.conf\
    $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt\
    |\
    build/lnd/bitcoind
	cp -f configs/lnd/bitcoind/lnd-testnet.conf $@ &&\
	RPC_PASS=`awk '/Your password:/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt` && sed -ri \
	-e 's#\$$\$$HOME\$$\$$#$(HOME)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LND_CONFIG_EXTERNALIP_TESTNET\$$\$$#$(BITCOIN_KIT_LND_CONFIG_EXTERNALIP_TESTNET)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' \
	-e 's#\$$\$$RPC_PASS\$$\$$#g'$$RPC_PASS'#' \
	$@

build/lnd/bitcoind/lnd-mainnet.conf :\
    $(NETWORK_MK_FILE)\
    configs/lnd/bitcoind/lnd-mainnet.conf\
    $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt\
    |\
    build/lnd/bitcoind
	cp -f configs/lnd/bitcoind/lnd-mainnet.conf $@ &&\
	RPC_PASS=`awk '/Your password:/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt` && sed -ri \
	-e 's#\$$\$$HOME\$$\$$#$(HOME)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LND_CONFIG_EXTERNALIP_MAINNET\$$\$$#$(BITCOIN_KIT_LND_CONFIG_EXTERNALIP_MAINNET)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' \
	-e 's#\$$\$$RPC_PASS\$$\$$#g'$$RPC_PASS'#' \
	$@

lnd_configs_bitcoind_bundle_install: |\
    bitcoind_configs_install\
    lncli-web_lnd_certs_install\
    $(HOME)/.lnd/lnd-testnet.conf\
    $(HOME)/.lnd/lnd-mainnet.conf
	@touch $@

MAKE_DIRS += build/bin/lnd

build/bin/lnd/mainnet-lnd-start: \
    $(NETWORK_MK_FILE)\
    configs/bin/lnd/mainnet-lnd-start\
    |\
    lnd_install\
    lnd_configs_bitcoind_bundle_install\
    build/bin/lnd
	cp -f configs/bin/lnd/mainnet-lnd-start $@ && \
	sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_UPNP_SUPPORT\$$\$$#$(BITCOIN_KIT_UPNP_SUPPORT)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' $@ && \
	chmod 755 $@

build/bin/lnd/testnet-lnd-start: \
    $(NETWORK_MK_FILE)\
    configs/bin/lnd/testnet-lnd-start\
    |\
    lnd_install\
    lnd_configs_bitcoind_bundle_install\
    build/bin/lnd
	cp -f configs/bin/lnd/testnet-lnd-start $@ && \
	sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_UPNP_SUPPORT\$$\$$#$(BITCOIN_KIT_UPNP_SUPPORT)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' $@ && \
	chmod 755 $@

build/bin/lnd/mainnet-lnd-stop: \
    $(NETWORK_MK_FILE)\
    configs/bin/lnd/mainnet-lnd-stop\
    |\
    lnd_install\
    lnd_configs_bitcoind_bundle_install\
    build/bin/lnd
	cp -f configs/bin/lnd/mainnet-lnd-stop $@ && \
	sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_UPNP_SUPPORT\$$\$$#$(BITCOIN_KIT_UPNP_SUPPORT)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' $@ && \
	chmod 755 $@

build/bin/lnd/testnet-lnd-stop: \
    $(NETWORK_MK_FILE)\
    configs/bin/lnd/testnet-lnd-stop\
    |\
    lnd_install\
    lnd_configs_bitcoind_bundle_install\
    build/bin/lnd
	cp -f configs/bin/lnd/testnet-lnd-stop $@ && \
	sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_UPNP_SUPPORT\$$\$$#$(BITCOIN_KIT_UPNP_SUPPORT)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' $@ && \
	chmod 755 $@

BITCOIN_NETWORK ?= mainnet

$(HOME)/.lnd/data/chain/bitcoin/mainnet/wallet.db: override CREATE_WALLET_LOCK := .create_wallet_mainnet_lock
$(HOME)/.lnd/data/chain/bitcoin/mainnet/wallet.db: | $(HOME)/.lnd/lnd-mainnet.conf
	umask 077 && nohup lnd --configfile=$(HOME)/.lnd/lnd-mainnet.conf &>$(CREATE_WALLET_LOCK).out.txt & echo $$! >$(CREATE_WALLET_LOCK).pid.txt
	echo $$'********************************************************************************\n\n\nNow the "lncli create" command will be run (creation of wallet). It'\'$$'s important! Please write passwords & seed of lnd!\n\n\n********************************************************************************\n\n'
	echo 'Please press ENTER to next step:'; read
	lncli --macaroonpath $(HOME)/.lnd/admin-mainnet.macaroon --rpcserver localhost:10009 create
	for i in {1..5}; do [ -f $(HOME)/.lnd/admin-mainnet.macaroon ] && break; sleep 1; done
	-@kill `cat $(CREATE_WALLET_LOCK).pid.txt` &>/dev/null; rm -f $(CREATE_WALLET_LOCK).pid.txt $(CREATE_WALLET_LOCK).out.txt
	if [ ! -f $(HOME)/.lnd/admin-mainnet.macaroon ]; then echo "No file $(HOME)/.lnd/admin-mainnet.macaroon"; false; fi
	cp -f $(HOME)/.lnd/admin-mainnet.macaroon $(HOME)/opt/lncli-web/
	@touch $@

$(HOME)/.lnd/data/chain/bitcoin/testnet/wallet.db: override CREATE_WALLET_LOCK := .create_wallet_testnet_lock
$(HOME)/.lnd/data/chain/bitcoin/testnet/wallet.db: | $(HOME)/.lnd/lnd-testnet.conf
	umask 077 && nohup lnd --configfile=$(HOME)/.lnd/lnd-testnet.conf &>$(CREATE_WALLET_LOCK).out.txt & echo $$! >$(CREATE_WALLET_LOCK).pid.txt
	echo $$'********************************************************************************\n\n\nNow the "lncli create" command will be run (creation of wallet). It'\'$$'s important! Please write passwords & seed of lnd!\n\n\n********************************************************************************\n\n'
	echo '!!! THIS IS TESTNODE WALLET! Please press ENTER to next step:'; read
	lncli --macaroonpath $(HOME)/.lnd/admin-testnet.macaroon --rpcserver localhost:10010 create
	for i in {1..5}; do [ -f $(HOME)/.lnd/admin-testnet.macaroon ] && break; sleep 1; done
	-@kill `cat $(CREATE_WALLET_LOCK).pid.txt` &>/dev/null; rm -f $(CREATE_WALLET_LOCK).pid.txt $(CREATE_WALLET_LOCK).out.txt
	if [ ! -f $(HOME)/.lnd/admin-testnet.macaroon ]; then echo "No file $(HOME)/.lnd/admin-testnet.macaroon"; false; fi
	cp -f $(HOME)/.lnd/admin-testnet.macaroon $(HOME)/opt/lncli-web/
	@touch $@

$(HOME)/bin/mainnet-lnd-start: build/bin/lnd/mainnet-lnd-start | miniupnpc_install

$(HOME)/bin/testnet-lnd-start: build/bin/lnd/testnet-lnd-start | miniupnpc_install

$(HOME)/bin/mainnet-lnd-stop: build/bin/lnd/mainnet-lnd-stop | miniupnpc_install

$(HOME)/bin/testnet-lnd-stop: build/bin/lnd/testnet-lnd-stop | miniupnpc_install
