binutils-2.30.tar.gz:
	gpg --keyserver keyserver.ubuntu.com --recv-key DD9E3C4F
	wget 'https://ftp.gnu.org/gnu/binutils/$@' && wget 'https://ftp.gnu.org/gnu/binutils/$@.sig' &&\
	gpg $@.sig || { echo "Bad sign of $@"; false; }

binutils_install: |\
    required_for_configure_install\
    binutils-2.30.tar.gz
	tar xzf binutils-2.30.tar.gz
	cd binutils-2.30 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "The bintuils was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
