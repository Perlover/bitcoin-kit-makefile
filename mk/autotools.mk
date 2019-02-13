################### autoconf...
autoconf-2.69.tar.gz: |\
    $(HOME)/.bitcoin_envs\
    m4_install
	wget 'http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz'
	echo '82d05e03b93e45f5a39b828dc9c6c29b  autoconf-2.69.tar.gz'|md5sum --check - || \
		{ \
			mv autoconf-2.69.tar.gz autoconf-2.69.bad.tar.gz &&\
			echo "Bad autoconf md5 sum"; false;\
		}

ifeq ($(AUTOCONF_MIN),FAIL)
autoconf_install: |\
    $(HOME)/.bitcoin_envs\
    autoconf-2.69.tar.gz
	tar xzf autoconf-2.69.tar.gz
	cd autoconf-2.69 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "Autoconf was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
else
autoconf_install: |\
    $(HOME)/.bitcoin_envs
	@touch $@
endif

#######################################

autotools_install: |\
    autoconf_install\
    automake_install\
    libtool_install
	@touch $@

######################################

# automake
automake-1.15.tar.gz:
	wget 'http://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz'
	echo '716946a105ca228ab545fc37a70df3a3  automake-1.15.tar.gz'|md5sum --check - || \
		{ \
			mv automake-1.15.tar.gz automake-1.15.bad.tar.gz &&\
			echo "Bad automake md5 sum"; false;\
		}


ifeq ($(AUTOMAKE_MIN),FAIL)
automake_install: |\
    $(HOME)/.bitcoin_envs\
    autoconf_install \
    automake-1.15.tar.gz
	tar xzf automake-1.15.tar.gz
	cd automake-1.15 && { \
		PERL=/usr/bin/perl ./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE) && $(MAKE) install && echo "The automake was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
else
automake_install: |\
    $(HOME)/.bitcoin_envs\
    autoconf_install
	@touch $@
endif

#####################################

# libtool
libtool-2.4.6.tar.gz:
	wget 'ftp://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz'
	echo 'addf44b646ddb4e3919805aa88fa7c5e  libtool-2.4.6.tar.gz'|md5sum --check - || \
		{ \
			mv libtool-2.4.6.tar.gz libtool-2.4.6.bad.tar.gz &&\
			echo "Bad libtool md5 sum"; false;\
		}

ifeq ($(LIBTOOL_MIN),FAIL)
libtool_install: |\
    $(HOME)/.bitcoin_envs\
    libtool-2.4.6.tar.gz
	tar xzf libtool-2.4.6.tar.gz
	cd libtool-2.4.6 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "Libtool was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
else
libtool_install: |\
    $(HOME)/.bitcoin_envs
	@touch $@
endif

####################################

ifeq ($(PKG_CONFIG_MIN),FAIL)
pkg-config_install: |\
    $(HOME)/.bitcoin_envs\
    autotools_install
	cd external/pkg-config && { \
		./autogen.sh --with-internal-glib --prefix=$(BASE_INSTALL_DIR) && $(MAKE_COMPILE) && $(MAKE) install && echo "pkg-config was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
else
pkg-config_install: |\
    $(HOME)/.bitcoin_envs\
    autotools_install
	@touch $@
endif

###################################

# m4
m4-1.4.18.tar.gz:
	wget 'http://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.gz'
	echo 'a077779db287adf4e12a035029002d28  m4-1.4.18.tar.gz'|md5sum --check - || \
		{ \
			mv m4-1.4.18.tar.gz m4-1.4.18.bad.tar.gz &&\
			echo "Bad m4 md5 sum"; false;\
		}


ifeq ($(M4_MIN),FAIL)
m4_install: |\
    $(HOME)/.bitcoin_envs\
    m4-1.4.18.tar.gz
	tar xzf m4-1.4.18.tar.gz
	cd m4-1.4.18 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "The m4 was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
else
m4_install: |\
    $(HOME)/.bitcoin_envs
	@touch $@
endif
