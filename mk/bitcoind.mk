bitcoin-core_install: |\
    required_for_configure_install\
    boost_install\
    openssl_install\
    libevent_install\
    zlib_install\
    zeromq_install\
    python3_install\
    miniupnpc_install
	cd external/bitcoin-core && { \
		./autogen.sh && \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) --with-incompatible-bdb --disable-wallet --without-gui --with-boost=$(BASE_INSTALL_DIR) --with-boost-libdir=$(BASE_INSTALL_DIR)/lib && $(MAKE_COMPILE) && $(MAKE) install && echo "The bitcoin-core was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

MAKE_DIRS +=  $(CREDENTIALS_DIR)

$(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt\
$(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt: |\
    bitcoin-core_install\
    $(CREDENTIALS_DIR)
	cd external/bitcoin-core && umask 077 && LANG=C ./share/rpcauth/rpcauth.py lnd >$@

bitcoin-core_update:
	-rm -f bitcoin-core_install
	-cd external/bitcoin-core && $(MAKE) clean
	$(MAKE) bitcoin-core_install

bitcoin_iptables_install:
	if [ `grep -c -- '-dport 8333' /etc/sysconfig/iptables` -le 0 ]; then \
		sed -ri -e 's#^.*--reject-with tcp-reset#-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 8333 -j ACCEPT\n&#' /etc/sysconfig/iptables; \
	fi
	$(reloadIPTables)
	@touch $@

####################### CONFIGS ###################################

MAKE_DIRS +=  build/bitcoind

$(HOME)/.bitcoin/bitcoin-testnet.conf: build/bitcoind/bitcoin-testnet.conf

$(HOME)/.bitcoin/bitcoin-mainnet.conf: build/bitcoind/bitcoin-mainnet.conf

$(eval $(call COPY_FILE,$(HOME)/.bitcoin,077))

build/bitcoind/bitcoin-testnet.conf :\
    $(NETWORK_MK_FILE)\
    configs/bitcoind/bitcoin-testnet.conf\
    $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt\
    |\
    build/bitcoind
	cp -f $< $@ &&\
	LND_RPC_PASS=`awk '/String to be appended to bitcoin.conf:/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt` && sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_BITCOIND_CONFIG_EXTERNALIP_TESTNET\$$\$$#$(BITCOIN_KIT_BITCOIND_CONFIG_EXTERNALIP_TESTNET)#' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#' \
	-e 's#\$$\$$LND_RPC_PASS\$$\$$#'$$LND_RPC_PASS'#' \
	$@

build/bitcoind/bitcoin-mainnet.conf :\
    $(NETWORK_MK_FILE)\
    configs/bitcoind/bitcoin-mainnet.conf\
    $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt\
    |\
    build/bitcoind
	cp -f $< $@ &&\
	LND_RPC_PASS=`awk '/String to be appended to bitcoin.conf:/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt` && sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_BITCOIND_CONFIG_EXTERNALIP_MAINNET\$$\$$#$(BITCOIN_KIT_BITCOIND_CONFIG_EXTERNALIP_MAINNET)#' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#' \
	-e 's#\$$\$$LND_RPC_PASS\$$\$$#'$$LND_RPC_PASS'#' \
	$@

bitcoind_configs_install: |\
    $(HOME)/.bitcoin/bitcoin-testnet.conf\
    $(HOME)/.bitcoin/bitcoin-mainnet.conf
	@touch $@

MAKE_DIRS += build/bin/bitcoind

build/bin/bitcoind/mainnet-bitcoind-start: \
    configs/bin/bitcoind/mainnet-bitcoind-start\
    |\
    bitcoin-core_install\
    build/bin/bitcoind
	cp -f $< $@ && chmod 755 $@

build/bin/bitcoind/testnet-bitcoind-start: \
    configs/bin/bitcoind/testnet-bitcoind-start\
    |\
    bitcoin-core_install\
    build/bin/bitcoind
	cp -f $< $@ && chmod 755 $@

build/bin/bitcoind/mainnet-bitcoind-stop: \
    configs/bin/bitcoind/mainnet-bitcoind-stop\
    |\
    bitcoin-core_install\
    build/bin/bitcoind
	cp -f $< $@ && chmod 755 $@

build/bin/bitcoind/testnet-bitcoind-stop: \
    configs/bin/bitcoind/testnet-bitcoind-stop\
    |\
    bitcoin-core_install\
    build/bin/bitcoind
	cp -f $< $@ && chmod 755 $@

$(HOME)/bin/mainnet-bitcoind-start: build/bin/bitcoind/mainnet-bitcoind-start | miniupnpc_install

$(HOME)/bin/testnet-bitcoind-start: build/bin/bitcoind/testnet-bitcoind-start | miniupnpc_install

$(HOME)/bin/mainnet-bitcoind-stop: build/bin/bitcoind/mainnet-bitcoind-stop | miniupnpc_install

$(HOME)/bin/testnet-bitcoind-stop: build/bin/bitcoind/testnet-bitcoind-stop | miniupnpc_install

