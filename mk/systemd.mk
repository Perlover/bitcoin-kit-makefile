# Per-user systemd unit files for bitcoind and lnd.
#
# Workflow:
#   make systemd-install         — template & copy units, run daemon-reload
#   make enable-linger           — let user services run when no one is logged in
#   make systemd-enable-mainnet  — enable+start bitcoind@mainnet, lnd@mainnet
#   make systemd-enable-testnet  — same for testnet
#   make systemd-status          — show what is installed/active/enabled
#   make systemd-disable-mainnet — disable+stop the mainnet pair
#   make systemd-disable-testnet — disable+stop the testnet pair
#   make systemd-uninstall       — disable everything and remove the unit files
#
# All targets are friendly no-ops on hosts where systemctl is not available
# (old CentOS without systemd, containers, etc.).
#
# `systemd-enable-<net>` only enables those services whose corresponding
# `~/bin/<net>-<svc>-start` wrapper actually exists, so a host that only
# installed lnd (or only bitcoind) will not get a unit it cannot run. The
# unit files themselves also carry `ConditionPathIsExecutable=` for the
# same wrapper, which makes the check defensive at start time too.
#
# After enabling lnd, the daemon comes up and waits for the wallet unlock
# password. Run `<net>-lnd-start` in a terminal as usual to enter it — the
# wrapper detects the systemd-managed lnd via its pid file and proceeds
# straight to `lncli unlock`.

SYSTEMD_USER_DIR := $(HOME)/.config/systemd/user
SYSTEMCTL_OK     := $(shell command -v systemctl >/dev/null 2>&1 && echo yes)

MAKE_DIRS += $(SYSTEMD_USER_DIR)
MAKE_DIRS += build/systemd

####################### CONFIGS ###################################

build/systemd/bitcoind@.service: \
    $(NETWORK_MK_FILE) \
    configs/systemd/bitcoind@.service \
    | build/systemd
	cp -f configs/systemd/bitcoind@.service $@ && \
	sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_UPNP_SUPPORT\$$\$$#$(BITCOIN_KIT_UPNP_SUPPORT)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' $@

build/systemd/lnd@.service: \
    $(NETWORK_MK_FILE) \
    configs/systemd/lnd@.service \
    | build/systemd
	cp -f configs/systemd/lnd@.service $@ && \
	sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_UPNP_SUPPORT\$$\$$#$(BITCOIN_KIT_UPNP_SUPPORT)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' $@

$(SYSTEMD_USER_DIR)/bitcoind@.service: build/systemd/bitcoind@.service | $(SYSTEMD_USER_DIR)
	cp -f $< $@

$(SYSTEMD_USER_DIR)/lnd@.service: build/systemd/lnd@.service | $(SYSTEMD_USER_DIR)
	cp -f $< $@

####################### TARGETS ###################################

.PHONY: systemd-install systemd-uninstall \
        systemd-enable-mainnet systemd-enable-testnet \
        systemd-disable-mainnet systemd-disable-testnet \
        systemd-status enable-linger

systemd-install: \
    $(SYSTEMD_USER_DIR)/bitcoind@.service \
    $(SYSTEMD_USER_DIR)/lnd@.service
ifeq ($(SYSTEMCTL_OK),yes)
	systemctl --user daemon-reload
	@echo
	@echo "Unit files installed in $(SYSTEMD_USER_DIR):"
	@ls -1 $(SYSTEMD_USER_DIR)/bitcoind@.service $(SYSTEMD_USER_DIR)/lnd@.service
	@echo
	@echo "Next steps:"
	@echo "  make enable-linger            # so user services start at boot"
	@echo "  make systemd-enable-mainnet   # enable & start mainnet services"
	@echo "  make systemd-enable-testnet   # same for testnet"
else
	@echo "WARNING: systemctl not found on this host."
	@echo "Unit files were copied to $(SYSTEMD_USER_DIR), but they cannot be"
	@echo "loaded without systemd. The other systemd-* targets will be no-ops."
endif

