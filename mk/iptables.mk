define reloadIPTables
	@ echo -n $$'***************************************************************\n***************************************************************\n\nPress now enter and then press enter too (firewall settings)'; read waiting
	@ { sleep 60 && service iptables stop >/dev/null & } &> /dev/null;\
	service iptables restart; backgroup_pid=$$! ; strstr() { [ "$${1#*$$2*}" = "$$1" ] && return 1; return 0; }; \
	echo -n "To kill sleep ? (Y)es/(N)o [Y] "; read answer; echo $$answer; \
	if strstr $$"yY" "$$answer" || [ "$$answer" = "" ] ; then kill $$backgroup_pid; echo "All is OK" ; else echo 'ATTENTION! Firewall will be flushed!' ; fi
endef

iptables_install: /etc/sysconfig/iptables reload_iptables startup_iptables
	echo $$'If you see this message through ssh - your network works fine ;-)'

/etc/sysconfig/iptables:
	cat iptables.template >$@

reload_iptables :
	$(reloadIPTables)
	@touch $@

startup_iptables :
	chkconfig iptables reset
	service iptables start
	@touch $@

