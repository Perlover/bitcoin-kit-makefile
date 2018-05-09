lnd_install: |\
    golang_install
	go get -d github.com/lightningnetwork/lnd &&\
	cd $$GOPATH/src/github.com/lightningnetwork/lnd &&\
	$(MAKE) && $(MAKE) install
	@touch $@

btcd_install: |\
    lnd_install
	cd $$GOPATH/src/github.com/lightningnetwork/lnd &&\
	make btcd
	@touch $@
