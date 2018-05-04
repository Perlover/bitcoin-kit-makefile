node-v10.0.0.tar.gz:
	gpg --keyserver pool.sks-keyservers.net --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D
	wget 'https://nodejs.org/dist/v10.0.0/$@' && wget -O $@-SHASUMS256.txt.asc 'https://nodejs.org/dist/v10.0.0/SHASUMS256.txt.asc' &&\
	grep $@ $@-SHASUMS256.txt | sha256sum -c - || { echo "Bad sign of $@"; false; }

# LANG=C ./configure... for correct version of assembler
nodejs_install: |\
    required_for_configure_install\
    binutils_install\
    python2_install\
    node-v10.0.0.tar.gz
	tar xzf node-v10.0.0.tar.gz
	cd node-v10.0.0 && { \
		LANG=C ./configure --prefix=$HOME && $(MAKE_COMPILE) && make install && echo "The node.js was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
