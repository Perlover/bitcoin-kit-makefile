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
	-e 's#\$$\$$BITCOIN_KIT_LND_CONFIG_EXTERNALIP_TESTNET\$$\$$#$(BITCOIN_KIT_LND_CONFIG_EXTERNALIP_TESTNET)#' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#' \
	-e 's#\$$\$$RPC_PASS\$$\$$#'$$RPC_PASS'#' \
	$@

build/lnd/bitcoind/lnd-mainnet.conf :\
    $(NETWORK_MK_FILE)\
    configs/lnd/bitcoind/lnd-mainnet.conf\
    $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt\
    |\
    build/lnd/bitcoind
	cp -f configs/lnd/bitcoind/lnd-mainnet.conf $@ &&\
	RPC_PASS=`awk '/Your password:/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt` && sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_LND_CONFIG_EXTERNALIP_MAINNET\$$\$$#$(BITCOIN_KIT_LND_CONFIG_EXTERNALIP_MAINNET)#' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#' \
	-e 's#\$$\$$RPC_PASS\$$\$$#'$$RPC_PASS'#' \
	$@

lnd_configs_bitcoind_bundle_install: |\
    bitcoind_configs_install\
    lncli-web_lnd_certs_install\
    $(HOME)/.lnd/lnd-testnet.conf\
    $(HOME)/.lnd/lnd-mainnet.conf
	@touch $@

BITCOIN_NETWORK ?= mainnet

$(HOME)/.lnd/data/chain/bitcoin/mainnet/wallet.db: override CREATE_WALLET_LOCK := .create_wallet_mainnet_lock
$(HOME)/.lnd/data/chain/bitcoin/mainnet/wallet.db: | $(HOME)/.lnd/lnd-mainnet.conf
	umask 077 && nohup lnd --configfile=$(HOME)/.lnd/lnd-mainnet.conf &>$(CREATE_WALLET_LOCK).out.txt & echo $$! >$(CREATE_WALLET_LOCK).pid.txt
	echo $$'********************************************************************************\n\n\nNow the "lncli create" command will be run (creation of wallet). It'\'$$'s important! Please write passwords & seed of lnd!\n\n\n********************************************************************************\n\n'
	echo 'Please press ENTER to next step:'; read
	lncli --rpcserver=localhost:10009 create
	for i in {1..5}; do [ -f $(HOME)/.lnd/admin.macaroon ] && break; sleep 1; done
	-@kill `cat $(CREATE_WALLET_LOCK).pid.txt`; rm -f $(CREATE_WALLET_LOCK).pid.txt $(CREATE_WALLET_LOCK).out.txt
	if [ ! -f $(HOME)/.lnd/admin.macaroon ]; then echo "No file $(HOME)/.lnd/admin.macaroon"; false; fi
	cp -f $(HOME)/.lnd/admin.macaroon $(HOME)/opt/lncli-web/
	@touch $@

$(HOME)/.lnd/data/chain/bitcoin/testnet/wallet.db: override CREATE_WALLET_LOCK := .create_wallet_testnet_lock
$(HOME)/.lnd/data/chain/bitcoin/testnet/wallet.db: | $(HOME)/.lnd/lnd-testnet.conf
	umask 077 && nohup lnd --configfile=$(HOME)/.lnd/lnd-testnet.conf &>$(CREATE_WALLET_LOCK).out.txt & echo $$! >$(CREATE_WALLET_LOCK).pid.txt
	echo $$'********************************************************************************\n\n\nNow the "lncli create" command will be run (creation of wallet). It'\'$$'s important! Please write passwords & seed of lnd!\n\n\n********************************************************************************\n\n'
	echo '!!! THIS IS TESTNODE WALLET! Please press ENTER to next step:'; read
	lncli --rpcserver=localhost:10010 create
	for i in {1..5}; do [ -f $(HOME)/.lnd/admin.macaroon ] && break; sleep 1; done
	-@kill `cat $(CREATE_WALLET_LOCK).pid.txt`; rm -f $(CREATE_WALLET_LOCK).pid.txt $(CREATE_WALLET_LOCK).out.txt
	if [ ! -f $(HOME)/.lnd/admin.macaroon ]; then echo "No file $(HOME)/.lnd/admin.macaroon"; false; fi
	cp -f $(HOME)/.lnd/admin.macaroon $(HOME)/opt/lncli-web/
	@touch $@

