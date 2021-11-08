node-v10.1.0.tar.gz:
	gpg --keyserver pool.sks-keyservers.net --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D
	$(WGET) 'https://nodejs.org/dist/v10.1.0/$@' && $(WGET) -O $@-SHASUMS256.txt.asc 'https://nodejs.org/dist/v10.1.0/SHASUMS256.txt.asc' &&\
	grep $@ $@-SHASUMS256.txt.asc | sha256sum -c - || { echo "Bad sign of $@"; false; }

# LANG=C ./configure... for correct version of assembler
nodejs_pre_install: |\
    required_for_configure_install\
    binutils_install\
    python2_install\
    node-v10.1.0.tar.gz
	tar xzf node-v10.1.0.tar.gz
	cd node-v10.1.0 && { \
		LANG=C ./configure --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) && $(MAKE) install && echo "The node.js was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

nodejs_install: |\
    nodejs_pre_install\
    nodejs_global_in_home_install\
    npm_update
	@touch $@

nodejs_global_in_home_install:
	-mkdir $(HOME)/.npm-global
	npm config set prefix '~/.npm-global'
	@touch $@

npm_update: |\
    nodejs_pre_install\
    nodejs_global_in_home_install
	npm install npm@latest -g
	@touch $@
