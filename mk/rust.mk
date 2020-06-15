rust_install: |\
    required_for_configure_install\
    binutils_install\
    cmake_install\
    python3_install\
    new_git_install\
    new_curl_install\
    openssl_install
	cd external/rust && { \
		cp config.toml.example config.toml && \
		sed -r -i 's/#extended = false/extended = true/' config.toml && \
		sed -r -i 's%#prefix = "/usr/local"%prefix = "$(BASE_INSTALL_DIR)"%' config.toml && \
		sed -r -i 's%#sysconfdir = "/etc"%sysconfdir = "etc"%' config.toml && \
		./x.py build && ./x.py install && echo "The rust was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
