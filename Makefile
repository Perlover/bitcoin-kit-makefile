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

# --login is important here. It forces read ~/.bash_profile file before each execution of make command in rules
SHELL := /bin/bash --login

# The base directory of all packages. It's home directory now but in a future it can be used for common directory in OS, for example /opt/
BASE_INSTALL_DIR := $(HOME)

# Here will be some password files and etc. for authorization of services
CREDENTIALS_DIR := $(HOME)/credentials

# This hash will be used when defining the network configuration (as cache ID)
HASH_NETWORK_CONFIG := $(shell echo `uname  -a` `/sbin/ifconfig | awk '/inet addr/{print substr($$2,6)}'|grep -vE '^127\.'`|md5sum|awk '{print $$1}')

# This is macro for version compareof software (for example gnu, python, pkg-config)
# $(eval $(call COMPARE_VERSIONS,command_for_version,required_version,result_variable_name))
# Example: $(eval $(call COMPARE_VERSIONS,gcc -dumpversion,5.0.0,GCC_5_0_0)) after will be 'OK' or 'FAIL'
COMPARE_VERSIONS = $(3) = $$(shell if [ "$$$$(printf '%s\n' "$(2)" $$$$($(1) &>/dev/null || echo "0.0.0") | sort -V | head -n1)" = "$(2)" ]; then echo OK; else echo FAIL; fi)

VERSION_MASK := sed -r -e 's#.* ([0-9]+\.[0-9a-z]+(\.[0-9a-z]+)?)$#\1#'
$(eval $(call COMPARE_VERSIONS,m4 --version|head -1|$(VERSION_MASK),1.4.17,M4_MIN))
$(eval $(call COMPARE_VERSIONS,automake --version|head -1|$(VERSION_MASK),1.15,AUTOMAKE_MIN))
$(eval $(call COMPARE_VERSIONS,autoconf --version|head -1|$(VERSION_MASK),2.69,AUTOCONF_MIN))
$(eval $(call COMPARE_VERSIONS,libtoolize --version|head -1|$(VERSION_MASK),2.4.6,LIBTOOL_MIN))
$(eval $(call COMPARE_VERSIONS,pkg-config --version|head -1|$(VERSION_MASK),0.29.1,PKG_CONFIG_MIN))

ifneq ($(MAKECMDGOALS),rsync)
ifneq ($(MAKECMDGOALS),clean)
ifneq ($(MAKECMDGOALS),help)
ifneq ($(MAKECMDGOALS),help-more)
ifneq ($(MAKECMDGOALS),)

NETWORK_MK_FILE    := network_$(HASH_NETWORK_CONFIG).mk
NETWORK_SHELL_FILE := network_$(HASH_NETWORK_CONFIG).sh

ifneq ($(wildcard $(NETWORK_MK_FILE)),$(NETWORK_MK_FILE))
$(shell mkdir -p $(CREDENTIALS_DIR) && ./define_all_ipaddresses.sh $(NETWORK_MK_FILE) $(NETWORK_SHELL_FILE) $(CREDENTIALS_DIR)/network-summary.txt)
endif

include $(NETWORK_MK_FILE)

endif
endif
endif
endif
endif

PROFILE_FILE := $(shell if [ -f $(HOME)/.bash_profile ]; then \
		echo $(HOME)/.bash_profile; \
	elif [ -f $(HOME)/.bash_login ]; then \
		echo $(HOME)/.bash_login; \
	else \
		echo $(HOME)/.profile; \
	fi )

# For aliases
BASHRC_FILE := $(HOME)/.bashrc

# MAKE_COMPILE: make or make -jN, where N = amount processors in system - 1
MAKE_COMPILE := $(MAKE) $(shell nproc=$$((`cat /proc/cpuinfo|grep processor|wc -l`-1));nproc=$$(($$nproc<=1?0:$$nproc));if [ $$nproc -le 0 ] ; then echo -n '' ; else echo "-j$$nproc" ; fi)

# For configure script: make variables for implicit rules
CONFIGURE_VARS += LDFLAGS="$(patsubst %,-L%,$(subst :, ,$(shell bash -c '. bitcoin_envs.sh; echo $$LD_LIBRARY_PATH')))"
CONFIGURE_VARS += CPPFLAGS="$(patsubst %,-I%,$(subst :, ,$(shell bash -c '. bitcoin_envs.sh; echo $$CPATH')))"

.PHONY: help help-more

help:
	@cat Usage_Brief.txt

help-more:
	@cat Usage_More.txt

bitcoind-start:
	nice -n 20 bitcoind -daemon -upnp=0 -maxconnections=500 -maxmempool=100 -mempoolexpiry=24
	@echo "The bitcoind started"

bitcoind-stop:
	bitcoin-cli stop
	@echo "The bitcoind stoped"

bitcoind-restart:
	sleep 5 && $(MAKE) stop && sleep 5 && $(MAKE) start
	@echo "The bitcoind restarted"

.PHONY: start stop restart

include mk/common.mk
include mk/autotools.mk
include mk/gcc.mk
include mk/libs.mk
include mk/bitcoind.mk
include mk/electrumx.mk
include mk/python3.mk
include mk/python2.mk
include mk/sqlite3.mk
include mk/binutils.mk
include mk/c-lightning.mk
include mk/nodejs.mk
include mk/golang.mk
include mk/lnd.mk
include mk/lncli-web.mk
include mk/iptables.mk
include mk/zeromq.mk
include mk/miniupnp.mk
include mk/i-want-lightning.mk
include mk/rsync.mk
include mk/finally.mk
