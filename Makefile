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

# Our external ip address. If we have only like 192.168.*.* it's be as failover
EXTERNAL_IP_ADDRESS := $(shell ifconfig | awk '/inet addr/{print substr($$2,6)}'|grep -vE '^192\.168\.|^127\.')
ifeq ($(EXTERNAL_IP_ADDRESS),)
EXTERNAL_IP_ADDRESS := $(shell ifconfig | awk '/inet addr/{print substr($$2,6)}'|grep -vE '^127\.')
endif

# MAKE_COMPILE: make or make -jN, where N = amount processors in system - 4
MAKE_COMPILE := $(MAKE) $(shell nproc=$$((`cat /proc/cpuinfo|grep processor|wc -l`-4));nproc=$$(($$nproc<=0?0:$$nproc));if [ $$nproc -le 0 ] ; then echo -n '' ; else echo "-j$$nproc" ; fi)

# For configure script: make variables for implicit rules
CONFIGURE_VARS += LDFLAGS="$(patsubst %,-L%,$(subst :, ,$(shell bash -c '. bitcoin_envs.sh; echo $$LD_LIBRARY_PATH')))"
CONFIGURE_VARS += CPPFLAGS="$(patsubst %,-I%,$(subst :, ,$(shell bash -c '. bitcoin_envs.sh; echo $$CPATH')))"

help:
	@cat Usage.txt

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
include mk/tools.mk
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
include mk/iptables.mk
include mk/zeromq.mk
include mk/rsync.mk
include mk/finally.mk
