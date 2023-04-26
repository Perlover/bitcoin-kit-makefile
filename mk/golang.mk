# https://lore.kernel.org/buildroot/CA+h8R2rtcynkCBsz=_9yANOEguyPCOcQDj8_ns+cv8RS8+8t9A@mail.gmail.com/T/
# New 1.20.3 requires 3-stage process :(

GOLANG_VER_STAGE_1 := 1.4
GOLANG_VER_STAGE_2 := 1.19.5
GOLANG_VER_STAGE_3 := $(GOLANG_VER)

GOLANG_TARGET_STAGE_2 := $(BASE_INSTALL_DIR)/go$(GOLANG_VER_STAGE_2)/bin/go

golang_pre_install_$(GOLANG_VER_STAGE_1): |\
    required_for_configure_install\
    binutils_install\
    new_git_install\
    $(HOME)/.golang_envs
	-rm -rf $(BASE_INSTALL_DIR)/go$(GOLANG_VER_STAGE_1)
	cd $(BASE_INSTALL_DIR) && git clone -b release-branch.go$(GOLANG_VER_STAGE_1) 'https://go.googlesource.com/go' go$(GOLANG_VER_STAGE_1) && cd go$(GOLANG_VER_STAGE_1)/src && ./make.bash
	@touch $@

$(GOLANG_TARGET_STAGE_2): | golang_pre_install_$(GOLANG_VER_STAGE_1)
	cd $(BASE_INSTALL_DIR)/go$(GOLANG_VER_STAGE_1) && git fetch origin
	-rm -rf $(BASE_INSTALL_DIR)/go$(GOLANG_VER_STAGE_2)
	cd $(BASE_INSTALL_DIR) && git clone --local $(BASE_INSTALL_DIR)/go$(GOLANG_VER_STAGE_1) go$(GOLANG_VER_STAGE_2) && cd go$(GOLANG_VER_STAGE_2) && git checkout go$(GOLANG_VER_STAGE_2) && cd src && ulimit -u `ulimit -H -u` && GOROOT_BOOTSTRAP=$(BASE_INSTALL_DIR)/go$(GOLANG_VER_STAGE_1) ./make.bash

$(CURRENT_GOLANG_TARGET): | $(GOLANG_TARGET_STAGE_2)
	cd $(BASE_INSTALL_DIR)/go$(GOLANG_VER_STAGE_1) && git fetch origin
	-rm -rf $(BASE_INSTALL_DIR)/go$(GOLANG_VER)
	cd $(BASE_INSTALL_DIR) && git clone --local $(BASE_INSTALL_DIR)/go$(GOLANG_VER_STAGE_1) go$(GOLANG_VER) && cd go$(GOLANG_VER) && git checkout go$(GOLANG_VER) && cd src && ulimit -u `ulimit -H -u` && GOROOT_BOOTSTRAP=$(BASE_INSTALL_DIR)/go$(GOLANG_VER_STAGE_2) ./make.bash

golang_envs-$(GOLANG_VER).sh: golang_envs.sh
	cp -f $< $@
	sed -ri -e 's#\$$\$$GOLANG_VER\$$\$$#$(GOLANG_VER)#g' $@
	sed -ri -e 's#\$$\$$GOLANG_VER_STAGE_2\$$\$$#$(GOLANG_VER_STAGE_2)#g' $@
	mkdir -p $(BASE_INSTALL_DIR)/go

# ~/.bash_profile patch...
$(HOME)/.golang_envs: golang_envs-$(GOLANG_VER).sh
	cp -f $< $@
	# This is a fix for multiple duplication of rows from previous updates
	grep -v '. $(HOME)/.golang_envs' $(PROFILE_FILE) >$(PROFILE_FILE).$$$$.~ &&\
	echo $$'\n. $(HOME)/.golang_envs' >> $(PROFILE_FILE).$$$$.~ &&\
	cat $(PROFILE_FILE).$$$$.~ >$(PROFILE_FILE) && rm -f $(PROFILE_FILE).$$$$.~
