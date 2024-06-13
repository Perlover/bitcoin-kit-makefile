TOR_VERSION   := 0.4.6.10
TOR_BASE_NAME := tor-$(TOR_VERSION)

$(TOR_BASE_NAME).tar.gz:
	$(WGET) 'https://dist.torproject.org/$@' &&\
	echo '94ccd60e04e558f33be73032bc84ea241660f92f58cfb88789bda6893739e31c  $@'|sha256sum --check - || { echo "Bad checksum"; false; }

tor_install: |\
    $(TOR_BASE_NAME).tar.gz\
    required_for_configure_install\
    gcc_install_11_2_0_min\
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
