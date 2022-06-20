lnd_install: |\
    new_git_install\
    $(CURRENT_GOLANG_TARGET)\
    inotify_install
	-mkdir -p $$GOPATH/src/github.com/lightningnetwork
	-rm -rf $$GOPATH/src/github.com/lightningnetwork/lnd
	cd $$GOPATH/src/github.com/lightningnetwork &&\
	git clone https://github.com/lightningnetwork/lnd &&\
	cd lnd &&\
	git fetch -f --tags origin && git checkout $(LND_ACTUAL_COMMIT) &&\
	$(MAKE) && $(MAKE) install tags="autopilotrpc signrpc walletrpc chainrpc invoicesrpc routerrpc watchtowerrpc wtclientrpc"
	@touch $@

.PHONY: lnd-install

lnd-install: lnd_install
	@echo "LND was installed!"

.PHONY: lnd-install

prepare-lnd-update: this_repo_update
	-rm -f lnd-bin-update lnd-update

lnd-update-testnet:
	$(MAKE) lnd-update BITCOIN_NETWORK=testnet

lnd-update-mainnet:
	$(MAKE) lnd-update BITCOIN_NETWORK=mainnet

lnd-update:\
    lnd-bin-update\
    $(HOME)/.bitcoin_aliases\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lnd-start\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lnd-debug-start\
    $(HOME)/bin/$(BITCOIN_NETWORK)-lnd-stop
	if [[ -f $(HOME)/.testnet-lnd.pid ]]; then\
	    kill -0 `cat $(HOME)/.testnet-lnd.pid` &>/dev/null &&\
	    echo "You must to stop testnet lnd before update!" &&\
	    exit 1;\
	fi
	if [[ -f $(HOME)/.mainnet-lnd.pid ]]; then\
	    kill -0 `cat $(HOME)/.mainnet-lnd.pid` &>/dev/null &&\
	    echo "You must to stop mainnet lnd before update!" &&\
	    exit 2;\
	fi
	if [[ -f $(HOME)/.testnet-lncli-web.pid ]]; then\
	    kill -0 `cat $(HOME)/.testnet-lncli-web.pid` &>/dev/null &&\
	    echo "You must to stop testnet lncli-web before update!" &&\
	    exit 1;\
	fi
	if [[ -f $(HOME)/.mainnet-lncli-web.pid ]]; then\
	    kill -0 `cat $(HOME)/.mainnet-lncli-web.pid` &>/dev/null &&\
	    echo "You must to stop mainnet lncli-web before update!" &&\
	    exit 2;\
	fi
	if [ "x${LND_BACKUP}" != "x" ]; then umask 077 && cd $(HOME) && tar czf lnd-backup-`date +%s-%Y-%m-%d`.tgz .lnd && echo $$'**********\n\nWe did backup of LND in home dir!\n\n**********'; fi
	./update_wallet_macaroon_files_to_standard_dir.sh
	./update_lnd_cert_to_standard_cert.sh
	@echo $$'*****************************************************\n\nLND was updated to commit/tag: $(LND_ACTUAL_COMMIT)\n\n' &&\
	echo "To run \`mainnet-lightning-start\` or \`testnet-lightning-start\`" &&\
	echo $$'\n\n*****************************************************'
	@touch $@

lnd-bin-update: |\
    new_git_install\
    lnd_install
	rm -rf $$GOPATH/pkg/dep
	-mkdir -p $$GOPATH/src/github.com/lightningnetwork
	-rm -rf $$GOPATH/src/github.com/lightningnetwork/lnd
	cd $$GOPATH/src/github.com/lightningnetwork &&\
	git clone https://github.com/lightningnetwork/lnd &&\
	cd lnd &&\
	git fetch -f --tags origin && git checkout $(LND_ACTUAL_COMMIT) &&\
	$(MAKE) clean && $(MAKE) && $(MAKE) install tags="autopilotrpc signrpc walletrpc chainrpc invoicesrpc routerrpc watchtowerrpc wtclientrpc"
	@touch lnd_install
	@touch $@

