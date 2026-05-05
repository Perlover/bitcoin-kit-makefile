# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A pure-Make build system that compiles Bitcoin Core, LND, and all of their toolchain dependencies (gcc, binutils, autotools, OpenSSL, Boost, libevent, libzmq, miniupnp, Python 3, Node.js, Go, Rust) **from source into `$HOME`** under an unprivileged user account. Originally aimed at CentOS 6, where the system toolchain is too old; works on any *nix where you can't or don't want to install global packages. There is **no application code in this repo** — it is purely a Makefile + helper shell scripts + config templates that orchestrate building upstream projects (which are pulled in as git submodules under `external/` or cloned at build time).

The end product is a set of `~/bin/{mainnet,testnet}-{bitcoind,lnd,lightning}-{start,stop,debug-start}` wrapper scripts plus `~/.bitcoin_envs`, `~/.golang_envs`, and `~/.bitcoin_aliases` sourced from the user's shell profile.

## Common commands

All targets are run from the repo root as the unprivileged build user (typically `bitcoin`), **not root**. Network/IP detection on first run is interactive — run inside `screen`.

```sh
# Full first-time install (1–2 hours; compiles gcc, Go in 4 stages, OpenSSL, Boost, bitcoind, lnd, …)
make i-want-lightning |& tee -a my_make_output.txt

# Create wallets and install ~/bin/* wrapper scripts (interactive, requires running lnd briefly)
make set-up-lightning-mainnet
make set-up-lightning-testnet

# Upgrade flow (run after `git pull`)
make prepare-bitcoin-core-update prepare-lnd-update
LND_BACKUP=1 make bitcoin-core-update lnd-update-mainnet     # LND_BACKUP=1 → ~/lnd-backup-<epoch>-YYYY-MM-DD.tgz
make lnd-update-testnet

# Single-component installs / updates
make bitcoin-core-install
make lnd-install

# One-shot cleanup of a previous lncli-web install (deprecated, removed from the project)
make purge-lncli-web

# Optional firewall helpers (run as root)
sudo make iptables_install              # installs iptables.template
sudo make bitcoin_iptables_install      # adds dport 8333 ACCEPT rule

# Misc
make help        # cat Usage_Brief.txt
make help-more   # cat Usage_More.txt
make clean       # rm -rf build network_*
make test-versions
```

There are no tests, no linter, no CI in this repo. The only "test" is `test_ver.sh` (a min-version comparator used by the Makefile itself).

## Pinning upstream versions

Two variables in the top-level `Makefile` drive what gets built:

- `LND_ACTUAL_COMMIT` — exact LND git commit (currently a v0.20.1-beta commit). Bumping LND = edit this line and update `CHANGES.txt`.
- `GOLANG_VER` — Go version. **Must also be reflected in `golang_envs.sh`'s `$PATH`** (see comment in `Makefile`).

Bitcoin Core, OpenSSL, Boost, libevent, libzmq, miniupnp, pkg-config, inotify-tools, and Rust are pinned via the git submodules in `external/` (see `.gitmodules`); to bump them, `cd` into the submodule, check out the desired ref, commit the new submodule SHA in this repo.

## Architecture

### Module layout

`Makefile` (top-level) defines toolchain-comparison macros, network-config caching, and shell/profile detection, then `include`s every `mk/*.mk` module. Each module owns one component and stays self-contained — `bitcoind.mk`, `lnd.mk`, `gcc.mk`, `binutils.mk`, `autotools.mk`, `golang.mk`, `python2.mk`, `python3.mk`, `nodejs.mk`, `rust.mk`, `cmake.mk`, `git.mk`, `libs.mk`, `tor.mk`, `electrumx.mk`, `zeromq.mk`, `miniupnp.mk`, `inotify.mk`, `iptables.mk`, `sqlite3.mk`, `rsync.mk`. Two glue modules orchestrate the rest: `i-want-lightning.mk` is the top-level "do everything" target; `common.mk` owns the shell-profile patching (`~/.bitcoin_envs`, `~/.bitcoin_aliases`), submodule init, `clean`, and the `purge-lncli-web` one-shot cleanup of legacy installs. `finally.mk` is included last so it can hook end-of-build steps.

### Network config caching (subtle)

The Makefile detects local + public IP addresses and UPnP availability **once per network/host fingerprint**. The fingerprint is `md5(uname -a + non-loopback inet addresses)` → `HASH_NETWORK_CONFIG`. On a fresh host, `define_all_ipaddresses.sh` is invoked (interactive, asks the user to confirm IPs and tests UPnP via `upnp/bin/upnpc`) and writes:

- `network_<hash>.mk` — included by the top-level Makefile, defines `BITCOIN_KIT_LOCAL_IP`, `BITCOIN_KIT_UPNP_SUPPORT`, `BITCOIN_KIT_*_EXTERNALIP_*`, etc.
- `network_<hash>.sh` — sourced by build wrapper scripts.

Once cached, subsequent `make` runs reuse the file. `make clean` deletes them. The detection is **skipped** for the `rsync`, `clean`, `help`, `help-more`, and empty-goal targets (see the `ifneq($(MAKECMDGOALS), …)` ladder in `Makefile`).

### Config-template pipeline (`configs/` → `build/` → `$HOME`)

Every user-facing artifact (daemon configs in `~/.bitcoin/*.conf`, `~/.lnd/*.conf`, and start/stop wrappers in `~/bin/*`) is produced by a **three-stage copy with `sed` substitution**:

