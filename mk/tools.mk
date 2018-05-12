pkg-config_install: |\
    $(HOME)/.bitcoin_envs\
    autotools_install
	git clone git://anongit.freedesktop.org/pkg-config
	cd pkg-config && { \
		git checkout pkg-config-0.29.2 &&\
		./autogen.sh --with-internal-glib --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) && $(MAKE) install && echo "pkg-config was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# m4
m4-1.4.18.tar.gz:
	wget 'http://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.gz'
	echo 'a077779db287adf4e12a035029002d28  m4-1.4.18.tar.gz'|md5sum --check - || \
		{ \
			mv m4-1.4.18.tar.gz m4-1.4.18.bad.tar.gz &&\
			echo "Bad m4 md5 sum"; false;\
		}


m4_install: |\
    $(HOME)/.bitcoin_envs\
    m4-1.4.18.tar.gz
	tar xzf m4-1.4.18.tar.gz
	cd m4-1.4.18 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "The m4 was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
