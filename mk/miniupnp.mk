miniupnpc_install: |\
    required_for_configure_install
	cd external/miniupnp/miniupnpc && { \
		INSTALLPREFIX=$(BASE_INSTALL_DIR) $(MAKE) install && echo "miniUPnP Client was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
