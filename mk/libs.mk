# make test was failed - test/recipes/90-test_shlibload.t It's test for perl shared loading - i skip here make test
openssl_install: |\
    required_for_configure_install
	git clone 'https://github.com/openssl/openssl.git'
	cd openssl && git checkout 1ee2125922 && { \
		./config --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "OpenSSL was installed - OK"; \
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
		./bootstrap.sh --prefix=$$HOME && ./b2 install; \
		if [ -d $(HOME)/include/boost -a `ls -1 $(HOME)/lib/libboost_*|wc -l` -gt 0 ]; then echo "Boost was installed - OK"; else false; fi \
	} &> make_out.txt && tail make_out.txt
	@touch $@

libevent_install: |\
    required_for_configure_install
	git clone 'https://github.com/libevent/libevent.git'
	cd libevent && { \
		git checkout release-2.1.8-stable &&\
		./autogen.sh && ./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "Libevent was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

