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

$(CREDENTIALS_DIR)/lncli-web-passwords.txt: |\
    $(CREDENTIALS_DIR)
	@umask 077 && echo $$'URL: https://$(LISTEN_IP_ADDRESS):8280/\n\nAdmin auth:\nUser: admin\nPassword: $(call GENERATE_PASSWORD,16)\n\nLimited user auth:\nUser: limit\nPassword: $(call GENERATE_PASSWORD,16)' >$@

build/lnd/lncli-web/start.sh: $(CREDENTIALS_DIR)/lncli-web-passwords.txt configs/lncli-web/start.sh | build/lnd/lncli-web
	cp -f configs/lncli-web/start.sh $@ &&\
	LNCLI_WEB_ADMIN_PASS=`awk '/User: admin/{getline; print}' $(CREDENTIALS_DIR)/lncli-web-passwords.txt|sed -e 's#Password: ##'` && \
	LNCLI_WEB_LIMIT_PASS=`awk '/User: limit/{getline; print}' $(CREDENTIALS_DIR)/lncli-web-passwords.txt|sed -e 's#Password: ##'` && \
	sed -ri \
	-e 's#\$$\$$LISTEN_IP_ADDRESS\$$\$$#$(LISTEN_IP_ADDRESS)#' \
	-e 's#\$$\$$LNCLI_WEB_ADMIN_PASS\$$\$$#'$$LNCLI_WEB_ADMIN_PASS'#' \
	-e 's#\$$\$$LNCLI_WEB_LIMIT_PASS\$$\$$#'$$LNCLI_WEB_LIMIT_PASS'#' \
	$@

$(HOME)/opt/lncli-web/start.sh: build/lnd/lncli-web/start.sh
	cp $< $@ && chmod 700 $@
