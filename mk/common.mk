# ~/.bash_profile of .profile patch...
$(HOME)/.bitcoin_envs: bitcoin_envs.sh
	cp -f $< $@
	if [ "x`grep '$(HOME)/.bitcoin_envs' $(PROFILE_FILE)`" = "x" ]; then echo $$'\n. $(HOME)/.bitcoin_envs' >> $(PROFILE_FILE); fi

# ~/.bash_profile of .profile patch...
$(HOME)/.bitcoin_aliases: configs/aliases.sh
	cp -f $< $@
	if [ "x`grep '$(HOME)/.bitcoin_aliases' $(BASHRC_FILE)`" = "x" ]; then echo $$'\n. $(HOME)/.bitcoin_aliases' >> $(BASHRC_FILE); fi

git_submodule_install: .gitmodules
	git submodule deinit -f --all
	git submodule update --init --recursive
	@touch $@

this_repo_update:
	git pull
	git submodule deinit -f --all
	git submodule foreach --recursive 'git reset --hard HEAD && git clean -fdx'
	git submodule sync --recursive
	git submodule update --init --recursive --force
	git clean -fd && git clean -fd

.PHONY: this_repo_update

MAKE_DIRS += $(HOME)/bin

required_for_configure_install: |\
    $(HOME)/.bitcoin_envs\
    autotools_install\
    autoconf_install\
    pkg-config_install
	@touch $@

clean:
	rm -rf build network_*

# One-shot cleanup of a previous lncli-web install. lncli-web was removed from
# this project; this target prunes leftover artifacts under $HOME so old installs
# can be tidied up. Stops any still-running lncli-web first.
.PHONY: purge-lncli-web

purge-lncli-web:
	@for net in mainnet testnet; do \
	    pid_file=$(HOME)/.$$net-lncli-web.pid; \
	    if [ -f $$pid_file ] && kill -0 `cat $$pid_file` 2>/dev/null; then \
	        echo "Stopping running lncli-web ($$net), pid="`cat $$pid_file`; \
	        kill `cat $$pid_file` 2>/dev/null || true; \
	        for i in 1 2 3 4 5; do kill -0 `cat $$pid_file` 2>/dev/null || break; sleep 1; done; \
	        kill -9 `cat $$pid_file` 2>/dev/null || true; \
	    fi; \
	done
	rm -rf $(HOME)/opt/lncli-web
	rm -f $(HOME)/bin/mainnet-lncli-web-start $(HOME)/bin/mainnet-lncli-web-stop \
	      $(HOME)/bin/testnet-lncli-web-start $(HOME)/bin/testnet-lncli-web-stop
	rm -f $(HOME)/.mainnet-lncli-web.pid $(HOME)/.testnet-lncli-web.pid
	rm -f $(CREDENTIALS_DIR)/lncli-web-mainnet-passwords.txt \
	      $(CREDENTIALS_DIR)/lncli-web-testnet-passwords.txt
	@echo "lncli-web artifacts purged from \$$HOME."

GENERATE_PASSWORD = $(shell cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $(1) | head -n 1)
