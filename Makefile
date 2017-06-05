# Makefile for CEntOS to compile full bitcoin core node for UASF
# To run from /home/bitcoin/src

SHELL := /bin/bash --login

help:
	@echo $$'*********************\n\n  HELP \n\n*********************\n'

# ~/.bash_profile patch...
$(HOME)/.bitcoin_envs:
	cp -f bitcoin_envs.sh $@

bash_profile_install: | $(HOME)/.bitcoin_envs
	echo $$'\n. $(HOME)/.bitcoin_envs' >> $(HOME)/.bash_profile
	touch $@

# autoconf...
autoconf-2.69.tar.gz: | bash_profile_install
	wget 'http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz'
	echo '82d05e03b93e45f5a39b828dc9c6c29b  autoconf-2.69.tar.gz'|md5sum --check - || \
		{ \
			mv autoconf-2.69.tar.gz autoconf-2.69.bad.tar.gz &&\
			echo "Bad autoconf md5 sum"; false;\
		}

autoconf_install: autoconf-2.69.tar.gz | bash_profile_install
	tar xzf autoconf-2.69.tar.gz
	cd autoconf-2.69 && { \
		./configure --prefix=$$HOME && make && make install && echo "Autoconf was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

bitcoin-uasf_download: |\
    bash_profile_install\
    autotools_install\
    pkg-config_install\
    boost_install\
    gcc_install\
    openssl_install\
    libevent_install
	git clone 'https://github.com/UASF/bitcoin.git' bitcoin-uasf
	cd bitcoin-uasf && git checkout v0.14.1-uasfsegwit0.3
	@touch $@

openssl_install: | bash_profile_install autotools_install
	git clone 'https://github.com/openssl/openssl'
	cd openssl && git checkout 1ee2125922 && { \
		./config --prefix $$HOME && make && make test && make install && echo "OpenSSL was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

boost_install: | bash_profile_install autotools_install
	git clone https://github.com/boostorg/boost.git
	cd boost && { \
		git checkout boost-1.64.0 && git submodule init && git submodule update &&\
		./bootstrap.sh && ./b2 install --prefix=$$HOME && echo "Boost was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

libevent_install: | bash_profile_install autotools_install
	git clone https://github.com/libevent/libevent
	cd libevent && { \
		git checkout release-2.1.8-stable &&\
		./autogen.sh && ./configure --prefix=$$HOME && make && make install && echo "Libevent was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

pkg-config_install: | bash_profile_install autotools_install
	git clone git://anongit.freedesktop.org/pkg-config
	cd pkg-config && { \
		git checkout pkg-config-0.29.2 &&\
		./autogen.sh --with-internal-glib --prefix=$$HOME && make && make install && echo "pkg-config was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# libtool
libtool-2.4.6.tar.gz: | bash_profile_install
	wget 'ftp://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz'
	echo 'addf44b646ddb4e3919805aa88fa7c5e  libtool-2.4.6.tar.gz'|md5sum --check - || \
		{ \
			mv libtool-2.4.6.tar.gz libtool-2.4.6.bad.tar.gz &&\
			echo "Bad libtool md5 sum"; false;\
		}


libtool_install: libtool-2.4.6.tar.gz | bash_profile_install
	tar xzf libtool-2.4.6.tar.gz
	cd libtool-2.4.6 && { \
		./configure --prefix=$$HOME && make && make install && echo "Libtool was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

autotools_install: | autoconf_install automake_install libtool_install
	@touch $@

# m4
m4-1.4.18.tar.gz: | bash_profile_install
	wget 'http://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.gz'
	echo 'a077779db287adf4e12a035029002d28  m4-1.4.18.tar.gz'|md5sum --check - || \
		{ \
			mv m4-1.4.18.tar.gz m4-1.4.18.bad.tar.gz &&\
			echo "Bad m4 md5 sum"; false;\
		}


m4_install: m4-1.4.18.tar.gz | bash_profile_install
	tar xzf m4-1.4.18.tar.gz
	cd m4-1.4.18 && { \
		./configure --prefix=$$HOME && make && make install && echo "The m4 was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# automake
automake-1.15.tar.gz: | bash_profile_install
	wget 'http://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz'
	echo '716946a105ca228ab545fc37a70df3a3  automake-1.15.tar.gz'|md5sum --check - || \
		{ \
			mv automake-1.15.tar.gz automake-1.15.bad.tar.gz &&\
			echo "Bad automake md5 sum"; false;\
		}


automake_install: automake-1.15.tar.gz | bash_profile_install
	tar xzf automake-1.15.tar.gz
	cd automake-1.15 && { \
		./configure --prefix=$$HOME && make && make install && echo "The automake was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# gmp
gmp-6.1.2.tar.bz2: | bash_profile_install
	wget 'https://gmplib.org/download/gmp/gmp-6.1.2.tar.bz2'
	echo '8ddbb26dc3bd4e2302984debba1406a5  gmp-6.1.2.tar.bz2'|md5sum --check - || \
		{ \
			mv gmp-6.1.2.tar.bz2 gmp-6.1.2.bad.tar.bz2 &&\
			echo "Bad gmp md5 sum"; false;\
		}

gmp_install: gmp-6.1.2.tar.bz2 | bash_profile_install autotools_install
	bzip2 -cd gmp-6.1.2.tar.bz2|tar xvf -
	cd gmp-6.1.2 && { \
		./configure --prefix=$$HOME && make && make install && echo "The gmp was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# mpfr
mpfr-3.1.5.tar.bz2: | bash_profile_install gmp_install
	wget http://www.mpfr.org/mpfr-current/mpfr-3.1.5.tar.bz2
	echo 'b1d23a55588e3b2a13e3be66bc69fd8d  mpfr-3.1.5.tar.bz2'|md5sum --check - || \
		{ \
			mv mpfr-3.1.5.tar.bz2 mpfr-3.1.5.bad.tar.bz2 &&\
			echo "Bad mpfr md5 sum"; false;\
		}

mpfr_install: mpfr-3.1.5.tar.bz2 | bash_profile_install autotools_install
	bzip2 -cd mpfr-3.1.5.tar.bz2|tar xvf -
	cd mpfr-3.1.5 && { \
		./configure --prefix=$$HOME && make && make install && echo "The mpfr was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# mpc
mpc-1.0.3.tar.gz: | bash_profile_install gmp_install mpfr_install
	wget ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz
	echo 'd6a1d5f8ddea3abd2cc3e98f58352d26  mpc-1.0.3.tar.gz'|md5sum --check - || \
		{ \
			mv mpc-1.0.3.tar.gz mpc-1.0.3.bad.tar.gz &&\
			echo "Bad mpc md5 sum"; false;\
		}

mpc_install: mpc-1.0.3.tar.gz | bash_profile_install autotools_install
	tar xzf mpc-1.0.3.tar.gz
	cd mpc-1.0.3 && { \
		./configure --prefix=$$HOME && make && make install && echo "The mpc was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# mpc
isl-0.18.tar.gz: | bash_profile_install
	wget http://isl.gforge.inria.fr/isl-0.18.tar.gz
	echo '076c69f81067f2f5b908c099f445a338  isl-0.18.tar.gz'|md5sum --check - || \
		{ \
			mv isl-0.18.tar.gz isl-0.18.bad.tar.gz &&\
			echo "Bad isl md5 sum"; false;\
		}

isl_install: isl-0.18.tar.gz | autotools_install bash_profile_install
	tar xzf isl-0.18.tar.gz
	cd isl-0.18 && { \
		./configure --prefix=$$HOME && make && make install && echo "The isl was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# gcc
gcc-7.1.0.tar.gz: | autotools_install gmp_install mpfr_install mpc_install isl_install bash_profile_install
	wget ftp://ftp.gnu.org/gnu/gcc/gcc-7.1.0/gcc-7.1.0.tar.gz
	echo 'b3d733ad75fdaf88009b52c0cce0ad4c  gcc-7.1.0.tar.gz'|md5sum --check - || \
		{ \
			mv gcc-7.1.0.tar.gz gcc-7.1.0.bad.tar.gz &&\
			echo "Bad gcc md5 sum"; false;\
		}

gcc_install: gcc-7.1.0.tar.gz | bash_profile_install
	tar xvzf gcc-7.1.0.tar.gz
	cd gcc-7.1.0 && { \
		./configure --prefix=$$HOME --disable-multilib && make && make install && echo "The gcc was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

full_install: bitcoin-uasf_download
