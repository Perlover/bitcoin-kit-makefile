zeromq_install: |\
    required_for_configure_install
	cd external/libzmq && { \
		./autogen.sh && ./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) check && $(MAKE) install && echo "ZeroMQ was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
