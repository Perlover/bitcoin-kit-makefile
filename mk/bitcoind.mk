# Bitcoin Core (v32.x) needs: gcc >= 12.1, cmake >= 3.22, Boost >= 1.74.
# libevent is not a dependency any more (since v32.0).
#
# The -D options belong to the *configure* step (cmake -B); `cmake --build`
# does not accept them.
#   ENABLE_IPC=OFF   - multiprocess binaries need Cap'n Proto, which we do not build
#   BUILD_TESTS=OFF  - test_bitcoin & co. are not installed anyway, saves a lot of time
#   CMAKE_PREFIX_PATH - lets cmake find our own Boost / ZeroMQ under $(BASE_INSTALL_DIR)
BITCOIN_CORE_CMAKE_VARS = \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=$(BASE_INSTALL_DIR) \
    -DCMAKE_PREFIX_PATH:PATH=$(BASE_INSTALL_DIR) \
    -DAPPEND_LDFLAGS:STRING="-lrt $(patsubst %,-L%,$(subst :, ,$(shell bash -c '. bitcoin_envs.sh; echo $$LD_LIBRARY_PATH')))" \
    -DAPPEND_CPPFLAGS:STRING="$(patsubst %,-isystem %,$(subst :, ,$(shell bash -c '. bitcoin_envs.sh; echo $$CPATH')))" \
    -DENABLE_WALLET:BOOL=OFF \
    -DENABLE_IPC:BOOL=OFF \
    -DWITH_ZMQ:BOOL=ON \
    -DBUILD_GUI:BOOL=OFF \
    -DBUILD_TESTS:BOOL=OFF \
    -DBUILD_BENCH:BOOL=OFF

# The same parallelism as $(MAKE_COMPILE) uses: -j<CPUs - 1>, or nothing on a
# single-CPU host
BITCOIN_CORE_BUILD_JOBS = $(filter -j%,$(MAKE_COMPILE))

