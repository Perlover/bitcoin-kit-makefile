# It's targets for development rsync for testing
rsync:
	git ls-files|rsync -avz --files-from=- . $(BITCOIN_TOOLS_RSYNC_SERVER_AND_PATH)
	RETCODE=$$$$?; echo $$$$RETCODE;\
	if [ $$$$RETCODE -eq 0 -o $$$$RETCODE -eq 23 ]; then true; else false;  fi

.PHONY: rsync
