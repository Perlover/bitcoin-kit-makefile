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
	-e 's#\$$\$$EXTERNAL_IP_ADDRESS\$$\$$#$(EXTERNAL_IP_ADDRESS)#' \
	-e 's#\$$\$$RPC_PASS\$$\$$#'$$RPC_PASS'#' \
	$@

build/lnd/bitcoind/lnd-mainnet.conf :\
    configs/lnd/bitcoind/lnd-mainnet.conf\
    $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt\
    |\
    build/lnd/bitcoind
	cp -f $< $@ &&\
	RPC_PASS=`awk '/Your password:/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt` && sed -ri \
	-e 's#\$$\$$EXTERNAL_IP_ADDRESS\$$\$$#$(EXTERNAL_IP_ADDRESS)#' \
	-e 's#\$$\$$RPC_PASS\$$\$$#'$$RPC_PASS'#' \
	$@

lnd_configs_bitcoind_bundle_install: \
    lnd_install\
    $(HOME)/.lnd/lnd-testnet.conf\
    $(HOME)/.lnd/lnd-mainnet.conf\
    lncli-web_lnd_certs_install

###### TODO
# tsl certificates for node.js
# lncli-web & tsl & *.macaroon files
