golang_pre_install: |\
    required_for_configure_install\
    binutils_install\
    $(HOME)/.golang_envs
	cd $(BASE_INSTALL_DIR) && git clone -b release-branch.go1.4 'https://go.googlesource.com/go' go1.4 && cd go1.4/src && ./make.bash
	@touch $@

golang_install: |\
    golang_pre_install
	cd $(BASE_INSTALL_DIR) && git clone $(BASE_INSTALL_DIR)/go1.4 go1.10.2 && cd go1.10.2 && git checkout go1.10.2 && cd src && ulimit -u 4096 && ./all.bash
	@touch $@

$(BASE_INSTALL_DIR)/go:
	mkdir -p $(BASE_INSTALL_DIR)/go

# ~/.bash_profile patch...
$(HOME)/.golang_envs: golang_envs.sh | $(BASE_INSTALL_DIR)/go
	cp -f $< $@
	echo $$'\n. $(HOME)/.golang_envs' >> $(PROFILE_FILE)