# The build is split in two stamps so that an upgrade needs only a short downtime:
#
#   bitcoin-core_build   - everything that takes long: the compiler, the libraries and
#                          the compilation itself. It does not touch the installed
#                          bitcoind, so it is safe to run while the old daemon works.
#   bitcoin-core_install - `cmake --install` only: a matter of seconds, to be done
#                          when the daemon is stopped.
#
# `this_repo_update` (mk/common.mk) wipes the submodule work trees, the build
# directory included - that is why it also drops the bitcoin-core_build stamp.
#
# bitcoin-core_install deliberately has NO prerequisites and calls the build
# through a sub-make instead. Many other targets reach bitcoin-core_install
# through their order-only prerequisites (configs, wrapper scripts, lnd-update):
# as a prerequisite, a missing bitcoin-core_build or compiler stamp would make
# them rebuild gcc and Bitcoin Core on a host where Bitcoin Core is already
# installed.
bitcoin-core_build: |\
    required_for_configure_install\
    cmake_3_31_install\
    gcc_install_12_1_0_min\
    binutils_install\
    boost_install\
    openssl_install\
    zlib_install\
    zeromq_install\
    python39_install\
    miniupnpc_install
	cd external/bitcoin-core && git checkout -f && git clean -fdx && { \
		cmake -B build $(BITCOIN_CORE_CMAKE_VARS) && \
		cmake --build build $(BITCOIN_CORE_BUILD_JOBS) && \
		echo "The bitcoin-core was built - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

bitcoin-core_install:
	$(MAKE) bitcoin-core_build
	@[ -d external/bitcoin-core/build ] || { \
		echo "ERROR: external/bitcoin-core/build does not exist - run 'make prepare-bitcoin-core-update' first"; false; \
	}
	cd external/bitcoin-core && cmake --install build && echo "The bitcoin-core was installed - OK"
	@touch $@

MAKE_DIRS +=  $(CREDENTIALS_DIR)

$(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt\
$(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt: |\
    bitcoin-core_install\
    $(CREDENTIALS_DIR)
	cd external/bitcoin-core && umask 077 && LANG=C ./share/rpcauth/rpcauth.py lnd >$@

prepare-bitcoin-core-update: this_repo_update
	-rm -f bitcoin-core_build bitcoin-core_install zeromq_install openssl_install binutils_install boost_install

# Optional step of an upgrade: build everything while the old bitcoind is
# still running, then stop it and run `make bitcoin-core-update`, which only
# has to install the ready binaries.
bitcoin-core-build:
	$(MAKE) bitcoin-core_build

bitcoin-core-update:
	$(MAKE) bitcoin-core_install

bitcoin_iptables_install:
	if [ `grep -c -- '-dport 8333' /etc/sysconfig/iptables` -le 0 ]; then \
		sed -ri -e 's#^.*--reject-with tcp-reset#-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 8333 -j ACCEPT\n&#' /etc/sysconfig/iptables; \
	fi
	$(reloadIPTables)
	@touch $@

####################### CONFIGS ###################################

MAKE_DIRS +=  build/bitcoind
MAKE_DIRS += $(HOME)/.bitcoin

$(HOME)/.bitcoin/bitcoin-testnet.conf: build/bitcoind/bitcoin-testnet.conf | $(HOME)/.bitcoin
	umask 077 && \
	if [ -f $@ ]; then \
	    cp -f $< $@.new.conf && \
	    touch $@; \
	else \
	    cp -f $< $@; \
	fi

$(HOME)/.bitcoin/bitcoin-mainnet.conf: build/bitcoind/bitcoin-mainnet.conf | $(HOME)/.bitcoin
	umask 077 && \
	if [ -f $@ ]; then \
	    cp -f $< $@.new.conf && \
	    touch $@; \
	else \
	    cp -f $< $@; \
	fi

build/bitcoind/bitcoin-testnet.conf :\
    $(NETWORK_MK_FILE)\
    configs/bitcoind/bitcoin-testnet.conf\
    $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt\
    |\
    build/bitcoind
	cp -f configs/bitcoind/bitcoin-testnet.conf $@ &&\
	LND_RPC_PASS=`awk '/String to be appended to bitcoin.conf:/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-testnet-auth.txt` && \
	sed -ri \
	-e 's#\$$\$$HOME\$$\$$#$(HOME)#g' \
	-e 's#\$$\$$BITCOIN_KIT_BITCOIND_CONFIG_EXTERNALIP_TESTNET\$$\$$#$(BITCOIN_KIT_BITCOIND_CONFIG_EXTERNALIP_TESTNET)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' \
	-e 's#\$$\$$LND_RPC_PASS\$$\$$#'$$LND_RPC_PASS'#g' \
	$@


build/bitcoind/bitcoin-mainnet.conf :\
    $(NETWORK_MK_FILE)\
    configs/bitcoind/bitcoin-mainnet.conf\
    $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt\
    |\
    build/bitcoind
	cp -f configs/bitcoind/bitcoin-mainnet.conf $@ &&\
	LND_RPC_PASS=`awk '/String to be appended to bitcoin.conf:/{getline; print}' $(CREDENTIALS_DIR)/bitcoind-lnd-mainnet-auth.txt` && \
	sed -ri \
	-e 's#\$$\$$HOME\$$\$$#$(HOME)#g' \
	-e 's#\$$\$$BITCOIN_KIT_BITCOIND_CONFIG_EXTERNALIP_MAINNET\$$\$$#$(BITCOIN_KIT_BITCOIND_CONFIG_EXTERNALIP_MAINNET)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' \
	-e 's#\$$\$$LND_RPC_PASS\$$\$$#'$$LND_RPC_PASS'#g' \
	$@

bitcoind_configs_install: |\
    $(HOME)/.bitcoin/bitcoin-testnet.conf\
    $(HOME)/.bitcoin/bitcoin-mainnet.conf
	@touch $@

MAKE_DIRS += build/bin/bitcoind

build/bin/bitcoind/mainnet-bitcoind-start: \
    $(NETWORK_MK_FILE)\
    configs/bin/bitcoind/mainnet-bitcoind-start\
    |\
    bitcoin-core_install\
    bitcoind_configs_install\
    build/bin/bitcoind
	cp -f configs/bin/bitcoind/mainnet-bitcoind-start $@ && \
	sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_UPNP_SUPPORT\$$\$$#$(BITCOIN_KIT_UPNP_SUPPORT)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' $@ && \
	chmod 755 $@

build/bin/bitcoind/testnet-bitcoind-start: \
    $(NETWORK_MK_FILE)\
    configs/bin/bitcoind/testnet-bitcoind-start\
    |\
    bitcoin-core_install\
    bitcoind_configs_install\
    build/bin/bitcoind
	cp -f configs/bin/bitcoind/testnet-bitcoind-start $@ && \
	sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_UPNP_SUPPORT\$$\$$#$(BITCOIN_KIT_UPNP_SUPPORT)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' $@ && \
	chmod 755 $@

build/bin/bitcoind/mainnet-bitcoind-stop: \
    $(NETWORK_MK_FILE)\
    configs/bin/bitcoind/mainnet-bitcoind-stop\
    |\
    bitcoin-core_install\
    bitcoind_configs_install\
    build/bin/bitcoind
	cp -f configs/bin/bitcoind/mainnet-bitcoind-stop $@ && \
	sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_UPNP_SUPPORT\$$\$$#$(BITCOIN_KIT_UPNP_SUPPORT)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' $@ && \
	chmod 755 $@

build/bin/bitcoind/testnet-bitcoind-stop: \
    $(NETWORK_MK_FILE)\
    configs/bin/bitcoind/testnet-bitcoind-stop\
    |\
    bitcoin-core_install\
    bitcoind_configs_install\
    build/bin/bitcoind
	cp -f configs/bin/bitcoind/testnet-bitcoind-stop $@ && \
	sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_UPNP_SUPPORT\$$\$$#$(BITCOIN_KIT_UPNP_SUPPORT)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' $@ && \
	chmod 755 $@

$(HOME)/bin/mainnet-bitcoind-start: build/bin/bitcoind/mainnet-bitcoind-start | miniupnpc_install $(HOME)/bin
	umask 077 && cp -f $< $@

$(HOME)/bin/testnet-bitcoind-start: build/bin/bitcoind/testnet-bitcoind-start | miniupnpc_install $(HOME)/bin
	umask 077 && cp -f $< $@

$(HOME)/bin/mainnet-bitcoind-stop: build/bin/bitcoind/mainnet-bitcoind-stop | miniupnpc_install $(HOME)/bin
	umask 077 && cp -f $< $@

$(HOME)/bin/testnet-bitcoind-stop: build/bin/bitcoind/testnet-bitcoind-stop | miniupnpc_install $(HOME)/bin
	umask 077 && cp -f $< $@
