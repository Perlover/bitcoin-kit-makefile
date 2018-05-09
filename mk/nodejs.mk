node-v10.0.0.tar.gz:
	gpg --keyserver pool.sks-keyservers.net --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D
	wget 'https://nodejs.org/dist/v10.0.0/$@' && wget -O $@-SHASUMS256.txt.asc 'https://nodejs.org/dist/v10.0.0/SHASUMS256.txt.asc' &&\
	grep $@ $@-SHASUMS256.txt.asc | sha256sum -c - || { echo "Bad sign of $@"; false; }

# LANG=C ./configure... for correct version of assembler
nodejs_pre_install: |\
    required_for_configure_install\
    binutils_install\
    python2_install\
    node-v10.0.0.tar.gz
	tar xzf node-v10.0.0.tar.gz
	cd node-v10.0.0 && { \
		LANG=C ./configure --prefix=$$HOME $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "The node.js was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

nodejs_install: |\
    nodejs_pre_install\
    nodejs_global_in_home
	@touch $@

nodejs_global_in_home:
	-mkdir $$HOME/.npm-global
	npm config set prefix '~/.npm-global'
	@touch $@
