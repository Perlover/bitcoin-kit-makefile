electrumx_related_pips_install: | python3_install
	pip3 install aiohttp cchardet aiodns pylru plyvel x11_hash
	@touch $@

electrumx_install:
	git clone 'https://github.com/kyuupichan/electrumx.git'
	cd electrumx && git checkout 1.2.1 && { \
		mkdir $(HOME)/.electrumx; \
		python3 setup.py install && echo "ElectrumX was installed - OK"; \
	} &> make_out.txt && tail make_out.txt
	@touch $@
