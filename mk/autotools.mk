# autoconf...
autoconf-2.69.tar.gz: |\
    bash_profile_install
	wget 'http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz'
	echo '82d05e03b93e45f5a39b828dc9c6c29b  autoconf-2.69.tar.gz'|md5sum --check - || \
		{ \
			mv autoconf-2.69.tar.gz autoconf-2.69.bad.tar.gz &&\
			echo "Bad autoconf md5 sum"; false;\
		}

autoconf_install: |\
    bash_profile_install\
    autoconf-2.69.tar.gz
	tar xzf autoconf-2.69.tar.gz
	cd autoconf-2.69 && { \
		./configure --prefix=$$HOME $(CONFIGURE_VARS) && $(MAKE_COMPILE) && make install && echo "Autoconf was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

autotools_install: |\
    autoconf_install\
    automake_install\
    libtool_install
	@touch $@

# automake
automake-1.15.tar.gz:
	wget 'http://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz'
	echo '716946a105ca228ab545fc37a70df3a3  automake-1.15.tar.gz'|md5sum --check - || \
		{ \
			mv automake-1.15.tar.gz automake-1.15.bad.tar.gz &&\
			echo "Bad automake md5 sum"; false;\
		}


automake_install: |\
    bash_profile_install\
    autoconf_install \
    automake-1.15.tar.gz
	tar xzf automake-1.15.tar.gz
	cd automake-1.15 && { \
		PERL=/usr/bin/perl ./configure --prefix=$$HOME $(CONFIGURE_VARS) && make && make install && echo "The automake was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# libtool
libtool-2.4.6.tar.gz:
	wget 'ftp://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz'
	echo 'addf44b646ddb4e3919805aa88fa7c5e  libtool-2.4.6.tar.gz'|md5sum --check - || \
		{ \
			mv libtool-2.4.6.tar.gz libtool-2.4.6.bad.tar.gz &&\
			echo "Bad libtool md5 sum"; false;\
		}

libtool_install: |\
    bash_profile_install\
    libtool-2.4.6.tar.gz
	tar xzf libtool-2.4.6.tar.gz
	cd libtool-2.4.6 && { \
		./configure --prefix=$$HOME $(CONFIGURE_VARS) && $(MAKE_COMPILE) && make install && echo "Libtool was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
