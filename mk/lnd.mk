lnd_install: |\
    golang_install
	go get -d github.com/lightningnetwork/lnd &&\
	cd $$GOPATH/src/github.com/lightningnetwork/lnd &&\
	$(MAKE_COMPILE) && $(MAKE) install
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

$(eval $(call COPY_FILE,build/lnd/bitcoind,$(HOME)/.lnd,077))

build/lnd/bitcoind/lnd-testnet.conf :\
    configs/lnd/bitcoind/lnd-testnet.conf\
    $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt\
    |\
    build/lnd/bitcoind
	cp -f $< $@ &&\
	RPC_PASS=`awk '/Your password:/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt` && sed -ri \
	-e 's#\$$\$$PUBLIC_IP_ADDRESS\$$\$$#$(PUBLIC_IP_ADDRESS)#' \
	-e 's#\$$\$$LISTEN_IP_ADDRESS\$$\$$#$(LISTEN_IP_ADDRESS)#' \
	-e 's#\$$\$$RPC_PASS\$$\$$#'$$RPC_PASS'#' \
	$@

build/lnd/bitcoind/lnd-mainnet.conf :\
    configs/lnd/bitcoind/lnd-mainnet.conf\
    $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt\
    |\
    build/lnd/bitcoind
	cp -f $< $@ &&\
	RPC_PASS=`awk '/Your password:/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt` && sed -ri \
	-e 's#\$$\$$PUBLIC_IP_ADDRESS\$$\$$#$(PUBLIC_IP_ADDRESS)#' \
	-e 's#\$$\$$LISTEN_IP_ADDRESS\$$\$$#$(LISTEN_IP_ADDRESS)#' \
	-e 's#\$$\$$RPC_PASS\$$\$$#'$$RPC_PASS'#' \
	$@

lnd_configs_bitcoind_bundle_install: |\
    bitcoind_configs_install\
    lncli-web_lnd_certs_install\
    $(HOME)/.lnd/lnd-testnet.conf\
    $(HOME)/.lnd/lnd-mainnet.conf
	@touch $@

i-want-lightning: |\
    bitcoin-core_install\
    lnd_install\
    lncli-web_install\
    bitcoind_configs_install\
    lnd_configs_bitcoind_bundle_install\
    lncli-web_configs_install
	@touch $@

lnd_create_wallet_macaroon_install:
	@[ -f $(HOME)/.lnd/admin.macaroon ] && echo "You already setted up the lnd daemon (the file $(HOME)/.lnd/admin.macaroon exists)" && touch $@ && false
	@umask 077 && nohup lnd &>.$@.out.txt & echo $$! >.$@.pid.txt
	@echo $$'********************************************************************************\n\n\n Now the 'lncli create' was run (creation of wallet). It's important! Please write passwords & seed of lnd!\n\n\n********************************************************************************\n\n'
	@echo 'Please press ENTER to next step:'; read
	lncli create
	-@kill `cat .$@.pid.txt`; rm -f .$@.pid.txt .$@.out.txt
	cp -f $(HOME)/.lnd/admin.macaroon $(HOME)/opt/lncli-web/
	@touch $@

set-up-lightning: |\
    i-want-lightning\
    lnd_install\
    lnd_configs_bitcoind_bundle_install\
    $(HOME)/.bitcoin_aliases\
    lncli-web_configs_install\
    lnd_create_wallet_macaroon_install\
    $(HOME)/opt/lncli-web/start.sh

set-up-lightning-testnet: | set-up-lightning
	if [ ! -f $(HOME)/.bitcoin/bitcoin.conf ]; then ln -s $(HOME)/.bitcoin/bitcoin-testnet.conf $(HOME)/.bitcoin/bitcoin.conf; fi
	if [ ! -f $(HOME)/.lnd/lnd.conf ]; then ln -s $(HOME)/.lnd/lnd-testnet.conf $(HOME)/.lnd/lnd.conf; fi

set-up-lightning-mainnet: | set-up-lightning
	if [ ! -f $(HOME)/.bitcoin/bitcoin.conf ]; then ln -s $(HOME)/.bitcoin/bitcoin-mainnet.conf $(HOME)/.bitcoin/bitcoin.conf; fi
	if [ ! -f $(HOME)/.lnd/lnd.conf ]; then ln -s $(HOME)/.lnd/lnd-mainnet.conf $(HOME)/.lnd/lnd.conf; fi
