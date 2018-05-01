Makefile for local-user compiling Bitcoin Core UASF/SegWit patched daemon
=========================================================================

License
-------

This Makefile is released under the terms of the MIT license. See COPYING for
more information or see https://opensource.org/licenses/MIT.

What is this?
-------------

This is my Makefile for building from sources the Bitcoin Core node (v0.16.0 but without wallet feature!) with compiling & building
of many prerequisites from sources under local user environment (not root). This
compiling and installing doesn't affect to Unix system because all binaries and
libraries installed to $HOME directory (for example to home of 'bitcoin' user).

The motivation to do it was because the CentOS 6.* has many old packages for the
Bitcoin Core compiling. These packages are: libtools, pkg-config, autotools, gcc
compiler and so on... You will not be able to build the Bitcoin Core from
sources without hardcore f*cking...

This makefile makes this f*cking for you! ;-)

How to install the Bitcoin Core v0.16.0 version from sources:
--------------------------------------------------------------

1.  First, you need to do by hands the prepare process:

    For CentOS 6.*

    $ sudo yum -y install git make coreutils screen db4 db4-devel db4-utils

    For Ubuntu/Mint/Debian Linux:

    $ sudo apt install build-essential zlibc zlib1g zlib1g-dev libleveldb-dev

    And then next (and for a rest OSes may be):

    $ sudo adduser bitcoin

2.  To login under 'bitcoin' by following ways:

    # screen -S bitcoin-core
    # su -l bitcoin

    OR

    ssh bitcoin@your-host.com
    $ screen -S bitcoin-core

    And to do the next:

    $ git clone https://github.com/Perlover/bitcoin-core-makefile.git
    $ cd bitcoin-core-makefile
    $ git checkout master
    $ make bitcoin-core_install |& tee my_make_output.txt

    wait, wait, wait...

    You can logout from 'screen' by 'Ctrl-A' -> 'd' and login to again by:

    # screen -r bitcoin-core

    OR (if you logged through ssh under 'bitcoin' user)

    $ screen -r bitcoin-core

3.  If you will see the last line as "The bitcoin-core was installed - OK" - everything was done! :)

4.  You can start bitcoin daemon as:

    bitcoind -daemon

    OR

    make start   - start through this makefile
    make stop    - stop through this makefile
    make restart - restart through this makefile

    This daemon will be located in ~bitcoin/bin folder. Your .bash_profile will be patched

5.  ATTENTION! If your OS has firewall rules - DON'T FORGET TO OPEN the 8333 TCP PORT

	This Makefile has helpers:

    a)
	If your OS doesn't have firewall rules but you want to have you can (if
	eth0 is WAN interface):
	From root from current repositary directory to do:

	# make iptables_install

	It will install my default suggested iptable rules for CentOS (but
	without bitcoin TCP port) For bitcoin rules to do next step:

    b)
	To install addition line for iptable rules (to my based example) to do by root:

	# make bitcoin_iptables_install

	Please ATTENTION! Both make targets requires some actions from root user:
	twice pressing of ENTER (to check internet activity after firewall
	applying and if it's not - an auto resetting to all)

How to update to v0.16.0 already previous installed one (DEPRECATED)
---------------------------------------------------------------------

If you already have installed the v0.14.*-uasfsegwit0.3 version (previous
version of this make file) you can easy upgrade to v0.15.1 version

1.  To login under 'bitcoin' by following ways:

    # screen -S bitcoin-core
    # su -l bitcoin

    OR

    ssh bitcoin@your-host.com
    $ screen -S bitcoin-core

    And to do the next:

    $ cd bitcoin-core-makefile
    $ git pull https://github.com/Perlover/bitcoin-core-makefile.git
    $ make bitcoin-core_install |& tee my_make_output.txt

    wait, wait, wait...

    You can logout from 'screen' by 'Ctrl-A' -> 'd' and login to again by:

    # screen -r bitcoin-core

    OR (if you logged through ssh under 'bitcoin' user)

    $ screen -r bitcoin-core

2. If you will see the last line as "The bitcoin-core was installed - OK" - everything was done! :)

3. Only stop & start new daemon:
    make restart


P.S. I think this bitcoin's folder can be packed by any archivators (tar/zip)
and unpacked in any same-platform machine for moving bitcoin core node

Have a nice day ;-)

// Perlover
