golang_pre_install:
	cd $$HOME && git clone -b release-branch.go1.4 'https://go.googlesource.com/go' go1.4 && cd go1.4/src && ./make.bash
	@touch $@

golang_install: |\
    required_for_configure_install\
    golang_pre_install\
    binutils_install
	cd $$HOME && git clone $$HOME/go1.4 go1.10.2 && cd go1.10.2 && git checkout go1.10.2 && cd src && ulimit -u 4096 && ./all.bash
	@touch $@
