lightning_install: |\
    git_submodule_install\
    python2_install\
    python3_install\
    sqlite3_install\
    binutils_install
	cd external/c-lightning && { \
		$(MAKE_COMPILE) prefix=$$HOME install && echo "The c-lightning was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
