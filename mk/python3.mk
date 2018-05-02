Python-3.6.3.tgz:
	wget 'https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tgz'
	echo 'e9180c69ed9a878a4a8a3ab221e32fa9  Python-3.6.3.tgz'|md5sum --check - || \
		{ \
			mv Python-3.6.3.tgz Python-3.6.3.bad.tgz &&\
			echo "Bad automake md5 sum"; false;\
		}

python3_install: |\
    required_for_configure_install\
    Python-3.6.3.tgz
	tar xzf Python-3.6.3.tgz
	cd Python-3.6.3 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make test && make install && echo "The python3 was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
