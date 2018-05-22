# ~/.bash_profile of .profile patch...
$(HOME)/.bitcoin_envs: bitcoin_envs.sh
	cp -f $< $@
	if [ "x`grep '$(HOME)/.bitcoin_envs' $(PROFILE_FILE)`" = "x" ]; then echo $$'\n. $(HOME)/.bitcoin_envs' >> $(PROFILE_FILE); fi

# ~/.bash_profile of .profile patch...
$(HOME)/.bitcoin_aliases: configs/aliases.sh
	cp -f $< $@
	if [ "x`grep '$(HOME)/.bitcoin_aliases' $(BASHRC_FILE)`" = "x" ]; then echo $$'\n. $(HOME)/.bitcoin_aliases' >> $(BASHRC_FILE); fi

git_submodule_install: .gitmodules
	git submodule update --init --recursive
	@touch $@

# For copying of config files
# $(call COPY_FILE,FROM_WHERE_DIR,TO_WHERE_DIR,UMASK)
define COPY_FILE

MAKE_DIRS += $(1)

$(1)/% : | $(1)
	umask $(2) && cp -f $$< $$@

endef

$(eval $(call COPY_FILE,$(HOME)/bin,077))

required_for_configure_install: |\
    $(HOME)/.bitcoin_envs\
    autotools_install\
    autoconf_install\
    gcc_install\
    pkg-config_install
	@touch $@

clean:
	rm -rf build


GENERATE_PASSWORD = $(shell cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $(1) | head -n 1)
