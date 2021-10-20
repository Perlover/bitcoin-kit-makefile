ifeq ($(GCC_MIN),FAIL)
gcc_install: |\
    $(HOME)/.bitcoin_envs\
    autotools_install\
    gmp_install\
    mpfr_install\
    mpc_install\
    isl_install\
    gcc-11.2.0.tar.gz
	tar xvzf gcc-11.2.0.tar.gz
	cd gcc-11.2.0 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) --disable-multilib && $(MAKE_COMPILE) && $(MAKE) install && echo "The gcc was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	ln -s $(BASE_INSTALL_DIR)/bin/gcc $(BASE_INSTALL_DIR)/bin/cc
	@touch $@
else
gcc_install: |\
    $(HOME)/.bitcoin_envs\
    autotools_install\
    gmp_install\
    mpfr_install\
    mpc_install\
    isl_install
	@touch $@
endif

# gcc
gcc-11.2.0.tar.gz:
	wget http://ftp.gnu.org/gnu/gcc/gcc-11.2.0/$@
	echo 'dc6886bd44bb49e2d3d662aed9729278  $@'|md5sum --check - || \
		{ \
			mv $@ $@.bad.tar.gz &&\
			echo "Bad gcc md5 sum"; false;\
		}

# gmp
gmp-6.1.2.tar.bz2:
	wget 'https://gmplib.org/download/gmp/gmp-6.1.2.tar.bz2'
	echo '8ddbb26dc3bd4e2302984debba1406a5  gmp-6.1.2.tar.bz2'|md5sum --check - || \
		{ \
			mv gmp-6.1.2.tar.bz2 gmp-6.1.2.bad.tar.bz2 &&\
			echo "Bad gmp md5 sum"; false;\
		}

ifeq ($(GCC_MIN),FAIL)
gmp_install: |\
    $(HOME)/.bitcoin_envs\
    autotools_install\
    gmp-6.1.2.tar.bz2
	bzip2 -cd gmp-6.1.2.tar.bz2|tar xvf -
	cd gmp-6.1.2 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) check && $(MAKE) install && echo "The gmp was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
else
gmp_install: |\
    $(HOME)/.bitcoin_envs
	@touch $@
endif

# mpfr
mpfr-4.0.2.tar.bz2:
	wget http://www.mpfr.org/mpfr-current/mpfr-4.0.2.tar.bz2
	echo '6d8a8bb46fe09ff44e21cdbf84f5cdac  mpfr-4.0.2.tar.bz2'|md5sum --check - || \
		{ \
			mv mpfr-4.0.2.tar.bz2 mpfr-4.0.2.bad.tar.bz2 &&\
			echo "Bad mpfr md5 sum"; false;\
		}

ifeq ($(GCC_MIN),FAIL)
mpfr_install: |\
    $(HOME)/.bitcoin_envs\
    gmp_install\
    autotools_install\
    mpfr-4.0.2.tar.bz2
	bzip2 -cd mpfr-4.0.2.tar.bz2|tar xvf -
	cd mpfr-4.0.2 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "The mpfr was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
else
mpfr_install: |\
    $(HOME)/.bitcoin_envs
	@touch $@
endif

# mpc
mpc-1.1.0.tar.gz:
	wget ftp://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz
	echo '4125404e41e482ec68282a2e687f6c73  mpc-1.1.0.tar.gz'|md5sum --check - || \
		{ \
			mv mpc-1.1.0.tar.gz mpc-1.1.0.bad.tar.gz &&\
			echo "Bad mpc md5 sum"; false;\
		}

ifeq ($(GCC_MIN),FAIL)
mpc_install: |\
    $(HOME)/.bitcoin_envs\
    gmp_install\
    mpfr_install\
    autotools_install\
    mpc-1.1.0.tar.gz
	tar xzf mpc-1.1.0.tar.gz
	cd mpc-1.1.0 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "The mpc was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
else
mpc_install: |\
    $(HOME)/.bitcoin_envs
	@touch $@
endif

# mpc
isl-0.18.tar.gz:
	wget http://isl.gforge.inria.fr/isl-0.18.tar.gz
	echo '076c69f81067f2f5b908c099f445a338  isl-0.18.tar.gz'|md5sum --check - || \
		{ \
			mv isl-0.18.tar.gz isl-0.18.bad.tar.gz &&\
			echo "Bad isl md5 sum"; false;\
		}

ifeq ($(GCC_MIN),FAIL)
isl_install: |\
    $(HOME)/.bitcoin_envs\
    autotools_install\
    isl-0.18.tar.gz
	tar xzf isl-0.18.tar.gz
	cd isl-0.18 && { \
		./configure --prefix=$(BASE_INSTALL_DIR) $(CONFIGURE_VARS) && $(MAKE_COMPILE) && $(MAKE) install && echo "The isl was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
else
isl_install: |\
    $(HOME)/.bitcoin_envs
	@touch $@
endif
