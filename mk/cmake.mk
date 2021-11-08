cmake-3.17.3.tar.gz:
	$(WGET) 'https://github.com/Kitware/CMake/releases/download/v3.17.3/cmake-3.17.3.tar.gz'
	echo 'd47f23a9781b68014e77717f8e291bb7  cmake-3.17.3.tar.gz'|md5sum --check - || \
		{ \
			mv cmake-3.17.3.tar.gz cmake-3.17.3.bad.tar.gz &&\
			echo "Bad cmake md5 sum"; false;\
		}

cmake_install: |\
    required_for_configure_install\
    binutils_install\
    cmake-3.17.3.tar.gz
	tar xzf cmake-3.17.3.tar.gz
	cd cmake-3.17.3 && { \
		./bootstrap --parallel=4 --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) && $(MAKE) install && echo "The cmake was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

make-4.3.tar.gz:
	$(WGET) 'http://ftp.gnu.org/gnu/make/$@' &&\
	echo 'e05fdde47c5f7ca45cb697e973894ff4f5d79e13b750ed57d7b66d8defc78e19  $@'|sha256sum --check - || { echo "Bad checksum"; false; }


gmake_install: |\
    required_for_configure_install\
    make-4.3.tar.gz
	tar xzf make-4.3.tar.gz
	cd make-4.3 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) && $(MAKE) install && echo "The gmake was installed - OK" && ln -s $(BASE_INSTALL_DIR)/bin/make $(BASE_INSTALL_DIR)/bin/gmake; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