btcd_install: |\
    lnd_install
	cd $$GOPATH/src/github.com/lightningnetwork/lnd &&\
	make btcd
	@touch $@

####################### CONFIGS ###################################

MAKE_DIRS +=  build/lnd/bitcoind
MAKE_DIRS +=  $(HOME)/.lnd

$(HOME)/.lnd/lnd-testnet.conf: build/lnd/bitcoind/lnd-testnet.conf | $(HOME)/.lnd
	umask 077 && \
	if [ -f $@ ]; then \
	    cp -f $< $@.new.conf && \
	    touch $@; \
	else \
	    cp -f $< $@; \
	fi

$(HOME)/.lnd/lnd-mainnet.conf: build/lnd/bitcoind/lnd-mainnet.conf | $(HOME)/.lnd
	umask 077 && \
	if [ -f $@ ]; then \
	    cp -f $< $@.new.conf && \
	    touch $@; \
	else \
	    cp -f $< $@; \
	fi

build/lnd/bitcoind/lnd-testnet.conf :\
    $(NETWORK_MK_FILE)\
    $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt\
    |\
    configs/lnd/bitcoind/lnd-testnet.conf\
    build/lnd/bitcoind
	cp -f configs/lnd/bitcoind/lnd-testnet.conf $@ &&\
	RPC_PASS=`awk '/Your password:/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt` && sed -ri \
	-e 's#\$$\$$HOME\$$\$$#$(HOME)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LND_CONFIG_EXTERNALIP_TESTNET\$$\$$#$(BITCOIN_KIT_LND_CONFIG_EXTERNALIP_TESTNET)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' \
	-e 's#\$$\$$RPC_PASS\$$\$$#'$$RPC_PASS'#g' \
	$@

build/lnd/bitcoind/lnd-mainnet.conf :\
    $(NETWORK_MK_FILE)\
    $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt\
    |\
    configs/lnd/bitcoind/lnd-mainnet.conf\
    build/lnd/bitcoind
	cp -f configs/lnd/bitcoind/lnd-mainnet.conf $@ &&\
	RPC_PASS=`awk '/Your password:/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt` && sed -ri \
	-e 's#\$$\$$HOME\$$\$$#$(HOME)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LND_CONFIG_EXTERNALIP_MAINNET\$$\$$#$(BITCOIN_KIT_LND_CONFIG_EXTERNALIP_MAINNET)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' \
	-e 's#\$$\$$RPC_PASS\$$\$$#'$$RPC_PASS'#g' \
	$@

lnd_configs_bitcoind_bundle_install: |\
    bitcoind_configs_install\
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

build/bin/lnd/mainnet-lnd-debug-start: \
    $(NETWORK_MK_FILE)\
    configs/bin/lnd/mainnet-lnd-debug-start\
    |\
    lnd_install\
    lnd_configs_bitcoind_bundle_install\
    build/bin/lnd
	cp -f configs/bin/lnd/mainnet-lnd-debug-start $@ && \
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

build/bin/lnd/testnet-lnd-debug-start: \
    $(NETWORK_MK_FILE)\
    configs/bin/lnd/testnet-lnd-debug-start\
    |\
    lnd_install\
    lnd_configs_bitcoind_bundle_install\
    build/bin/lnd
	cp -f configs/bin/lnd/testnet-lnd-debug-start $@ && \
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
$(HOME)/.lnd/data/chain/bitcoin/mainnet/wallet.db:
	umask 077 && nohup lnd --configfile=$(HOME)/.lnd/lnd-mainnet.conf &>$(CREATE_WALLET_LOCK).out.txt & echo $$! >$(CREATE_WALLET_LOCK).pid.txt
	echo $$'********************************************************************************\n\n\nNow the "lncli create" command will be run (creation of wallet). It'\'$$'s important! Please write passwords & seed of lnd!\n\n\n********************************************************************************\n\n'
	echo 'Please press ENTER to next step:'; read
	lncli --macaroonpath $(HOME)/.lnd/data/chain/bitcoin/mainnet/admin.macaroon --rpcserver localhost:10009 create
	-@kill `cat $(CREATE_WALLET_LOCK).pid.txt` &>/dev/null; rm -f $(CREATE_WALLET_LOCK).pid.txt $(CREATE_WALLET_LOCK).out.txt

