golang_pre_install: |\
    required_for_configure_install\
    binutils_install\
    new_git_install\
    $(HOME)/.golang_envs
	cd $(BASE_INSTALL_DIR) && git clone -b release-branch.go1.4 'https://go.googlesource.com/go' go1.4 && cd go1.4/src && ./make.bash
	@touch $@

golang_envs-$(GOLANG_VER).sh: golang_envs.sh
	cp -f $< $@ &&\
	sed -ri \
	-e 's#\$$\$$GOLANG_VER\$$\$$#$(GOLANG_VER)#g' $@
	[ -d $(BASE_INSTALL_DIR)/go ] && mv $(BASE_INSTALL_DIR)/go $(BASE_INSTALL_DIR)/go.old-$$(date +%Y-%m-%d-%H:%M)
	mkdir -p $(BASE_INSTALL_DIR)/go

# ~/.bash_profile patch...
$(HOME)/.golang_envs: golang_envs-$(GOLANG_VER).sh
	cp -f $< $@
	# This is a fix for multiple duplication of rows from previous updates
	grep -v '. $(HOME)/.golang_envs' $(PROFILE_FILE) >$(PROFILE_FILE).$$$$.~ &&\
	echo $$'\n. $(HOME)/.golang_envs' >> $(PROFILE_FILE).$$$$.~ &&\
	cat $(PROFILE_FILE).$$$$.~ >$(PROFILE_FILE) && rm -f $(PROFILE_FILE).$$$$.~

$(CURRENT_GOLANG_TARGET): | golang_pre_install
	cd $(BASE_INSTALL_DIR)/go1.4 && git fetch origin
	cd $(BASE_INSTALL_DIR) && git clone $(BASE_INSTALL_DIR)/go1.4 go$(GOLANG_VER) && cd go$(GOLANG_VER) && git checkout go$(GOLANG_VER) && cd src && ulimit -u `ulimit -H -u` && ./make.bash

golang_fresh_dep_install: | $(CURRENT_GOLANG_TARGET)
	go get -d -u github.com/golang/dep
	cd $$(go env GOPATH)/src/github.com/golang/dep &&\
	DEP_LATEST=$$(git describe --abbrev=0 --tags) &&\
	git checkout $$DEP_LATEST &&\
	go install -ldflags="-X main.version=$$DEP_LATEST" ./cmd/dep &&\
	git checkout master
	@touch $@
