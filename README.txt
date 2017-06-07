Makefile for local-user compiling Bitcoin Core UASF/SegWit patched daemon
=========================================================================

License
-------

This Makefile is released under the terms of the MIT license. See COPYING for
more information or see https://opensource.org/licenses/MIT.

What is this?
-------------

This is my Makefile for building of Bitcoin Core node v0.14.1 UASF/SegWit patch
from sources with compiling & building of many prerequisites from sources too
under local user environment (not root).

The motivation to do it was because the CentOS 6.* has many old packages for the
Bitcoin Core compiling. These packages are: libtools, pkg-config, autotools, gcc
compiler and so on... You will not be able to build from sources the Bitcoin
Core without hardcore...

This makefile has this the hardcore stuff for you!

How install
-----------

1.  First, you need to do by hands the prepare process:

    For CentOS 6.*

    # yum -y install git make coreutils

    And then next (and for a rest OSes may be):

    # adduser bitcoin

2.  To login under 'bitcoin' user and to do the next:

    $ git clone https://github.com/Perlover/bitcoin-uasf-makefile.git
    $ cd bitcoin-uasf-makefile
    $ make bitcoin-uasf_install |& tee my_make_output.txt

    wait, wait, wait...

3.  If you will see the last line as "The bitcoin-uasf was installed - OK" - everything was done! :)

4.  You can start bitcoin daemon as:
    bitcoind -daemon

    This daemon will be located in ~bitcoin/bin folder. Your .bash_profile will be patched

5.  ATTENTION! If your OS has firewall rules - DON'T FORGET TO OPEN 8333 TCP PORT

	This Makefile has helpers:

    a)
	If your OS doesn't have firewall rules but you want to have you can (if
	eth0 is WAN interface):
	From root from current repositary directory to do:

	# make iptables_install

	It will install my default suggested iptable rules for CentOS (but
	without bitcoin TCP port) For bitcoin rules to do next step:

    b)
	To install addition line for iptable rules (to my vased example) to do from root:

	# make bitcoin_iptables_install

	Please ATTENTION! Both make targets to be needed actions from user:
	twice pressing of ENTER

Have a nice day ;-)

// Perlover
