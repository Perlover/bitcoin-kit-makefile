# The ElectrumX now uses the BitcoinSV as main blockchain (v0.15.0) but the Bitcoin was moved to "altcoin" branch (It's about killing a project in one day.)
# So i decided to stopped to support it and will add other Electrum server to this repo
# P.S. I added this server some years ago before Segwit fork...
electrumx_related_pips_install: | python39_install
	pip3 install aiohttp cchardet aiodns pylru plyvel x11_hash
	@touch $@

MAKE_DIRS += $(HOME)/.electrumx

electrumx_install: | electrumx_related_pips_install $(HOME)/.electrumx
	git clone 'https://github.com/kyuupichan/electrumx.git'
	cd electrumx && git checkout 1.15.0 && { \
		python3 setup.py install && echo "ElectrumX was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

MAKE_DIRS += build/electrumx
MAKE_DIRS += build/electrumx/ssl
MAKE_DIRS += $(HOME)/.electrumx/ssl

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

build/electrumx/env.sh: \
    $(NETWORK_MK_FILE)\
    configs/electrumx/env.sh\
    |\
    build/electrumx
