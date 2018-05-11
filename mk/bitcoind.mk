bitcoin-core_download:
	git clone 'https://github.com/bitcoin/bitcoin.git' bitcoin-core
	cd bitcoin-core && git checkout v0.16.0
	@touch $@

bitcoin-core_install: |\
    required_for_configure_install\
    boost_install\
    openssl_install\
    libevent_install\
    zlib_install\
    zeromq_install\
    python3_install\
    bitcoin-core_download
	cd bitcoin-core && { \
		./autogen.sh && \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) --with-incompatible-bdb --disable-wallet --without-gui --without-miniupnpc --with-boost=$(BASE_INSTALL_DIR) --with-boost-libdir=$(BASE_INSTALL_DIR)/lib && $(MAKE_COMPILE) && $(MAKE) install && echo "The bitcoin-core was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

MAKE_DIRS +=  $(HOME)/.bitcoin

$(call COPY_FILE,configs/bitcoind,$(HOME)/.bitcoin,077)

MAKE_DIRS +=  $(CREDENTIALS_DIR)

$(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt\
$(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt: |\
    bitcoin-core_install\
    $(CREDENTIALS_DIR)
	cd bitcoin-core && umask 077 && LANG=C ./share/rpcauth/rpcauth.py lnd >$@

bitcoin-core_update:
	-rm -f bitcoin-core_download bitcoin-core_install
	-rm -rf bitcoin-core
	$(MAKE) bitcoin-core_install

bitcoin_iptables_install:
	if [ `grep -c -- '-dport 8333' /etc/sysconfig/iptables` -le 0 ]; then \
		sed -ri -e 's#^.*--reject-with tcp-reset#-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 8333 -j ACCEPT\n&#' /etc/sysconfig/iptables; \
	fi
	$(reloadIPTables)
	@touch $@
