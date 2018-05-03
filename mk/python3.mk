Python-3.6.5.tgz:
	wget 'https://www.python.org/ftp/python/3.6.5/Python-3.6.5.tgz'
	echo 'ab25d24b1f8cc4990ade979f6dc37883  Python-3.6.5.tgz'|md5sum --check - || \
		{ \
			mv Python-3.6.5.tgz Python-3.6.5.bad.tgz &&\
			echo "Bad python3 md5 sum"; false;\
		}

python3_install: |\
    required_for_configure_install\
    zlib_install\
    Python-3.6.5.tgz
	tar xzf Python-3.6.5.tgz
	cd Python-3.6.5 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make test && make install && echo "The python3 was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