$(HOME)/.lnd/data/chain/bitcoin/mainnet/admin.macaroon: | $(HOME)/.lnd/lnd-mainnet.conf $(HOME)/.lnd/data/chain/bitcoin/mainnet/wallet.db
	if [ -f $(HOME)/.lnd/admin-mainnet.macaroon ]; then echo $$'**************\n\nYou need stop LNDs; $(MAKE) lnd-update; and to run LND again\n\n**************'; false; fi
	for i in {1..30}; do [ -f $@ ] && break; sleep 1; done
	[ -f $@ ]

$(HOME)/opt/lncli-web/admin-mainnet.macaroon: $(HOME)/.lnd/data/chain/bitcoin/mainnet/admin.macaroon
	cp -f $< $@

$(HOME)/.lnd/data/chain/bitcoin/testnet/wallet.db: override CREATE_WALLET_LOCK := .create_wallet_testnet_lock
$(HOME)/.lnd/data/chain/bitcoin/testnet/wallet.db:
	umask 077 && nohup lnd --configfile=$(HOME)/.lnd/lnd-testnet.conf &>$(CREATE_WALLET_LOCK).out.txt & echo $$! >$(CREATE_WALLET_LOCK).pid.txt
	echo $$'********************************************************************************\n\n\nNow the "lncli create" command will be run (creation of wallet). It'\'$$'s important! Please write passwords & seed of lnd!\n\n\n********************************************************************************\n\n'
	echo '!!! THIS IS TESTNODE WALLET! Please press ENTER to next step:'; read
	lncli --macaroonpath $(HOME)/.lnd/data/chain/bitcoin/testnet/admin.macaroon --rpcserver localhost:10010 create
	-@kill `cat $(CREATE_WALLET_LOCK).pid.txt` &>/dev/null; rm -f $(CREATE_WALLET_LOCK).pid.txt $(CREATE_WALLET_LOCK).out.txt

$(HOME)/.lnd/data/chain/bitcoin/testnet/admin.macaroon: | $(HOME)/.lnd/lnd-testnet.conf $(HOME)/.lnd/data/chain/bitcoin/testnet/wallet.db
	if [ -f $(HOME)/.lnd/admin-testnet.macaroon ]; then echo $$'**************\n\nYou need stop LNDs; $(MAKE) lnd-update; and to run LND again\n\n**************'; false; fi
	for i in {1..30}; do [ -f $@ ] && break; sleep 1; done
	[ -f $@ ]

$(HOME)/opt/lncli-web/admin-testnet.macaroon: $(HOME)/.lnd/data/chain/bitcoin/testnet/admin.macaroon
	cp -f $< $@

$(HOME)/bin/mainnet-lnd-start: build/bin/lnd/mainnet-lnd-start | $(HOME)/bin miniupnpc_install
	umask 077 && cp -f $< $@

$(HOME)/bin/mainnet-lnd-debug-start: build/bin/lnd/mainnet-lnd-debug-start | $(HOME)/bin miniupnpc_install
	umask 077 && cp -f $< $@

$(HOME)/bin/testnet-lnd-start: build/bin/lnd/testnet-lnd-start | $(HOME)/bin miniupnpc_install
	umask 077 && cp -f $< $@

$(HOME)/bin/testnet-lnd-debug-start: build/bin/lnd/testnet-lnd-debug-start | $(HOME)/bin miniupnpc_install
	umask 077 && cp -f $< $@

$(HOME)/bin/mainnet-lnd-stop: build/bin/lnd/mainnet-lnd-stop | $(HOME)/bin miniupnpc_install
	umask 077 && cp -f $< $@

$(HOME)/bin/testnet-lnd-stop: build/bin/lnd/testnet-lnd-stop | $(HOME)/bin miniupnpc_install
	umask 077 && cp -f $< $@
