binutils-2.37.tar.gz:
	gpg --keyserver keyserver.ubuntu.com --recv-key DD9E3C4F
	$(WGET) 'https://ftp.gnu.org/gnu/binutils/$@' && $(WGET) 'https://ftp.gnu.org/gnu/binutils/$@.sig' &&\
	gpg $@.sig || { echo "Bad sign of $@"; false; }

ifeq ($(BINUTILS_MIN),FAIL)
binutils_install: |\
    required_for_configure_install\
    binutils-2.37.tar.gz
	tar xzf binutils-2.30.tar.gz
	cd binutils-2.30 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "The bintuils was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
else
binutils_install: |\
    required_for_configure_install
	@touch $@
endif
