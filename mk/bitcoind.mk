bitcoin-core_install: |\
    required_for_configure_install\
    boost_install\
    openssl_install\
    libevent_install\
    zlib_install\
    zeromq_install\
    python3_install\
	cd cd external/bitcoin-core && { \
		./autogen.sh && \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) --with-incompatible-bdb --disable-wallet --without-gui --without-miniupnpc --with-boost=$(BASE_INSTALL_DIR) --with-boost-libdir=$(BASE_INSTALL_DIR)/lib && $(MAKE_COMPILE) && $(MAKE) install && echo "The bitcoin-core was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

MAKE_DIRS +=  $(CREDENTIALS_DIR)

$(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt\
$(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt: |\
    bitcoin-core_install\
    $(CREDENTIALS_DIR)
	cd bitcoin-core && umask 077 && LANG=C ./share/rpcauth/rpcauth.py lnd >$@

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

$(eval $(call COPY_FILE,build/bitcoind,$(HOME)/.bitcoin,077))

build/bitcoind/bitcoin-testnet.conf :\
    configs/bitcoind/bitcoin-testnet.conf\
    $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt\
    |\
    build/bitcoind
	cp -f $< $@ &&\
	LND_RPC_PASS=`awk '/String to be appended to bitcoin.conf:/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt` && sed -ri \
	-e 's#\$$\$$EXTERNAL_IP_ADDRESS\$$\$$#$(EXTERNAL_IP_ADDRESS)#' \
	-e 's#\$$\$$LND_RPC_PASS\$$\$$#'$$LND_RPC_PASS'#' \
	$@

build/bitcoind/bitcoin-mainnet.conf :\
    configs/bitcoind/bitcoin-mainnet.conf\
    $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt\
    |\
    build/bitcoind
	cp -f $< $@ &&\
	LND_RPC_PASS=`awk '/String to be appended to bitcoin.conf:/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt` && sed -ri \
	-e 's#\$$\$$EXTERNAL_IP_ADDRESS\$$\$$#$(EXTERNAL_IP_ADDRESS)#' \
	-e 's#\$$\$$LND_RPC_PASS\$$\$$#'$$LND_RPC_PASS'#' \
	$@

bitcoind_configs_install: $(HOME)/.bitcoin/bitcoin-testnet.conf $(HOME)/.bitcoin/bitcoin-mainnet.conf
