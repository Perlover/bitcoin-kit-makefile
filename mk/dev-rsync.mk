# It's targets for development rsync for testing
rsync_libzmq:
	cd external/libzmq && git ls-files|rsync -avz --files-from=- . $(BITCOIN_TOOLS_RSYNC_SERVER_AND_PATH)/external/libzmq/
	RETCODE=$$?; echo $$RETCODE;\
	if [ $$RETCODE -eq 0 -o $$RETCODE -eq 23 ]; then true; else false;  fi

rsync_clightning:
	cd external/c-lightning && git ls-files|rsync -avz --files-from=- . $(BITCOIN_TOOLS_RSYNC_SERVER_AND_PATH)/external/c-lightning/
	RETCODE=$$?; echo $$RETCODE;\
	if [ $$RETCODE -eq 0 -o $$RETCODE -eq 23 ]; then true; else false;  fi

rsync: rsync_libzmq rsync_clightning
	git ls-files|rsync -avz --files-from=- . $(BITCOIN_TOOLS_RSYNC_SERVER_AND_PATH)
	RETCODE=$$?; echo $$RETCODE;\
	if [ $$RETCODE -eq 0 -o $$RETCODE -eq 23 ]; then true; else false;  fi

.PHONY: rsync rsync_libzmq rsync_clightning
