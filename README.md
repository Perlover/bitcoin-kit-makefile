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

This makefile was written for the CentOS 6.x because this OS very conservative
for new libraries and tools. There are many dependencies which should have new
versions (gcc, autotools, libtools, pkg-config, gcc, boost, binutils, python 2.x,
python 3.x, nodeJS, Golang and etc etc etc...). But you can use this makefile
packet for any *nix i think.

[bitcoin-core]: https://github.com/bitcoin/bitcoin "Bitcoin Core full-node"
[lnd]:          https://github.com/lightningnetwork/lnd "Lightning node from Lightning Labs"
[electrumx]:    https://github.com/kyuupichan/electrumx "Alternative Electrum server"

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
    sudo apt install git build-essential screen gettext pkg-config
    
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

5.  You can start bitcoin &amp; lnd daemons in one of two ways:

    * **via systemd** - if your OS has systemd and you installed the
      per-user unit files (see #9 below). This is the recommended way on
      any modern Linux, because then the daemons also come up
      automatically after a reboot.
    * **via the wrapper scripts** `[mainnet|testnet]-*-[start|stop]` - the
      original way. It is the only way on hosts without systemd (e.g. old
      CentOS 6), and it keeps working everywhere.

    Note that `[mainnet|testnet]-lnd-start` is needed in **both** cases: it
    is not only a launcher but also the wallet-unlock helper. `lnd` always
    comes up locked and waits for the wallet password, and there is no way
    to type that password from a systemd unit. When `lnd` is already
    running (started by systemd, or by an earlier run of the script), the
    script detects the running daemon and goes straight to `lncli unlock`.

    1.  **With systemd units installed** (see #9):

        ```
        systemctl --user start bitcoind@mainnet.service
        # ... wait some seconds (minutes at the very first start) ...
        systemctl --user start lnd@mainnet.service
        # lnd is up but locked - enter the wallet password:
        mainnet-lnd-start
        ```

        Stopping:

        ```
        systemctl --user stop lnd@mainnet.service
        systemctl --user stop bitcoind@mainnet.service
        ```

        `mainnet-lnd-stop` also works here - it detects an active
        `lnd@mainnet.service` and delegates to `systemctl --user stop`, so
        the unit is left cleanly inactive. `mainnet-bitcoind-stop` does
        **not** have that detection, so for a systemd-managed `bitcoind`
        prefer `systemctl --user stop bitcoind@mainnet.service`.

        After a reboot nothing has to be started by hand at all (with
        `make enable-linger` done) - only the unlock step remains:

        ```
        mainnet-lnd-start
        ```

    2.  **Without systemd** (or when you did not install the units):

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

        4.  Or you can start/stop both daemons at once:

            ```
            mainnet-lightning-start
            mainnet-lightning-stop
            ```

            But first time run after installation i recommend to run as described in #5.2.1

    Do not mix the two ways for the same daemon: if the systemd unit is
    installed and enabled, start `lnd` with `systemctl`, not with
    `mainnet-lnd-start` on a stopped unit - otherwise you get an `lnd`
    that systemd does not manage (and, after a reboot or a
    `systemctl --user start`, a risk of two daemons fighting for the
    wallet DB lock and the gRPC port).

6.  If you want to change password of wallet you can do it by following commands:

    ```
    mainnet-lnd-stop
    mainnet-lnd-start changepassword
    ```

    You must to enter the old password and the new one. The seed password is kept old (it cannot be changed).

    With the systemd units installed, restart the daemon through systemd
    and use the script only for the password dialog:

    ```
    systemctl --user restart lnd@mainnet.service
    mainnet-lnd-start changepassword
    ```

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

    The debug binary is started by the script, not by the unit, so on a
    systemd host stop the unit first and start it again afterwards:

    ```
    systemctl --user stop lnd@mainnet.service
    mainnet-lnd-debug-start
    # ... work with `l abandonchannel ...` ...
    mainnet-lnd-stop
    systemctl --user start lnd@mainnet.service
    mainnet-lnd-start
    ```

8.  After setup you have easy bash aliases and functions:

    `l`   - the mainnet lncli command

    `lt`  - the testnet lncli command

    `loc` - connect &amp; open channel to mainnet node of format `pubkey@host:port` as:

            loc <pubkey@host:port> <amount_satoshies>

    `ltoc` - same as `loc` only for testnet network


9.  **OPTIONAL** Auto-start at boot via per-user systemd:

    If your OS has systemd (most modern Linux distributions), you can
    install per-user unit files so `bitcoind` and `lnd` start automatically
    after a reboot:

    ```
    make systemd-install
    make enable-linger
    make systemd-enable-mainnet
    # and/or:
    make systemd-enable-testnet
    ```

    `enable-linger` makes the user's services start at boot without an
    active login. On modern systemd polkit usually allows this without
    root; otherwise run `sudo make enable-linger LINGER_USER=bitcoin`.

    On hosts without systemd (e.g. old CentOS) the `systemd-*` targets
    print a warning and exit cleanly - they don't fail the build.

    `make systemd-enable-mainnet` only enables those services whose
    `~/bin/<network>-<service>-start` wrappers actually exist on the host,
    so a server that only installed `lnd` (or only `bitcoind`) will not
    get a stale unit.

    After enabling, `lnd` comes up but blocks waiting for the wallet
    unlock password. Run `<network>-lnd-start` in a terminal as usual to
    enter it - the wrapper detects the systemd-managed `lnd` and proceeds
    straight to `lncli unlock`. The same is true after every reboot: the
    daemons start on their own, only the unlock stays manual.

    Other useful targets: `make systemd-status`,
    `make systemd-disable-mainnet`, `make systemd-uninstall`.

    **Day-to-day commands** (replace `mainnet` with `testnet` as needed):

    ```
    systemctl --user start   bitcoind@mainnet.service
    systemctl --user start   lnd@mainnet.service
    mainnet-lnd-start                       # unlock the wallet

    systemctl --user stop    lnd@mainnet.service
    systemctl --user stop    bitcoind@mainnet.service

    systemctl --user restart lnd@mainnet.service
    mainnet-lnd-start                       # unlock again after every restart

    systemctl --user status  lnd@mainnet.service
    make systemd-status                     # both networks at once
    ```

    **Where the logs are.** `lnd@.service` redirects the daemon's
    stdout/stderr into the same append-only log the terminal wrapper has
    always used, so `journalctl` shows only systemd lifecycle events:

    ```
    tail -f ~/.lnd/mainnet-lnd-run.log             # full history, all restarts
    tail -f ~/.lnd/logs/bitcoin/mainnet/lnd.log    # lnd's own rotated log
    journalctl --user -u lnd@mainnet.service       # unit start/stop events only
    tail -f ~/.bitcoin/debug.log                   # bitcoind (mainnet)
    ```

    A clean `lnd` shutdown ends with `LTND: Shutdown complete` in
    `~/.lnd/logs/bitcoin/mainnet/lnd.log` - that is the one-line check that
    the daemon was stopped gracefully and the channel databases were closed
    properly (both units deliberately wait for the daemon to finish
    stopping instead of just asking it to stop).

    **Hosts where you do NOT want bitcoind to auto-start.** `lnd@<net>.service`
    has `Wants=bitcoind@<net>.service`, so starting `lnd` pulls
    `bitcoind` into the start transaction even if `bitcoind` was not
    enabled. On servers where you do not want a local `bitcoind` at all
    (remote `bitcoind`, neutrino, or simply not needed on this host),
    just **disable is not enough** - the `Wants=` would still pull it
    in. Use `mask`:

    ```
    systemctl --user disable --now bitcoind@mainnet.service
    systemctl --user mask        bitcoind@mainnet.service
    ```

    `mask` replaces the unit with a symlink to `/dev/null`, so systemd
    physically cannot start it. `lnd` starts as usual; the journal will
    contain one harmless warning about the masked dependency.

    To undo:

    ```
    systemctl --user unmask        bitcoind@mainnet.service
    systemctl --user enable --now  bitcoind@mainnet.service
    ```

10. **RECOMMENDATION** If your OS has firewall rules - **DON'T FORGET TO OPEN the 8333 TCP PORT**

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

2.  To stop bitcoind and/or LND, for example for mainnet.

    **With the systemd units installed** ([see #9 of the install
    section](#how-to-install-the-bitcoin-core--lnd)):

    ```
    systemctl --user stop lnd@mainnet.service
    systemctl --user stop bitcoind@mainnet.service   # only if you upgrade Bitcoin Core
    ```

    Note the units wait for the daemon to really finish its shutdown, so
    `systemctl stop` returns only when `lnd`/`bitcoind` is actually gone.
    Still, give it a couple of seconds before overwriting the binaries.

    **Without systemd:**

    ```
    mainnet-lnd-stop
    mainnet-bitcoind-stop
    ```

3.  Then, if you want to upgrade Bitcoin Core:

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

4.  After upgrade and before start please logout from terminal and login again. The upgrade process corrects `$PATH` after upgrade of *golang*

5.  **If you use the systemd units** - `git pull` may have brought new
    versions of the unit files (`configs/systemd/*.service`), so reinstall
    them after the upgrade:

    ```
    make systemd-install
    ```

    It re-templates the units into `~/.config/systemd/user/` and runs
    `systemctl --user daemon-reload`. The new unit takes effect at the next
    start of the service, so do this **before** step #7 below. Check
    `CHANGES.txt` - unit changes are listed there.

6.  **ONLY TESTNET!** After upgrade for testnet (if you use testnet network daemon) you may be needed to make reindex in bitcoind [to see details here why](https://bitcoin.stackexchange.com/questions/79662/solving-bitcoin-cores-activatebestchain-failed). You need to make once after upgrade:

    ```
    bitcoind  -conf=$HOME/.bitcoin/bitcoin-testnet.conf -reindex
    ```

    When reindexing will be finished (you can check in logs by `tail -f ~/.bitcoin/testnet3/debug.log`) you can stop and start again the *bitcoind* (optionally)

7.  To start bitcoind and/or LND again, for example for mainnet.

    **With the systemd units installed:**

    ```
    systemctl --user start bitcoind@mainnet.service
    sleep 5
    systemctl --user start lnd@mainnet.service
    sleep 5
    mainnet-lnd-start                 # unlock the wallet
    ```

    (`mainnet-lnd-start` here does not launch a second daemon - it finds
    the systemd-managed `lnd` and only asks for the wallet password.)

    **Without systemd:**

    ```
    mainnet-bitcoind-start
    mainnet-lnd-start
    ```

### A short LND-only upgrade (systemd host)

The most frequent case is bumping just LND on a host where `bitcoind`
keeps running and does not need to be touched at all:

```
cd ~/bitcoin-kit-makefile
git checkout master
git pull

systemctl --user stop lnd@mainnet.service && sleep 3 && make prepare-lnd-update && make lnd-update-mainnet

systemctl --user start lnd@mainnet.service
sleep 5
mainnet-lnd-start
```

Add `LND_BACKUP=1` before `make lnd-update-mainnet` if you want the
pre-upgrade tar archive of `~/.lnd` (recommended for a node with open
channels). For testnet use `lnd@testnet.service`,
`make lnd-update-testnet` and `testnet-lnd-start`.

Two things this short form leaves out on purpose, check `CHANGES.txt`
after `git pull` to see whether you need them:

* `make systemd-install` - if the update changed the unit files;
* logout/login of the shell - if the update also bumped *golang* (`$PATH`
  changes), see step #4 above.

Have a nice day ;-)

*Perlover*
