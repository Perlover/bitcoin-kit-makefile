# autoconf...
autoconf-2.69.tar.gz: | bash_profile_install
	wget 'http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz'
	echo '82d05e03b93e45f5a39b828dc9c6c29b  autoconf-2.69.tar.gz'|md5sum --check - || \
		{ \
			mv autoconf-2.69.tar.gz autoconf-2.69.bad.tar.gz &&\
			echo "Bad autoconf md5 sum"; false;\
		}

autoconf_install: | autoconf-2.69.tar.gz bash_profile_install
	tar xzf autoconf-2.69.tar.gz
	cd autoconf-2.69 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "Autoconf was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# make test was failed - test/recipes/90-test_shlibload.t It's test for perl shared loading - i skip here make test
openssl_install: | bash_profile_install autotools_install
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

boost_install: | boost_1_64_0.tar.gz bash_profile_install autotools_install gcc_install
	tar xvzf boost_1_64_0.tar.gz
	cd boost_1_64_0 && { \
		./bootstrap.sh --prefix=$$HOME && ./b2 install; \
		if [ -d $(HOME)/include/boost -a `ls -1 $(HOME)/lib/libboost_*|wc -l` -gt 0 ]; then echo "Boost was installed - OK"; else false; fi \
	} &> make_out.txt && tail make_out.txt
	@touch $@

libevent_install: | bash_profile_install autotools_install
	git clone 'https://github.com/libevent/libevent.git'
	cd libevent && { \
		git checkout release-2.1.8-stable &&\
		./autogen.sh && ./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "Libevent was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

pkg-config_install: | bash_profile_install autotools_install
	git clone git://anongit.freedesktop.org/pkg-config
	cd pkg-config && { \
		git checkout pkg-config-0.29.2 &&\
		./autogen.sh --with-internal-glib --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "pkg-config was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# libtool
libtool-2.4.6.tar.gz:
	wget 'ftp://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz'
	echo 'addf44b646ddb4e3919805aa88fa7c5e  libtool-2.4.6.tar.gz'|md5sum --check - || \
		{ \
			mv libtool-2.4.6.tar.gz libtool-2.4.6.bad.tar.gz &&\
			echo "Bad libtool md5 sum"; false;\
		}


libtool_install: | libtool-2.4.6.tar.gz bash_profile_install
	tar xzf libtool-2.4.6.tar.gz
	cd libtool-2.4.6 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "Libtool was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

autotools_install: | autoconf_install automake_install libtool_install
	@touch $@

# m4
m4-1.4.18.tar.gz:
	wget 'http://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.gz'
	echo 'a077779db287adf4e12a035029002d28  m4-1.4.18.tar.gz'|md5sum --check - || \
		{ \
			mv m4-1.4.18.tar.gz m4-1.4.18.bad.tar.gz &&\
			echo "Bad m4 md5 sum"; false;\
		}


m4_install: | m4-1.4.18.tar.gz bash_profile_install
	tar xzf m4-1.4.18.tar.gz
	cd m4-1.4.18 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "The m4 was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# automake
automake-1.15.tar.gz:
	wget 'http://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz'
	echo '716946a105ca228ab545fc37a70df3a3  automake-1.15.tar.gz'|md5sum --check - || \
		{ \
			mv automake-1.15.tar.gz automake-1.15.bad.tar.gz &&\
			echo "Bad automake md5 sum"; false;\
		}


automake_install: | automake-1.15.tar.gz autoconf_install bash_profile_install
	tar xzf automake-1.15.tar.gz
	cd automake-1.15 && { \
		PERL=/usr/bin/perl ./configure --prefix=$$HOME && make && make install && echo "The automake was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# gmp
gmp-6.1.2.tar.bz2:
	wget 'https://gmplib.org/download/gmp/gmp-6.1.2.tar.bz2'
	echo '8ddbb26dc3bd4e2302984debba1406a5  gmp-6.1.2.tar.bz2'|md5sum --check - || \
		{ \
			mv gmp-6.1.2.tar.bz2 gmp-6.1.2.bad.tar.bz2 &&\
			echo "Bad gmp md5 sum"; false;\
		}

gmp_install: | gmp-6.1.2.tar.bz2 bash_profile_install autotools_install
	bzip2 -cd gmp-6.1.2.tar.bz2|tar xvf -
	cd gmp-6.1.2 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "The gmp was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# mpfr
mpfr-4.0.1.tar.bz2:
	wget http://www.mpfr.org/mpfr-current/mpfr-4.0.1.tar.bz2
	echo '8c21d8ac7460493b2b9f3ef3cc610454  mpfr-4.0.1.tar.bz2'|md5sum --check - || \
		{ \
			mv mpfr-4.0.1.tar.bz2 mpfr-4.0.1.bad.tar.bz2 &&\
			echo "Bad mpfr md5 sum"; false;\
		}

mpfr_install: | mpfr-4.0.1.tar.bz2 bash_profile_install gmp_install autotools_install
	bzip2 -cd mpfr-4.0.1.tar.bz2|tar xvf -
	cd mpfr-4.0.1 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "The mpfr was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# mpc
mpc-1.1.0.tar.gz:
	wget ftp://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz
	echo '4125404e41e482ec68282a2e687f6c73  mpc-1.1.0.tar.gz'|md5sum --check - || \
		{ \
			mv mpc-1.1.0.tar.gz mpc-1.1.0.bad.tar.gz &&\
			echo "Bad mpc md5 sum"; false;\
		}

mpc_install: | mpc-1.1.0.tar.gz bash_profile_install gmp_install mpfr_install autotools_install
	tar xzf mpc-1.1.0.tar.gz
	cd mpc-1.1.0 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "The mpc was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# mpc
isl-0.18.tar.gz:
	wget http://isl.gforge.inria.fr/isl-0.18.tar.gz
	echo '076c69f81067f2f5b908c099f445a338  isl-0.18.tar.gz'|md5sum --check - || \
		{ \
			mv isl-0.18.tar.gz isl-0.18.bad.tar.gz &&\
			echo "Bad isl md5 sum"; false;\
		}

isl_install: | bash_profile_install isl-0.18.tar.gz autotools_install
	tar xzf isl-0.18.tar.gz
	cd isl-0.18 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "The isl was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# gcc
gcc-7.1.0.tar.gz:
	wget ftp://ftp.gnu.org/gnu/gcc/gcc-7.1.0/gcc-7.1.0.tar.gz
	echo 'b3d733ad75fdaf88009b52c0cce0ad4c  gcc-7.1.0.tar.gz'|md5sum --check - || \
		{ \
			mv gcc-7.1.0.tar.gz gcc-7.1.0.bad.tar.gz &&\
			echo "Bad gcc md5 sum"; false;\
		}

gcc_install: | gcc-7.1.0.tar.gz bash_profile_install autotools_install gmp_install mpfr_install mpc_install isl_install
	tar xvzf gcc-7.1.0.tar.gz
	cd gcc-7.1.0 && { \
		./configure --prefix=$$HOME --disable-multilib && $(MAKE_COMPILE) && make install && echo "The gcc was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
