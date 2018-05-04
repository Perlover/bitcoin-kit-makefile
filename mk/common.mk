# ~/.bash_profile patch...
$(HOME)/.bitcoin_envs: bitcoin_envs.sh
	cp -f bitcoin_envs.sh $@

bash_profile_install: | $(HOME)/.bitcoin_envs
	echo $$'\n. $(HOME)/.bitcoin_envs' >> $(HOME)/.bash_profile
	touch $@

git_submodule_install:
	git submodule update --init --recursive

required_for_configure_install: \
    bash_profile_install\
    autotools_install\
    autoconf_install\
    gcc_install\
    pkg-config_install
	touch $@
