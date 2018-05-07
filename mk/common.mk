# ~/.bash_profile patch...
$(HOME)/.bitcoin_envs: bitcoin_envs.sh
	cp -f bitcoin_envs.sh $@

bash_profile_install: | $(HOME)/.bitcoin_envs
	echo $$'\n. $(HOME)/.bitcoin_envs' >> $(HOME)/.bashrc
	@touch $@

git_submodule_install: .gitmodules
	git submodule update --init --recursive
	@touch $@

required_for_configure_install: |\
    bash_profile_install\
    autotools_install\
    autoconf_install\
    gcc_install\
    pkg-config_install
	@touch $@
