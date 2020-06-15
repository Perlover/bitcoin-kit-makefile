cmake-3.17.3.tar.gz:
	wget 'https://github.com/Kitware/CMake/releases/download/v3.17.3/cmake-3.17.3.tar.gz'
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
