# ~/.bash_profile patch...
$(HOME)/.bitcoin_envs: bitcoin_envs.sh
	cp -f bitcoin_envs.sh $@

bash_profile_install: | $(HOME)/.bitcoin_envs
	echo $$'\n. $(HOME)/.bitcoin_envs' >> $(HOME)/.bash_profile
	touch $@
