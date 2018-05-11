# It's targets for development rsync for testing
rsync_main_repo:
	git ls-files|rsync -dlptgoDvz --files-from=- . $(BITCOIN_TOOLS_RSYNC_SERVER_AND_PATH)
	RETCODE=$$?; echo $$RETCODE;\
	if [ $$RETCODE -eq 0 -o $$RETCODE -eq 23 ]; then true; else false;  fi

rsync_submodules:
	git submodule --quiet foreach --recursive 'git ls-files|''awk '\''{print "'\''$$toplevel/$$path'\''/"$$1}'\' | rsync -dlptgoDvz --files-from=- / $(BITCOIN_TOOLS_RSYNC_SERVER_AND_PATH)
	RETCODE=$$?; echo $$RETCODE;\
	if [ $$RETCODE -eq 0 -o $$RETCODE -eq 23 ]; then true; else false;  fi

rsync: rsync_main_repo rsync_submodules
	git ls-files|rsync -dlptgoDvz --files-from=- . $(BITCOIN_TOOLS_RSYNC_SERVER_AND_PATH)
	RETCODE=$$?; echo $$RETCODE;\
	if [ $$RETCODE -eq 0 -o $$RETCODE -eq 23 ]; then true; else false;  fi

.PHONY: rsync rsync_main_repo rsync_submodules
