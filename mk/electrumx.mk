electrumx_related_pips_install: | python3_install
	pip3 install aiohttp cchardet aiodns pylru plyvel x11_hash
	@touch $@

MAKE_DIRS += $(HOME)/.electrumx

electrumx_install: | electrumx_related_pips_install $(HOME)/.electrumx
	git clone 'https://github.com/kyuupichan/electrumx.git'
	cd electrumx && git checkout 1.4.3 && { \
		python3 setup.py install && echo "ElectrumX was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

MAKE_DIRS += build/electrumx/ssl

electrumx_certs_install: |\
    openssl_install\
    build/electrumx/ssl\
    $(HOME)/.electrumx/ssl
	cd build/electrumx/ssl && \
	openssl ecparam -genkey -name prime256v1 -out tls.key && \
	openssl req -new -sha256 -key tls.key -out csr.csr -subj '/CN=localhost/O=electrumx' && \
	openssl req -x509 -sha256 -days 36500 -key tls.key -in csr.csr -out tls.cert && \
	rm csr.csr && \
	cp -f * $(HOME)/.electrumx/ssl
	@touch $@

MAKE_DIRS += build/electrumx

build/electrumx/env.sh: \
    $(NETWORK_MK_FILE)\
    configs/electrumx/env.sh\
    |\
    build/electrumx
