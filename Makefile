# Copyright (c) 2017 Perlover
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

# Makefile for CentOS to compile full bitcoin core node for UASF
# This make does many things under user local folder ( NOT root! ;-) ):
#   Compiling and installing from fresh sources (actual at 2017-06-06):
#   - autotools
#   - pkg-config
#   - libevent
#   - openssl
#   - automake
#   - m4
#   - gcc 7.1
#   - bitcoin core node v0.14.1 with UASF/SegWit patch
# To run from /home/bitcoin/bitcoin-core-makefile for example

SHELL := /bin/bash --login

# MAKE_COMPILE: make or make -jN, where N = amount processors in system - 4
MAKE_COMPILE := make $(shell nproc=$$((`cat /proc/cpuinfo|grep processor|wc -l`-4));nproc=$$(($$nproc<=0?0:$$nproc));if [ $$nproc -le 0 ] ; then echo -n '' ; else echo "-j$$nproc" ; fi)

help:
	@echo $$'*******************************************************************************\n\n  HELP \n\n*******************************************************************************\n'
	@echo $$'make bitcoin-core_install\t- install bitcoind in $$HOME/bin\n'\
	$$'make bitcoin-core_update\t- update already installed bitcoind in $$HOME/bin\n'\
	$$'\n\nFROM ROOT:\n\nmake iptables_install\n\tThe setup of my example iptables config.\n\tToo see the iptables.template file here (there are no bitcoin rules)\n\tBE CAREFULLY! It'\'$$'s risk!\n\n'\
	$$'make bitcoin_iptables_install\n\tpatch iptables config for bitcoin node\n\t(To do after "make iptables_install" for example)\n\tYou will need to press ENTER twice when will be asked!\n\tIf you will not press ENTER twiceyour firewall settings will be reset to full access again\n\t(it prevents from wrong firewall rules through network)\n\nmake [start|stop|restart]\n\tThe helper - to start/stop/restart daemon after installation ;-)\n\n*******************************************************************************\n'

# ~/.bash_profile patch...
$(HOME)/.bitcoin_envs: bitcoin_envs.sh
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

autoconf_install: | autoconf-2.69.tar.gz bash_profile_install
	tar xzf autoconf-2.69.tar.gz
	cd autoconf-2.69 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "Autoconf was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

bitcoin-core_download:
	git clone 'https://github.com/bitcoin/bitcoin.git' bitcoin-core
	cd bitcoin-core && git checkout v0.15.1
	@touch $@

bitcoin-core_install: |\
    bash_profile_install\
    bitcoin-core_download\
    gcc_install\
    autotools_install\
    pkg-config_install\
    boost_install\
    openssl_install\
    libevent_install
	cd bitcoin-core && { \
		./autogen.sh && \
		./configure --prefix=$$HOME --with-incompatible-bdb --disable-wallet --without-gui --without-miniupnpc --with-boost=$(HOME) --with-boost-libdir=$(HOME)/lib && make && make install && echo "The bitcoin-core was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

bitcoin-core_update:
	-rm -f bitcoin-core_download bitcoin-core_install
	-rm -rf bitcoin-core
	$(MAKE) bitcoin-core_install

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
		./configure --prefix=$$HOME && make && make install && echo "The automake was installed - OK"; \
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
mpfr-3.1.6.tar.bz2:
	wget http://www.mpfr.org/mpfr-current/mpfr-3.1.6.tar.bz2
	echo '320c28198def956aeacdb240b46b8969  mpfr-3.1.6.tar.bz2'|md5sum --check - || \
		{ \
			mv mpfr-3.1.6.tar.bz2 mpfr-3.1.6.bad.tar.bz2 &&\
			echo "Bad mpfr md5 sum"; false;\
		}

mpfr_install: | mpfr-3.1.6.tar.bz2 bash_profile_install gmp_install autotools_install
	bzip2 -cd mpfr-3.1.6.tar.bz2|tar xvf -
	cd mpfr-3.1.6 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "The mpfr was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# mpc
mpc-1.0.3.tar.gz:
	wget ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz
	echo 'd6a1d5f8ddea3abd2cc3e98f58352d26  mpc-1.0.3.tar.gz'|md5sum --check - || \
		{ \
			mv mpc-1.0.3.tar.gz mpc-1.0.3.bad.tar.gz &&\
			echo "Bad mpc md5 sum"; false;\
		}

mpc_install: | mpc-1.0.3.tar.gz bash_profile_install gmp_install mpfr_install autotools_install
	tar xzf mpc-1.0.3.tar.gz
	cd mpc-1.0.3 && { \
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

define reloadIPTables
	@ echo -n $$'***************************************************************\n***************************************************************\n\nPress now enter and then press enter too (firewall settings)'; read waiting
	@ { sleep 60 && service iptables stop >/dev/null & } &> /dev/null;\
	service iptables restart; backgroup_pid=$$! ; strstr() { [ "$${1#*$$2*}" = "$$1" ] && return 1; return 0; }; \
	echo -n "To kill sleep ? (Y)es/(N)o [Y] "; read answer; echo $$answer; \
	if strstr $$"yY" "$$answer" || [ "$$answer" = "" ] ; then kill $$backgroup_pid; echo "All is OK" ; else echo 'ATTENTION! Firewall will be flushed!' ; fi
endef

bitcoin_iptables_install:
	if [ `grep -c -- '-dport 8333' /etc/sysconfig/iptables` -le 0 ]; then \
		sed -ri -e 's#^.*--reject-with tcp-reset#-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 8333 -j ACCEPT\n&#' /etc/sysconfig/iptables; \
	fi
	$(reloadIPTables)
	@touch $@

iptables_install: /etc/sysconfig/iptables reload_iptables startup_iptables
	echo $$'If you see this message through ssh - your network works fine ;-)'

/etc/sysconfig/iptables:
	cat iptables.template >$@

reload_iptables :
	$(reloadIPTables)
	@touch $@

startup_iptables :
	chkconfig iptables reset
	service iptables start
	@touch $@

start:
	nice -n 20 bitcoind -daemon -upnp=0 -maxconnections=500 -maxmempool=100 -mempoolexpiry=24
	@echo "The bitcoind started"

stop:
	bitcoin-cli stop
	@echo "The bitcoind stoped"

restart:
	sleep 5 && $(MAKE) stop && sleep 5 && $(MAKE) start
	@echo "The bitcoind restarted"

.PHONY: start stop restart
