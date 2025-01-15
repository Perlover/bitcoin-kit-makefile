Python-3.9.9.tgz:
	$(WGET) 'https://www.python.org/ftp/python/3.9.9/Python-3.9.9.tgz'
	echo 'a2da2a456c078db131734ff62de10ed5  Python-3.9.9.tgz'|md5sum --check - || \
		{ \
			mv Python-3.9.9.tgz Python-3.9.9.bad.tgz &&\
			echo "Bad python3 md5 sum"; false;\
		}

python39_install: |\
    required_for_configure_install\
    openssl_install\
    libevent_install\
    zlib_install\
    zeromq_install\
    Python-3.9.9.tgz
	tar xzf Python-3.9.9.tgz
	cd Python-3.9.9 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "The python3 was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
