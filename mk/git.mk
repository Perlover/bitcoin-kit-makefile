new_git_download:
	git clone https://github.com/git/git
	@touch $@

new_git_install: |\
    required_for_configure_install\
    new_curl_install\
    new_git_download
	cd git && $(MAKE) configure && ./configure --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) all && $(MAKE) install
	@touch $@

curl-7.63.0.tar.gz:
	wget 'https://curl.haxx.se/download/curl-7.63.0.tar.gz'
	echo '6121427a7199cd6094fc48c9e31e8992  curl-7.63.0.tar.gz'|md5sum --check - || \
		{ \
			mv curl-7.63.0.tar.gz curl-7.63.0.bad.tar.gz &&\
			echo "Bad curl md5 sum"; false;\
		}

new_curl_install: |\
    required_for_configure_install\
    curl-7.63.0.tar.gz
	tar xzf curl-7.63.0.tar.gz
	cd curl-7.63.0 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) && $(MAKE) install && echo "Curl was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
