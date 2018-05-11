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

MAKE_DIRS +=  build/bitcoind

$(call COPY_FILE,build/bitcoind,$(HOME)/.lnd,077)

build/bitcoind/lnd-testnet.conf :\
    configs/lnd/bitcoind/lnd-testnet.conf\
    $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt\
    |\
    build/bitcoind
	cp -f $< $@ &&\
	RPC_PASS=`awk '/blah/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt` sed -ri\
	-e 's#\$$\$$EXTERNAL_IP_ADDRESS\$$\$$#$(EXTERNAL_IP_ADDRESS)#'\
	-e 's#\$$\$$RPC_PASS\$$\$$#$RPC_PASS#'\
	$@

lnd_testnet_config_for_bitcoind_install: $(HOME)/.lnd/lnd-testnet.conf
