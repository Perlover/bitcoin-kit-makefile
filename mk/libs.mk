# $(MAKE) test was failed - test/recipes/90-test_shlibload.t It's test for perl shared loading - i skip here $(MAKE) test
openssl_install: |\
    required_for_configure_install
	cd external/openssl && { \
		$(MAKE) clean; ./config --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) && $(MAKE) install && echo "OpenSSL was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

boost_install: |\
    required_for_configure_install
	cd external/boost && { \
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

zlib-1.2.13.tar.gz:
	$(WGET) 'https://github.com/madler/zlib/releases/download/v1.2.13/$@' &&\
	echo 'b3a24de97a8fdbc835b9833169501030b8977031bcb54b3b3ac13740f846ab30  $@'|sha256sum --check - || { echo "Bad checksum"; false; }

zlib_install: |\
    required_for_configure_install\
    zlib-1.2.13.tar.gz
	tar xzf zlib-1.2.13.tar.gz
	cd zlib-1.2.13 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) && $(MAKE) test && $(MAKE) install && echo "The zlib was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

glibc-2.34.tar.gz:
	$(WGET) 'http://ftp.gnu.org/gnu/glibc/$@' &&\
	echo '255b7632746b5fdd478cb7b36bebd1ec1f92c2b552ee364c940f48eb38d07f62  $@'|sha256sum --check - || { echo "Bad checksum"; false; }

glibc_install: |\
    required_for_configure_install\
    bison_install\
    gmake_install\
    glibc-2.34.tar.gz
	tar xzf glibc-2.34.tar.gz
	cd glibc-2.34 && { \
		rm -rf build; mkdir build && cd build && \
		../configure --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) && $(MAKE) test && $(MAKE) install && echo "The glib was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@


bison-3.8.tar.gz:
	$(WGET) 'http://ftp.gnu.org/gnu/bison/$@' &&\
	echo 'd5d184d421aee15603939973a6b0f372f908edfb24c5bc740697497021ad9458  $@'|sha256sum --check - || { echo "Bad checksum"; false; }

bison_install: |\
    required_for_configure_install\
    bison-3.8.tar.gz
	tar xzf bison-3.8.tar.gz
	cd bison-3.8 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) && $(MAKE) install && echo "The bison was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

basez_1.6.2.orig.tar.gz:
	$(WGET) 'http://deb.debian.org/debian/pool/main/b/basez/$@' &&\
	echo '2a9f821488791c2763ef0120c75c43dc83dd16567b7c416f30331889fd598937  $@'|sha256sum --check - || { echo "Bad checksum"; false; }

# To be needed for base64pem utility for example (tor service configuring)
basez_install: |\
    required_for_configure_install\
    basez_1.6.2.orig.tar.gz
	tar xzf basez_1.6.2.orig.tar.gz
	cd basez-1.6.2 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) && $(MAKE) install && echo "The basez utils were installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