systemd-enable-mainnet:
ifeq ($(SYSTEMCTL_OK),yes)
	@if [ -x $(HOME)/bin/mainnet-bitcoind-start ]; then \
	    echo "Enabling bitcoind@mainnet.service..."; \
	    systemctl --user enable --now bitcoind@mainnet.service; \
	else \
	    echo "Skipping bitcoind@mainnet (no $(HOME)/bin/mainnet-bitcoind-start on this host)"; \
	fi
	@if [ -x $(HOME)/bin/mainnet-lnd-start ]; then \
	    echo "Enabling lnd@mainnet.service..."; \
	    systemctl --user enable --now lnd@mainnet.service; \
	    echo; \
	    echo "lnd is up and waiting for the wallet unlock password."; \
	    echo "Run 'mainnet-lnd-start' in a terminal to enter it."; \
	else \
	    echo "Skipping lnd@mainnet (no $(HOME)/bin/mainnet-lnd-start on this host)"; \
	fi
else
	@echo "systemctl not found; skipping."
endif

systemd-enable-testnet:
ifeq ($(SYSTEMCTL_OK),yes)
	@if [ -x $(HOME)/bin/testnet-bitcoind-start ]; then \
	    echo "Enabling bitcoind@testnet.service..."; \
	    systemctl --user enable --now bitcoind@testnet.service; \
	else \
	    echo "Skipping bitcoind@testnet (no $(HOME)/bin/testnet-bitcoind-start on this host)"; \
	fi
	@if [ -x $(HOME)/bin/testnet-lnd-start ]; then \
	    echo "Enabling lnd@testnet.service..."; \
	    systemctl --user enable --now lnd@testnet.service; \
	    echo; \
	    echo "lnd is up and waiting for the wallet unlock password."; \
	    echo "Run 'testnet-lnd-start' in a terminal to enter it."; \
	else \
	    echo "Skipping lnd@testnet (no $(HOME)/bin/testnet-lnd-start on this host)"; \
	fi
else
	@echo "systemctl not found; skipping."
endif

systemd-disable-mainnet:
ifeq ($(SYSTEMCTL_OK),yes)
	-systemctl --user disable --now lnd@mainnet.service
	-systemctl --user disable --now bitcoind@mainnet.service
else
	@echo "systemctl not found; skipping."
endif

systemd-disable-testnet:
ifeq ($(SYSTEMCTL_OK),yes)
	-systemctl --user disable --now lnd@testnet.service
	-systemctl --user disable --now bitcoind@testnet.service
else
	@echo "systemctl not found; skipping."
endif

systemd-uninstall:
ifeq ($(SYSTEMCTL_OK),yes)
	-systemctl --user disable --now \
	    lnd@mainnet.service lnd@testnet.service \
	    bitcoind@mainnet.service bitcoind@testnet.service 2>/dev/null
endif
	rm -f $(SYSTEMD_USER_DIR)/bitcoind@.service $(SYSTEMD_USER_DIR)/lnd@.service
ifeq ($(SYSTEMCTL_OK),yes)
	-systemctl --user daemon-reload
endif
	@echo "systemd unit files removed."

systemd-status:
ifeq ($(SYSTEMCTL_OK),yes)
	@echo "Linger:"
	@loginctl show-user `whoami` 2>/dev/null | grep -i Linger= || echo "  (loginctl unavailable)"
	@echo
	@echo "Units:"
	@for net in mainnet testnet; do \
	    for svc in bitcoind lnd; do \
	        unit=$$svc@$$net.service; \
	        if [ -f $(SYSTEMD_USER_DIR)/$$svc@.service ]; then \
	            state=`systemctl --user is-active $$unit 2>/dev/null`; \
	            enabled=`systemctl --user is-enabled $$unit 2>/dev/null`; \
	            printf "  %-30s active=%-10s enabled=%s\n" "$$unit" "$$state" "$$enabled"; \
	        fi; \
	    done; \
	done
else
	@echo "systemctl not found on this host."
endif

# Linger lets the user's services start at boot without an active login.
# On modern systemd (>= ~232) polkit usually allows the user to enable it
# on their own account; on stricter setups run as root:
#     sudo make enable-linger LINGER_USER=$(shell whoami)
LINGER_USER ?= $(shell whoami)

enable-linger:
ifeq ($(SYSTEMCTL_OK),yes)
	@if loginctl enable-linger $(LINGER_USER) 2>&1; then \
	    echo "Linger enabled for user '$(LINGER_USER)'."; \
	else \
	    echo; \
	    echo "Could not enable linger for '$(LINGER_USER)' as the current user."; \
	    echo "Try as root:  sudo make enable-linger LINGER_USER=$(LINGER_USER)"; \
	    exit 1; \
	fi
else
	@echo "loginctl/systemctl not found; nothing to do."
endif
