gcc_install: |\
    bash_profile_install\
    autotools_install\
    gmp_install\
    mpfr_install\
    mpc_install\
    isl_install\
    gcc-7.1.0.tar.gz
	tar xvzf gcc-7.1.0.tar.gz
	cd gcc-7.1.0 && { \
		./configure --prefix=$$HOME --disable-multilib && $(MAKE_COMPILE) && make install && echo "The gcc was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	ln -s $$HOME/bin/gcc $$HOME/bin/cc
	@touch $@

# gcc
gcc-7.1.0.tar.gz:
	wget ftp://ftp.gnu.org/gnu/gcc/gcc-7.1.0/gcc-7.1.0.tar.gz
	echo 'b3d733ad75fdaf88009b52c0cce0ad4c  gcc-7.1.0.tar.gz'|md5sum --check - || \
		{ \
			mv gcc-7.1.0.tar.gz gcc-7.1.0.bad.tar.gz &&\
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

gmp_install: |\
    bash_profile_install\
    autotools_install\
    gmp-6.1.2.tar.bz2
	bzip2 -cd gmp-6.1.2.tar.bz2|tar xvf -
	cd gmp-6.1.2 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "The gmp was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# mpfr
mpfr-4.0.1.tar.bz2:
	wget http://www.mpfr.org/mpfr-current/mpfr-4.0.1.tar.bz2
	echo '8c21d8ac7460493b2b9f3ef3cc610454  mpfr-4.0.1.tar.bz2'|md5sum --check - || \
		{ \
			mv mpfr-4.0.1.tar.bz2 mpfr-4.0.1.bad.tar.bz2 &&\
			echo "Bad mpfr md5 sum"; false;\
		}

mpfr_install: |\
    bash_profile_install\
    gmp_install\
    autotools_install\
    mpfr-4.0.1.tar.bz2
	bzip2 -cd mpfr-4.0.1.tar.bz2|tar xvf -
	cd mpfr-4.0.1 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "The mpfr was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# mpc
mpc-1.1.0.tar.gz:
	wget ftp://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz
	echo '4125404e41e482ec68282a2e687f6c73  mpc-1.1.0.tar.gz'|md5sum --check - || \
		{ \
			mv mpc-1.1.0.tar.gz mpc-1.1.0.bad.tar.gz &&\
			echo "Bad mpc md5 sum"; false;\
		}

mpc_install: |\
    bash_profile_install\
    gmp_install\
    mpfr_install\
    autotools_install\
    mpc-1.1.0.tar.gz
	tar xzf mpc-1.1.0.tar.gz
	cd mpc-1.1.0 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "The mpc was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

# mpc
isl-0.18.tar.gz:
	wget http://isl.gforge.inria.fr/isl-0.18.tar.gz
	echo '076c69f81067f2f5b908c099f445a338  isl-0.18.tar.gz'|md5sum --check - || \
		{ \
			mv isl-0.18.tar.gz isl-0.18.bad.tar.gz &&\
			echo "Bad isl md5 sum"; false;\
		}

isl_install: |\
    bash_profile_install\
    autotools_install\
    isl-0.18.tar.gz
	tar xzf isl-0.18.tar.gz
	cd isl-0.18 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "The isl was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@

