golang_pre_install: |\
    required_for_configure_install\
    binutils_install\
    golang_bash_profile_install
	cd $(HOME) && git clone -b release-branch.go1.4 'https://go.googlesource.com/go' go1.4 && cd go1.4/src && ./make.bash
	@touch $@

golang_install: |\
    golang_pre_install
	cd $(HOME) && git clone $(HOME)/go1.4 go1.10.2 && cd go1.10.2 && git checkout go1.10.2 && cd src && ulimit -u 4096 && ./all.bash
	@touch $@

$(HOME)/go:
	mkdir -p $(HOME)/go

# ~/.bash_profile patch...
$(HOME)/.golang_envs: golang_envs.sh
	cp -f $< $@

golang_bash_profile_install: |\
    $(HOME)/go\
    $(HOME)/.golang_envs
	echo $$'\n. $(HOME)/.golang_envs' >> $(HOME)/.bash_profile
	@touch $@
