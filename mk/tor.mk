TOR_VERSION   := 0.4.6.8
TOR_BASE_NAME := tor-$(TOR_VERSION)

$(TOR_BASE_NAME).tar.gz:
	$(WGET) 'https://dist.torproject.org/$@' &&\
	echo '15ce1a37b4cc175b07761e00acdcfa2c08f0d23d6c3ab9c97c464bd38cc5476a  $@'|sha256sum --check - || { echo "Bad checksum"; false; }

tor_install: |\
    $(TOR_BASE_NAME).tar.gz\
    required_for_configure_install\
    gcc_install_8_0_0_min\
    binutils_install\
    openssl_install\
    libevent_install\
    $(HOME)/.bitcoin_envs\
    autotools_install\
    miniupnpc_install
	tar xvzf $(TOR_BASE_NAME).tar.gz
	cd $(TOR_BASE_NAME) && { \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "The tor was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
