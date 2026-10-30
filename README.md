# Terraria server deployment

This repository contains a small, resource-conscious deployment baseline for a
Terraria dedicated server on Ubuntu 24.04 with 1 GB RAM and approximately 5 GB
of disk space.

## Mobile-first compatibility

This baseline targets the official mobile clients first. Use the exact server
build and mobile release that were verified together; mobile Android/iOS
support must not be inferred from a PC release number.

The mobile-compatible baseline is vanilla. TShock, plugins, custom server
weapons, and modded content are intentionally excluded because they require
client/server support that the official mobile clients do not provide.

Use the official server archive supplied by the operator and record the
compatibility result in the deployment notes before enabling public access.

## Resource policy

- One server process and one world only.
- Medium world by default; Large worlds require a memory and disk test first.
- Eight players maximum initially.
- No Docker, database server, TShock, tModLoader, plugins, or custom weapons.
- Keep at least 1 GB free disk space for world growth and rotating backups.
- A 1 GB swap file is recommended, but swap is a safety margin, not a RAM
  substitute.

## Installation

Run as root on the target Ubuntu host, after copying this repository:

```sh
sudo ./deploy/install.sh /path/to/terraria-server-archive.tar.gz
```

The archive must be obtained from a trusted official release source. The
installer refuses to overwrite an existing installation, preserves existing
world data, creates a dedicated `terraria` user, installs the systemd unit,
and opens TCP port 7777 only when `ufw` is already active.

Before starting the service, review:

```sh
sudoedit /etc/terraria/serverconfig.txt
sudo systemctl start terraria
sudo systemctl status terraria
```

The service stores worlds and backups in `/var/lib/terraria`. A first world is
created automatically using the configured Medium size. The starter layout is
described in [`deploy/map-plan.txt`](deploy/map-plan.txt). To use an existing
world, copy it into `/var/lib/terraria/worlds/` as the `terraria` user and set
`world=` in the config.

The map uses normal Terraria buildings and wiring for its spawn, safe storage,
trade, and event areas. It does not claim server-side region protection:
official mobile vanilla has no plugin region system. Protect important areas
with in-game walls, locked chests, a whitelist/password, and regular backups.

## Operational checks

```sh
sudo journalctl -u terraria -f
sudo du -sh /var/lib/terraria
free -h
df -h /
```

Do not upgrade the server binary or add plugins until Android and iOS clients
have both connected successfully and the exact versions have been recorded.
Additional weapons cannot be added while retaining official mobile client
compatibility; use the game's existing weapons and accessories instead.

## Compatibility record

Fill this table from an actual client connection test; do not infer values
from a PC release number.

| Server release | Android version | iOS version | Multiplayer version | Plugins | Checked on | Result |
|---|---|---|---|---|---|---|
| Pending | Pending | Pending | Pending | None | Pending | Not tested |
