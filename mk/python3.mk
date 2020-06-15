Python-3.8.3.tgz:
	wget 'https://www.python.org/ftp/python/3.8.3/Python-3.8.3.tgz'
	echo 'a7c10a2ac9d62de75a0ca5204e2e7d07  Python-3.8.3.tgz'|md5sum --check - || \
		{ \
			mv Python-3.8.3.tgz Python-3.8.3.bad.tgz &&\
			echo "Bad python3 md5 sum"; false;\
		}

python3_install: |\
    required_for_configure_install\
    openssl_install\
    libevent_install\
    zlib_install\
    zeromq_install\
    Python-3.8.3.tgz
	tar xzf Python-3.8.3.tgz
	cd Python-3.8.3 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "The python3 was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
