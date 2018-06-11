MAKE_DIRS += $(HOME)/opt

$(HOME)/opt/lncli-web: |\
    $(HOME)/opt
	cd $(HOME)/opt && git clone https://github.com/mably/lncli-web.git

lncli-web_install: |\
    nodejs_install\
    openssl_install\
    $(HOME)/opt/lncli-web
	cd $(HOME)/opt/lncli-web && { \
		npm install && echo "lncli-web for lnd was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@


.PHONY: lncli-web-install

lncli-web-install: lncli-web_install
	@echo "The lncli-web was installed!"

.PHONY: lncli-web-update

lncli-web-update: lncli-web_install
	cd $(HOME)/opt/lncli-web && git pull && { \
		npm install && echo "lncli-web for lnd was updated - OK"; \
	} &> make_out.txt && tail make_out.txt
	@echo $$'*****************************************************\n\nThe lncli-web was updated to current commit\n\n' &&\
	echo "To run \`mainnet-lncli-web-stop && mainnet-lncli-web-start\` or \`testnet-lncli-web-stop && testnet-lncli-web-start\`" &&\
	echo $$'\n\n*****************************************************'

MAKE_DIRS += build/lnd/lncli-web

# Lnd uses the P-521 curve for its certificates but NodeJS gRPC module is only compatible with certificates using the P-256 curve
# To make here these keys
lncli-web_lnd_certs_install: |\
    openssl_install\
    build/lnd/lncli-web\
    $(HOME)/opt/lncli-web\
    $(HOME)/.lnd
	cd build/lnd/lncli-web && \
	openssl ecparam -genkey -name prime256v1 -out tls.key && \
	openssl req -new -sha256 -key tls.key -out csr.csr -subj '/CN=localhost/O=lnd' && \
	openssl req -x509 -sha256 -days 36500 -key tls.key -in csr.csr -out tls.cert && \
	rm csr.csr && \
	cp -f * $(HOME)/.lnd && cp -f tls.cert $(HOME)/opt/lncli-web/lnd.cert
	@touch $@

MAKE_DIRS += build/lnd/lncli-web/ssl

# To make tls keys for lncli-web
$(HOME)/opt/lncli-web/ssl: |\
    $(HOME)/opt/lncli-web\
    build/lnd/lncli-web/ssl
	cd build/lnd/lncli-web/ssl && \
	openssl req \
	-x509 \
	-newkey \
	rsa:2048 \
	-keyout key.pem \
	-out cert.pem \
	-days 36500 \
	-nodes \
	-subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" && \
	mkdir -p $@ && mv -f * $@

lncli-web_configs_install: |\
    lncli-web_lnd_certs_install\
    $(HOME)/opt/lncli-web/ssl
	@touch $@

$(CREDENTIALS_DIR)/lncli-web-mainnet-passwords.txt: |\
    $(CREDENTIALS_DIR)
	@umask 077 && echo $$'URL: https://$(BITCOIN_KIT_LOCAL_IP):8280/\n\nAdmin auth:\nUser: admin\nPassword: $(call GENERATE_PASSWORD,16)\n\nLimited user auth:\nUser: limit\nPassword: $(call GENERATE_PASSWORD,16)' >$@

$(CREDENTIALS_DIR)/lncli-web-testnet-passwords.txt: |\
    $(CREDENTIALS_DIR)
	@umask 077 && echo $$'URL: https://$(BITCOIN_KIT_LOCAL_IP):8281/\n\nAdmin auth:\nUser: admin\nPassword: $(call GENERATE_PASSWORD,16)\n\nLimited user auth:\nUser: limit\nPassword: $(call GENERATE_PASSWORD,16)' >$@

MAKE_DIRS += build/bin/lncli-web

build/bin/lncli-web/mainnet-lncli-web-start: \
    $(NETWORK_MK_FILE)\
    $(CREDENTIALS_DIR)/lncli-web-mainnet-passwords.txt\
    configs/bin/lncli-web/mainnet-lncli-web-start\
    |\
    build/bin/lncli-web
	cp -f configs/bin/lncli-web/mainnet-lncli-web-start $@ &&\
	LNCLI_WEB_MAINNET_ADMIN_PASS=`awk '/User: admin/{getline; print}' $(CREDENTIALS_DIR)/lncli-web-mainnet-passwords.txt|sed -e 's#Password: ##'` && \
	LNCLI_WEB_MAINNET_LIMIT_PASS=`awk '/User: limit/{getline; print}' $(CREDENTIALS_DIR)/lncli-web-mainnet-passwords.txt|sed -e 's#Password: ##'` && \
	sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_UPNP_SUPPORT\$$\$$#$(BITCOIN_KIT_UPNP_SUPPORT)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' \
	-e 's#\$$\$$LNCLI_WEB_MAINNET_ADMIN_PASS\$$\$$#'$$LNCLI_WEB_MAINNET_ADMIN_PASS'#g' \
	-e 's#\$$\$$LNCLI_WEB_MAINNET_LIMIT_PASS\$$\$$#'$$LNCLI_WEB_MAINNET_LIMIT_PASS'#g' \
	$@ && \
	chmod 755 $@

build/bin/lncli-web/testnet-lncli-web-start: \
    $(NETWORK_MK_FILE)\
    $(CREDENTIALS_DIR)/lncli-web-testnet-passwords.txt\
    configs/bin/lncli-web/testnet-lncli-web-start\
    |\
    build/bin/lncli-web
	cp -f configs/bin/lncli-web/testnet-lncli-web-start $@ &&\
	LNCLI_WEB_TESTNET_ADMIN_PASS=`awk '/User: admin/{getline; print}' $(CREDENTIALS_DIR)/lncli-web-testnet-passwords.txt|sed -e 's#Password: ##'` && \
	LNCLI_WEB_TESTNET_LIMIT_PASS=`awk '/User: limit/{getline; print}' $(CREDENTIALS_DIR)/lncli-web-testnet-passwords.txt|sed -e 's#Password: ##'` && \
	sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_UPNP_SUPPORT\$$\$$#$(BITCOIN_KIT_UPNP_SUPPORT)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' \
	-e 's#\$$\$$LNCLI_WEB_TESTNET_ADMIN_PASS\$$\$$#'$$LNCLI_WEB_TESTNET_ADMIN_PASS'#g' \
	-e 's#\$$\$$LNCLI_WEB_TESTNET_LIMIT_PASS\$$\$$#'$$LNCLI_WEB_TESTNET_LIMIT_PASS'#g' \
	$@ && \
	chmod 755 $@

build/bin/lncli-web/mainnet-lncli-web-stop: \
    $(NETWORK_MK_FILE)\
    configs/bin/lncli-web/mainnet-lncli-web-stop\
    |\
    build/bin/lncli-web
	cp -f configs/bin/lncli-web/mainnet-lncli-web-stop $@ &&\
	sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_UPNP_SUPPORT\$$\$$#$(BITCOIN_KIT_UPNP_SUPPORT)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' \
	$@ && \
	chmod 755 $@

build/bin/lncli-web/testnet-lncli-web-stop: \
    $(NETWORK_MK_FILE)\
    configs/bin/lncli-web/testnet-lncli-web-stop\
    |\
    build/bin/lncli-web
	cp -f configs/bin/lncli-web/testnet-lncli-web-stop $@ &&\
	sed -ri \
	-e 's#\$$\$$BITCOIN_KIT_UPNP_SUPPORT\$$\$$#$(BITCOIN_KIT_UPNP_SUPPORT)#g' \
	-e 's#\$$\$$BITCOIN_KIT_LOCAL_IP\$$\$$#$(BITCOIN_KIT_LOCAL_IP)#g' \
	$@ && \
	chmod 755 $@

$(HOME)/bin/mainnet-lncli-web-start: build/bin/lncli-web/mainnet-lncli-web-start | miniupnpc_install

$(HOME)/bin/testnet-lncli-web-start: build/bin/lncli-web/testnet-lncli-web-start | miniupnpc_install

$(HOME)/bin/mainnet-lncli-web-stop: build/bin/lncli-web/mainnet-lncli-web-stop | miniupnpc_install

$(HOME)/bin/testnet-lncli-web-stop: build/bin/lncli-web/testnet-lncli-web-stop | miniupnpc_install
