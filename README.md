# Makefile for compiling Full Lightning Node

The local-user compiling if *Bitcoin Core*, *Lightning* in CentOS 6.x and other *nix.

## License

This Makefile is released under the terms of the MIT license. See COPYING for
more information or see https://opensource.org/licenses/MIT.

## What is this?

### Brief:

`make i-want-lightning` and you will have compiled bitcoind with lnd daemons with preconfigured files.

`make set-up-lightning-mainnet` and you will be ready to run immediately the
**lnd** and **bitcoind** daemons.

### More info:

This is the Makefile for building from sources the software for the Bitcoin:

1. [Bitcoin Core][bitcoin-core]
2. [LND][lnd]
3. [Lncli-Web][lncli-web] (web interface to *lnd*)

This makefile was written for the CentOS 6.x because this OS very conservative
for new libraries and tools. There are many dependencies which should have new
versions (gcc, autotools, libtools, pkg-config, gcc, boost, binutils, python 2.x,
python 3.x, nodeJS, Golang and etc etc etc...). But you can use this makefile
packet for any *nix i think.

[bitcoin-core]: https://github.com/bitcoin/bitcoin "Bitcoin Core full-node"
[c-lightning]:  https://github.com/ElementsProject/lightning "Lightning node from BlockStream"
[lnd]:          https://github.com/lightningnetwork/lnd "Lightning node from Lightning Labs"
[electrumx]:    https://github.com/kyuupichan/electrumx "Alternative Electrum server"
[lncli-web]:    https://github.com/mably/lncli-web

This compiling and installing doesn't affect to Unix system because all binaries
and libraries installed to $HOME directory (for example to home of 'bitcoin'
user).

The **install process is maximally secure** for installation. Wherever possible
**MD5/SHA256** checksums or **GPG signatures** are checked before compilation and
installing. The *git sources* are secured by commit ID checkout.

## How to install the Bitcoin Core v0.16.0 version from sources:

1.  First, you need to do by hands the prepare process:

    For CentOS 6.*

        $ sudo yum -y install git make coreutils screen

    For Ubuntu/Mint/Debian Linux:

        $ sudo apt install build-essential screen

    And then next (and for a rest OSes may be):

        $ sudo adduser bitcoin

2.  To login under *bitcoin* user by following ways:

        # screen -S bitcoin-core
        # su -l bitcoin

    OR

        ssh bitcoin@your-host.com
        $ screen -S bitcoin-core

    And to do the next:

        $ git clone --branch upnp --recursive https://github.com/Perlover/bitcoin-core-makefile.git
        $ cd bitcoin-core-makefile
        $ make i-want-lightning |& tee my_make_output.txt

    wait, wait, wait...

    You can logout from 'screen' by 'Ctrl-A' -> 'd' and login to again by:

        # screen -r bitcoin-core

    OR (if you logged through ssh under 'bitcoin' user)

        $ screen -r bitcoin-core

3.  After you need to create lnd's wallet:

        $ make set-up-lightning-mainnet

    OR

        $ make set-up-lightning-testnet

4.  To logout from terminal/shell and login again. After you will have all environment variables for normal work.

    And you will have alias commands for start:

    * `bitcoind-start`
    * `bitcoind-stop`
    * `lnd-start`
    * `lnd-stop`
    * `lncli-web-start` (the https protocol)
    * `lncli-web-stop`

5.  You can start bitcoin & lnd daemons as:

        bitcoind-start
        lnd-start

    Stop daemon:

        bitcoind-stop
        lnd-stop

    And you can use browser to control and manage lightning node:

        lncli-web-start

    And after this you can to login to *https://your_listen_ip_address:8280/*
    (the passwords can be found in ~/credentials directory).

5.  **ATTENTION!** If your OS has firewall rules - **DON'T FORGET TO OPEN the 8333 TCP PORT**

    This Makefile has helpers:

    **a)** If your OS doesn't have firewall rules but you want to have you can (if
    eth0 is WAN interface):
    From root from current repositary directory to do:

        # make iptables_install

    It will install my default suggested iptable rules for CentOS (but
    without bitcoin TCP port) For bitcoin rules to do next step:

    **b)** To install addition line for iptable rules (to my based example) to do by root:

        # make bitcoin_iptables_install

    Please ATTENTION! Both make targets requires some actions from root user:
    twice pressing of ENTER (to check internet activity after firewall
    applying and if it's not - an auto resetting to all)

Have a nice day ;-)

*Perlover*
