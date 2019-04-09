inotify_install: |\
    required_for_configure_install
	cd external/inotify-tools && { \
		./configure --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) && $(MAKE) install && echo "inotify-tools was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
