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
    configs/lnd/bitcoind/lnd-testnet.conf\
    $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt\
    |\
    build/lnd/bitcoind
	cp -f $< $@ &&\
	RPC_PASS=`awk '/Your password:/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt` && sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_LND_CONFIG_EXTERNALIP_TESTNET\$$\$$#$(BITCOIN_KIT_LND_CONFIG_EXTERNALIP_TESTNET)#' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#' \
	-e 's#\$$\$$RPC_PASS\$$\$$#'$$RPC_PASS'#' \
	$@

build/lnd/bitcoind/lnd-mainnet.conf :\
    configs/lnd/bitcoind/lnd-mainnet.conf\
    $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt\
    |\
    build/lnd/bitcoind
	cp -f $< $@ &&\
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

lnd_create_macaroon_install: | $(HOME)/.lnd/lnd-mainnet.conf
	if [ -f $(HOME)/.lnd/admin.macaroon ]; then \
	    echo "You already setted up the lnd daemon (the file $(HOME)/.lnd/admin.macaroon exists)";\
	else\
	    umask 077 && nohup lnd --configfile=$(HOME)/.lnd/lnd-mainnet.conf &>.$@.out.txt & echo $$! >.$@.pid.txt;\
	    sleep 2 && kill `cat .$@.pid.txt`; rm -f .$@.pid.txt .$@.out.txt;\
	    sleep 2;\
	fi \
	cp -f $(HOME)/.lnd/admin.macaroon $(HOME)/opt/lncli-web/
	@touch $@

lnd_create_mainnet_wallet_install: | lnd_create_macaroon_install
	umask 077 && nohup lnd &>.$@.out.txt & echo $$! >.$@.pid.txt
	echo $$'********************************************************************************\n\n\nNow the "lncli create" command will be run (creation of wallet). It'\'$$'s important! Please write passwords & seed of lnd!\n\n\n********************************************************************************\n\n'
	echo 'Please press ENTER to next step:'; read
	lncli --rpcserver=localhost:10009 create && sleep 2
	-@kill `cat .$@.pid.txt`; rm -f .$@.pid.txt .$@.out.txt
	@touch $@

lnd_create_testnet_wallet_install: | lnd_create_macaroon_install
	umask 077 && nohup lnd &>.$@.out.txt & echo $$! >.$@.pid.txt
	echo $$'********************************************************************************\n\n\nNow the "lncli create" command will be run (creation of wallet). It'\'$$'s important! Please write passwords & seed of lnd!\n\n\n********************************************************************************\n\n'
	echo '!!! THIS IS TESTNODE WALLET! Please press ENTER to next step:'; read
	lncli --rpcserver=localhost:10010 create && sleep 2
	-@kill `cat .$@.pid.txt`; rm -f .$@.pid.txt .$@.out.txt
	@touch $@

