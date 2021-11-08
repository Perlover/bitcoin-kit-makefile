Python-2.7.15.tgz:
	$(WGET) 'https://www.python.org/ftp/python/2.7.15/Python-2.7.15.tgz'
	echo '045fb3440219a1f6923fefdabde63342  Python-2.7.15.tgz'|md5sum --check - || \
		{ \
			mv Python-2.7.15.tgz Python-2.7.15.bad.tgz &&\
			echo "Bad python2 md5 sum"; false;\
		}

python2_install: |\
    required_for_configure_install\
    zlib_install\
    Python-2.7.15.tgz
	tar xzf Python-2.7.15.tgz
	cd Python-2.7.15 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "The python2 was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
