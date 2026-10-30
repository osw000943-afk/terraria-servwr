#!/bin/sh
set -eu

ARCHIVE=${1:-}
INSTALL_DIR=/opt/terraria
DATA_DIR=/var/lib/terraria
CONFIG_DIR=/etc/terraria
SERVICE_FILE=deploy/terraria.service
CONFIG_FILE=deploy/serverconfig.txt

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this installer as root." >&2
    exit 1
fi

if [ "$(uname -m)" != "x86_64" ]; then
    echo "This baseline expects an x86_64 Terraria server archive." >&2
    exit 1
fi

if [ -z "$ARCHIVE" ] || [ ! -f "$ARCHIVE" ]; then
    echo "Usage: $0 /path/to/official-terraria-server-archive.tar.gz" >&2
    exit 1
fi

if [ ! -r "$SERVICE_FILE" ] || [ ! -r "$CONFIG_FILE" ]; then
    echo "Run this script from the repository root." >&2
    exit 1
fi

if [ -e "$INSTALL_DIR" ]; then
    echo "An existing path was found at $INSTALL_DIR." >&2
    echo "Refusing to overwrite it. Back it up or install manually." >&2
    exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
    echo "tar is required." >&2
    exit 1
fi

if ! id terraria >/dev/null 2>&1; then
    useradd --system --home-dir "$DATA_DIR" --create-home --shell /usr/sbin/nologin terraria
fi

install -d -o terraria -g terraria -m 0755 "$INSTALL_DIR" "$DATA_DIR" \
    "$DATA_DIR/worlds" "$DATA_DIR/backups" "$CONFIG_DIR"

tar -xzf "$ARCHIVE" -C "$INSTALL_DIR" --strip-components=1
if [ ! -x "$INSTALL_DIR/TerrariaServer.bin.x86_64" ]; then
    echo "The archive does not contain TerrariaServer.bin.x86_64." >&2
    rm -rf "$INSTALL_DIR"
    exit 1
fi

chown -R terraria:terraria "$INSTALL_DIR" "$DATA_DIR"
chmod 0755 "$INSTALL_DIR/TerrariaServer.bin.x86_64"
install -o root -g root -m 0644 "$CONFIG_FILE" "$CONFIG_DIR/serverconfig.txt"
install -o root -g root -m 0644 "$SERVICE_FILE" /etc/systemd/system/terraria.service

if command -v ufw >/dev/null 2>&1 && ufw status | grep -q '^Status: active'; then
    ufw allow 7777/tcp comment 'Terraria dedicated server'
fi

systemctl daemon-reload
systemctl enable terraria
echo "Installed. Review $CONFIG_DIR/serverconfig.txt, then run: systemctl start terraria"
