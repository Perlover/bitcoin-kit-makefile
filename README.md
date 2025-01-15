# Makefile for compiling Full Lightning Node

The local-user compiling if *Bitcoin Core*, *Lightning* in CentOS 6.x and other *nix.

## License

This Makefile is released under the terms of the MIT license. See COPYING for
more information or see https://opensource.org/licenses/MIT.

## What is this?

### Brief:

**`make i-want-lightning`** and you will have compiled bitcoind with lnd daemons with preconfigured files.

**`make set-up-lightning-mainnet`** and you will be ready to run immediately the
**lnd** and **bitcoind** daemons in mainnet.

**`make set-up-lightning-testnet`** and you will be ready to run immediately the
**lnd** and **bitcoind** daemons in testnet.

**You can use together mainnet &amp; testnet** services in single host.
**UPnP is supported** auto by scripts from this repositary!

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
[lnd]:          https://github.com/lightningnetwork/lnd "Lightning node from Lightning Labs"
[electrumx]:    https://github.com/kyuupichan/electrumx "Alternative Electrum server"
[lncli-web]:    https://github.com/mably/lncli-web

This compiling and installing doesn't affect to Unix system because all binaries
and libraries installed to $HOME directory (for example to home of 'bitcoin'
user).

The **install process is maximally secure** for installation. Wherever possible
**MD5/SHA256** checksums or **GPG signatures** are checked before compilation and
installing. The *git sources* are secured by commit ID checkout.

