new_git_download:
	git clone https://github.com/git/git
	@touch $@

new_git_install: | new_git_download
	cd git && $(MAKE) configure && ./configure --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) all && $(MAKE) install
	@touch $@
