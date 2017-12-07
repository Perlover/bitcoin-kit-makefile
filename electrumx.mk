electrumx_related_pips_install: | python3_install
	pip3 install aiohttp cchardet aiodns pylru plyvel x11_hash
	@touch $@
