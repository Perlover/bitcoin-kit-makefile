# $(MAKE) test was failed - test/recipes/90-test_shlibload.t It's test for perl shared loading - i skip here $(MAKE) test
openssl_install: |\
    required_for_configure_install
	cd external/openssl && { \
		make clean; ./config --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) && $(MAKE) install && echo "OpenSSL was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# boost
boost_1_64_0.tar.gz:
	wget 'https://dl.bintray.com/boostorg/release/1.64.0/source/boost_1_64_0.tar.gz'
	echo '319c6ffbbeccc366f14bb68767a6db79  boost_1_64_0.tar.gz'|md5sum --check - || \
		{ \
			mv boost_1_64_0.tar.gz boost_1_64_0.bad.tar.gz &&\
			echo "Bad boost md5 sum"; false;\
		}

boost_install: |\
    required_for_configure_install\
    boost_1_64_0.tar.gz
	tar xvzf boost_1_64_0.tar.gz
	cd boost_1_64_0 && { \
		./bootstrap.sh --prefix=$(BASE_INSTALL_DIR) && ./b2 install; \
		if [ -d $(BASE_INSTALL_DIR)/include/boost -a `ls -1 $(BASE_INSTALL_DIR)/lib/libboost_*|wc -l` -gt 0 ]; then echo "Boost was installed - OK"; else false; fi \
	} &> make_out.txt && tail make_out.txt
	@touch $@

libevent_install: |\
    required_for_configure_install
	cd external/libevent && { \
		make clean; ./autogen.sh && ./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "Libevent was installed - OK"; \
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