If you have old this repositary installed in your system you can easy upgrade up to fresh Bitcoin Core &amp; LND. [Please to see below upgrade section](#upgrade-lnd-bitcoin-core)

## How to install the Bitcoin Core + LND:

1.  First, you need to do by hands the prepare process:

    For CentOS 6.* (there are old autotoolsm, gcc and etc... So we will install only this minimal packages)

    ```
    sudo yum -y install git make coreutils screen gettext
    ```

    For Ubuntu/Mint/Debian Linux:

    ```
    sudo apt install git build-essential screen gettext
    
    ```

    For Raspberry Pi (Raspbian OS) you need to install some requires
    (because a compiling from sources will take many more time and memory resources):

    ```
    sudo apt install gcc build-essential screen git m4 automake autoconf libtool pkg-config binutils
    # And you need to increase a swap up to ~1Gb
    # (else you will have 'no virtual memory' error) by following commands:
    sudo dd if=/dev/zero of=/swapfile bs=1M count=1000
    sudo mkswap /swapfile
    sudo swapon /swapfile
    # optional: to add line '/swapfile none swap sw 0 0' to /etc/fstab (sudo vi /etc/fstab)
    ```

    And then next (and for a rest OSes may be):

    ```
    sudo adduser bitcoin
    ```

2.  To login under *bitcoin* user by following ways:

    ```
    screen -S bitcoin-kit
    sudo su -l bitcoin
    ```

    OR

    ```
    ssh bitcoin@your-host.com
    screen -S bitcoin-kit
    ```

    And to do the next:

    ```
    git clone --recursive https://github.com/Perlover/bitcoin-kit-makefile.git
    cd bitcoin-kit-makefile
    make i-want-lightning |& tee -a my_make_output.txt
    ```

    wait, wait, wait...

    You can logout from 'screen' by 'Ctrl-A' -> 'd' and login to again by:

    ```
    screen -r bitcoin-kit
    ```

    OR (if you logged through ssh under 'bitcoin' user)

    ```
    screen -r bitcoin-kit
    ```

3.  After you need to create lnd's wallet:

    ```
    make set-up-lightning-mainnet
    ```

    OR

    ```
    make set-up-lightning-testnet
    ```

4.  To logout from terminal/shell and login again. After you will have all environment variables for normal work.

    And you will have scripts in `$PATH` for starting/stopping:

    * `[mainnet|testnet]-lightning-[start|stop]`
    * `[mainnet|testnet]-bitcoind-[start|stop]`
    * `[mainnet|testnet]-lnd-[start|stop]`
    * `[mainnet|testnet]-lncli-web-[start|stop]`

5.  You can start bitcoin &amp; lnd daemons as:

    1.  First time after installation:

        ```
        mainnet-bitcoind-start
        # ... wait some minutes ...
        mainnet-lnd-start
        ```

    2.  Next time starting:

        ```
        mainnet-bitcoind-start
        # ... wait some seconds...
        mainnet-lnd-start
        ```

    3.  Stopping:

        ```
        mainnet-lnd-stop
        mainnet-bitcoind-stop
        ```

    4.  If you want to use `lncli-web` you can start same way:

        ```
        mainnet-lightning-start
        ```

        Stop daemon:

        ```
        mainnet-lightning-stop
        ```
        
        But first time run after installation i recommend to run as described in #5.1

        You can work with node same way: `https://your_listen_ip_address:[8280|8281]/`
        The passwords can be found in ~/credentials directory, 8280 - for mainnet, 8281 - for testnet

6.  If you want to change password of wallet you can do it by following commands:

    ```
    mainnet-lnd-stop
    mainnet-lnd-start changepassword
    ```

    You must to enter the old password and the new one. The seed password is kept old (it cannot be changed).

7.  For the `abandonchannel` command of lnd you need the debug lnd binary. You can start the LND in debug mode by same way:

    ```
    mainnet-lnd-stop
    mainnet-lnd-debug-start
    ```

    Then you can run lncli with `abandonchannel` command:

    ```
    l abandonchannel ...
    ```

    When you finished we recommend to return to non-debug mode:

    ```
    mainnet-lnd-stop
    mainnet-lnd-start
    ```

8.  After setup you have easy bash aliases and functions:

    `l`   - the mainnet lncli command

    `lt`  - the testnet lncli command

    `loc` - connect &amp; open channel to mainnet node of format `pubkey@host:port` as:

            loc <pubkey@host:port> <amount_satoshies>

    `ltoc` - same as `loc` only for testnet network


9.  **RECOMMENDATION** If your OS has firewall rules - **DON'T FORGET TO OPEN the 8333 TCP PORT**

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

## Upgrade LND &amp; Bitcoin Core

If you have installed old LND and/or Bitcoin Core by this repository this makefile gives easy targets to update. The LND update makes TAR archive before upgrading by request (to see `LND_BACKUP` below). For upgrade:

1.  To checkout to master branch and to pull fresh repositary:

    ```
    cd ~/bitcoin-kit-makefile
    git checkout master
    git pull
    ```

3.  To stop bitcoind and/or LND, for example for mainnet:

    ```
    mainnet-lnd-stop
    mainnet-bitcoind-stop
    ```

4.  Then, if you want to upgrade Bitcoin Core:

    ```
    make prepare-bitcoin-core-update
    make bitcoin-core-update
    ```
   
    If upgrade LND for mainnet:

    ```
    make prepare-lnd-update
    # without a LND backup
    make lnd-update-mainnet
    # OR for backup of LND before:
    LND_BACKUP=1 make lnd-update-mainnet
    ```
    Or upgrade LND for testnet:

    ```
    make prepare-lnd-update
    make lnd-update-testnet
    ```

    Or to upgrade both:

    ```
    make prepare-bitcoin-core-update prepare-lnd-update
    LND_BACKUP=1 make bitcoin-core-update lnd-update-mainnet
    ```
    
    In home directory you will see lnd tar archive before upgrade (if you used `LND_BACKUP` as above):

    ```
    lnd-backup-UUUUUUU-YYYY-MM-DD.tgz
    ```

    Where: UUUUUU - seconds from computer epoch (1970-01-01), YYYY - a year, MM - a month and DD - a day.

    Upgrade corrects LND config files and move *macaroon* files to standard for v0.5.* lnd directories.

5.  After upgrade and before start please logout from terminal and login again. The upgrade process corrects `$PATH` after upgrade of *golang*

6.  **ONLY TESTNET!** After upgrade for testnet (if you use testnet network daemon) you may be needed to make reindex in bitcoind [to see details here why](https://bitcoin.stackexchange.com/questions/79662/solving-bitcoin-cores-activatebestchain-failed). You need to make once after upgrade:

    ```
    bitcoind  -conf=$HOME/.bitcoin/bitcoin-testnet.conf -reindex
    ```

    When reindexing will be finished (you can check in logs by `tail -f ~/.bitcoin/testnet3/debug.log`) you can stop and start again the *bitcoind* (optionally)

7.  To start bitcoind and/or LND again, for example for mainnet:

    ```
    mainnet-bitcoind-start
    mainnet-lnd-start
    ```

Have a nice day ;-)

*Perlover*
