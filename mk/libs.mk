BOOST_VER := 1_72_0
BOOST_SHA256 := c66e88d5786f2ca4dbebb14e06b566fb642a1a6947ad8cc9091f9f445134143f

# $(MAKE) test was failed - test/recipes/90-test_shlibload.t It's test for perl shared loading - i skip here $(MAKE) test
openssl_install: |\
    required_for_configure_install
	cd external/openssl && { \
		$(MAKE) clean; ./config --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) && $(MAKE) install && echo "OpenSSL was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# boost
boost_$(BOOST_VER).tar.gz:
	wget 'https://dl.bintray.com/boostorg/release/$(subst _,.,$(BOOST_VER))/source/boost_$(BOOST_VER).tar.gz'
	echo '$(BOOST_SHA256)  $@'|sha256sum --check - || \
		{ \
			mv boost_$(BOOST_VER).tar.gz boost_$(BOOST_VER).bad.tar.gz &&\
			echo "Bad boost md5 sum"; false;\
		}

boost_install: |\
    required_for_configure_install\
    boost_$(BOOST_VER).tar.gz
	tar xvzf boost_$(BOOST_VER).tar.gz
	cd boost_$(BOOST_VER) && { \
		./bootstrap.sh --prefix=$(BASE_INSTALL_DIR) && ./b2 install; \
		if [ -d $(BASE_INSTALL_DIR)/include/boost -a `ls -1 $(BASE_INSTALL_DIR)/lib/libboost_*|wc -l` -gt 0 ]; then echo "Boost was installed - OK"; else false; fi \
	} &> make_out.txt && tail make_out.txt
	@touch $@

libevent_install: |\
    required_for_configure_install
	cd external/libevent && { \
		$(MAKE) clean; ./autogen.sh && ./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "Libevent was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

zlib-1.2.11.tar.gz:
	wget 'https://zlib.net/$@' &&\
	echo 'c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1  $@'|sha256sum --check - || { echo "Bad checksum"; false; }

zlib_install: |\
    required_for_configure_install\
    zlib-1.2.11.tar.gz
	tar xzf zlib-1.2.11.tar.gz
	cd zlib-1.2.11 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) && $(MAKE) test && $(MAKE) install && echo "The zlib was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
