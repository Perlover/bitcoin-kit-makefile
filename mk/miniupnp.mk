MAKE_DIRS += ./upnp

miniupnpc_for_make_install: |\
    ./upnp
	cd ./upnp && cwd=`pwd` && cd .. && \
	cd external/miniupnp/miniupnpc && { \
		INSTALLPREFIX=$$cwd $(MAKE) install && make clean && echo "miniUPnP client FOR THIS MAKE was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

UPNPC_RUN := LD_LIBRARY_PATH=./upnp/lib ./upnp/bin/upnpc

miniupnpc_install: |\
    required_for_configure_install
	cd external/miniupnp/miniupnpc && { \
		INSTALLPREFIX=$(BASE_INSTALL_DIR) $(MAKE) install && make clean && echo "miniUPnP Client was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
