# srvctl bash completion

Bash completion for Oracle `srvctl` (Oracle Restart, Grid Infrastructure, RAC), 19c and later.

## Installation

```bash
# per user
echo 'source ~/srvctl-completion/srvctl_completion.bash' >> ~/.bashrc

# system-wide (any bash, with or without the bash-completion package)
cp srvctl_completion.bash /etc/bash_completion.d/srvctl     # if bash-completion is installed
# otherwise: cp to /etc/profile.d/srvctl_completion.sh
```

## What gets completed

| Position / option | Source |
|---|---|
| verb, object, options | parsed from `srvctl -h` + `srvctl <verb> -h` of the srvctl being called |
| options already used | are not offered again |
| `{A \| B}` values (`-policy`, `-role`, `-failovertype` …) | parsed from the usage lines |
| `-startoption`, `-stopoption` | built-in list (only documented in descriptions) |
| `-db` | `crsctl stat res -p`, `ora.database.type` → `DB_UNIQUE_NAME` |
| `-service` | `ora.service.type`, filtered by `-db` on the command line |
| `-pdb` | `ora.pdb.type` + `PLUGGABLE_DATABASE` of services, filtered by `-db` |
| `-instance`, `-preferred`, `-available` | `(GEN_)USR_ORA_INST_NAME[@SERVERNAME(node)]`, filtered by `-db` and `-node`; `-preferred`/`-available` exclude each other |
| `-listener`, `-diskgroup` | `ora.listener.type`, `ora.diskgroup.type` |
| `-node`, `-server`, `-targetnode` … | see *Restart vs. cluster* |
| `-netnum` (cluster) | `ora.netN.network` |
| `-vip` (cluster) | `USR_ORA_VIP` of the node VIPs, filtered by `-node` |
| `-scannumber`, `-scanname` (cluster) | `ora.scanN.vip`, `SCAN_NAME` |
| `-volume`, `-device` (cluster, ACFS) | `VOLUME_NAME`, `VOLUME_DEVICE` of `ora.volume.type` |
| `-oraclehome` | homes from the central inventory, then directories |
| `…file…`, `…path…` | filenames |

Comma separated lists are supported (`-service app1,<TAB>` offers the remaining services).

## Restart vs. cluster

The mode is read from `/etc/oracle/ocr.loc` (`local_only=TRUE` → Restart, otherwise cluster).

- **Commands and options**: srvctl itself only shows the commands of its mode
  (26ai: 10 objects with Restart, 34 in a cluster; `-node` does not exist in Restart).
  The parsed help is therefore cached per srvctl binary *and* mode.
- **Nodes**: Restart → `hostname -s`. Cluster → `olsnodes`; if the stack is down
  the node list from the installation (19c: inventory `NODE_LIST`,
  26ai: `NODE_NAME_LIST` in `<GI_HOME>/crs/install/crsconfig_params`, does not include nodes added later).
- **Resources**: cluster-only types (network, VIP, SCAN, ADVM volumes) only exist there.
  With the stack down, all live values are empty.

## Caches

- Parsed help: `${XDG_CACHE_HOME:-~/.cache}/srvctl-completion/<path-of-srvctl>.<restart|cluster>.bash`
  (override with `SRVCTL_COMP_CACHE`). Built on the first TAB (~2–3 s, srvctl is Java),
  rebuilt automatically when the srvctl binary is newer (patching / new home).
- crsctl output: kept in the shell for `SRVCTL_COMP_TTL` seconds (default 10).

## GI home detection

`/etc/oracle/olr.loc` (`crs_home=`), fallback `$ORACLE_HOME/bin/crsctl`, then `crsctl` from `PATH`.
`/etc/oratab` is not used.

## Tested

The completion is tested with [oravirt/ansible-oracle](https://github.com/oravirt/ansible-oracle)
molecule scenarios, the primary test platform for this project. Focus is on 26ai.

- **Oracle Restart 26ai** (23.26.0.4): GI home and DB home 19.33 (molecule `has-ol9`).
  - srvctl from GI home and from a 19.33 DB home.
  - Services (comptest1, comptest2), PDBs, instances, listeners, diskgroups.
- **2-node RAC 26ai** (molecule `rac`, GI 26.04, DB home 26.03, RACCDB).
  - Instances per node with `-node` filter, `-preferred`/`-available` exclusion.
  - Cluster resources: `-vip`, `-netnum`, `-scannumber`, `-scanname`.
  - Also tested with the CRS stack down (node list from `crsconfig_params`).
  - srvctl from GI home and from DB home 26.03.
- **Not tested**: 19c cluster, RAC services (none in RACCDB), ACFS volumes, RAC One Node.