1. **Source template:** `configs/bitcoind/bitcoin-mainnet.conf`, `configs/lnd/bitcoind/lnd-mainnet.conf`, `configs/bin/lnd/mainnet-lnd-start`, etc. Templates use `$$VARNAME$$` placeholders (literal double-dollar) — e.g. `$$BITCOIN_KIT_LOCAL_IP$$`, `$$HOME$$`, `$$RPC_PASS$$`, `$$BITCOIN_KIT_UPNP_SUPPORT$$`.
2. **Build copy:** `build/bitcoind/bitcoin-mainnet.conf`, `build/bin/lnd/mainnet-lnd-start`, etc. — the `sed -ri -e 's#\$$\$$NAME\$$\$$#…#g'` rules in the corresponding `mk/*.mk` substitute placeholders with values from `$(NETWORK_MK_FILE)` and from `$(CREDENTIALS_DIR)/bitcoind-lnd-{mainnet,testnet}-auth.txt` (generated by Bitcoin Core's `share/rpcauth/rpcauth.py`, see `mk/bitcoind.mk`).
3. **Install copy:** `~/.bitcoin/*.conf`, `~/.lnd/*.conf`, `~/bin/*-start`, `~/bin/*-stop`. For configs, if the target already exists it is **not overwritten** — instead `<name>.new.conf` is written next to it so the user can diff/merge manually.

When editing templates, always edit `configs/...` (the source). Anything under `build/` is regenerated.

### Go bootstrap (4-stage)

`mk/golang.mk` builds Go via four chained source builds because modern Go can't be bootstrapped directly from a system C compiler: `1.4` (C-bootstrapped) → `1.19.5` → `1.20.3` → `$(GOLANG_VER)`. Each stage uses the previous as `GOROOT_BOOTSTRAP`. Don't shortcut this — earlier stages exist because of historical Go bootstrap-toolchain rules. When bumping `GOLANG_VER`, also update `golang_envs.sh`.

### Build environment isolation

`SHELL := /bin/bash --login` at the top of `Makefile` is **load-bearing** — every recipe line runs under a login shell so `~/.bash_profile` (which sources `~/.bitcoin_envs` and `~/.golang_envs`) is read first. That's how `$LD_LIBRARY_PATH`, `$PKG_CONFIG_PATH`, `$GOPATH`, and the prepended `~/bin` reach `configure`, `make`, `go build`. `bitcoin_envs.sh` and `golang_envs.sh` are the canonical environment definitions; the Makefile also derives `LDFLAGS`/`CPPFLAGS` for `configure` from `$LD_LIBRARY_PATH`/`$CPATH`.

`required_for_configure_install` is the prerequisite stamp every component depends on; it pulls in `~/.bitcoin_envs` patching plus autotools/autoconf/pkg-config installs.

### Service start/stop scripts (final user interface)

After `make set-up-lightning-{mainnet,testnet}`, the user has in `$PATH`:

- `{mainnet,testnet}-bitcoind-{start,stop}` — bitcoind on default ports (mainnet 8333, testnet 18333)
- `{mainnet,testnet}-lnd-{start,debug-start,stop}` — lnd on TCP 9735, gRPC 10009 (mainnet) / 10010 (testnet)
- `{mainnet,testnet}-lightning-{start,stop}` — bundle that calls bitcoind + lnd in sequence

PID files live at `~/.<network>-<service>.pid`. Wrapper scripts call `upnpc` to add port-forwarding when `BITCOIN_KIT_UPNP_SUPPORT=Yes`. Wallet creation runs lnd in a temporary nohup'd process during `set-up-lightning-*` (see the `wallet.db` rule in `mk/lnd.mk`).

Aliases installed via `configs/aliases.sh`: `l`/`lt` = mainnet/testnet `lncli` with the right macaroon path, `loc`/`ltoc` = "open channel to `pubkey@host:port`" helper that pre-checks for existing channels.

### Macaroon / TLS migration

`update_wallet_macaroon_files_to_standard_dir.sh` and `update_lnd_cert_to_standard_cert.sh` are run on every `lnd-update` to migrate state from pre-v0.5 LND layouts (`~/.lnd/admin.macaroon`, non-standard cert paths) into the modern `~/.lnd/data/chain/bitcoin/<network>/admin.macaroon` layout. Old installs may still need them; do not remove these scripts.

## Conventions when modifying the build

- **No root in build recipes.** Only `iptables_install` / `bitcoin_iptables_install` need root, and they're invoked separately. Everything else must work as the `bitcoin` user.
- **Stamp files** (e.g. `lnd_install`, `bitcoin-core_install`, `required_for_configure_install`) are empty marker files in the repo root used as Make targets. `prepare-*-update` removes the relevant stamps to force rebuilds. Don't `.gitignore` patterns that would track these — `.gitignore` is the source of truth for what's allowed to appear.
- **Configs are templated, not generated.** When changing a runtime config or a wrapper script, edit `configs/...` and the matching `sed` rule in `mk/*.mk` if a new `$$VAR$$` is introduced. Never edit files in `build/` or `~/`.
- **Existing user configs are preserved.** Install rules for `~/.bitcoin/*.conf` and `~/.lnd/*.conf` write `<name>.new.conf` instead of overwriting — keep this behavior on any new config.
- **`CHANGES.txt` is the changelog.** Update it when bumping `LND_ACTUAL_COMMIT`, Bitcoin Core, Go, or other pinned components, mirroring the existing `YYYY-MM-DD` format.
- **GPG / SHA256 verification before compile** is a project value (`README.md`); preserve it where present in `mk/*.mk` (especially for tarball downloads via `$(WGET)`, which uses `--no-check-certificate` for old-CA-bundle compatibility but compensates with checksum/signature checks).
