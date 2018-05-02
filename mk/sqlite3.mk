sqlite-autoconf-3230100.tar.gz:
	wget 'https://www.sqlite.org/2018/sqlite-autoconf-3230100.tar.gz' &&\
	echo '0edbfd75ececb95e8e6448d6ff33df82774c9646  sqlite-autoconf-3230100.tar.gz'|sha1sum --check - || { echo "Bad checksum"; false; }

sqlite3_install: |\
    required_for_configure_install\
    sqlite-autoconf-3230100.tar.gz
	tar xzf sqlite-autoconf-3230100.tar.gz
	cd sqlite-autoconf-3230100 && { \
		./configure --prefix=$$HOME && $(MAKE_COMPILE) && make install && echo "The sqlite3 was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
