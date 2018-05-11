# ~/.bash_profile patch...
$(HOME)/.bitcoin_envs: bitcoin_envs.sh
	cp -f $< $@

bash_profile_install: | $(HOME)/.bitcoin_envs
	echo $$'\n. $(HOME)/.bitcoin_envs' >> $(HOME)/.bash_profile
	@touch $@

git_submodule_install: .gitmodules
	git submodule update --init --recursive
	@touch $@

# To make here directories
$(MAKE_DIRS) :
	mkdir -p $@

# For copying of config files
# $(call COPY_FILE,FROM_WHERE_DIR,TO_WHERE_DIR,UMASK)
define COPY_FILE
$(2)/% : | $(2)
	umask $(3) && cp -f $(1)/$$(subst $$|,,$$@) $$@
endef

required_for_configure_install: |\
    bash_profile_install\
    autotools_install\
    autoconf_install\
    gcc_install\
    pkg-config_install
	@touch $@
