zeromq_install: |\
    required_for_configure_install
	git clone 'https://github.com/zeromq/libzmq.git'
	cd libzmq && git checkout v4.2.3 && { \
		./autogen.sh && ./configure --prefix=$$HOME $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "ZeroMQ was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
