#!/usr/bin/env bash
# Copy a bitstream to the Raspberry Pi and program the Arty S7 with openFPGALoader.
#
# Usage:
#   ./scripts/program-remote.sh pi@yourboard.duckdns.org design.bit
#
# Optional environment variables:
#   BOARD     board name (default: arty_s7_50; try `openFPGALoader --list-boards | grep arty`)
#   SSH_PORT  SSH port on the Pi / forwarded on your router (default: 22)
#   FLASH     set to 1 to write the SPI flash so the design survives a power cycle
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "usage: $0 user@host bitfile.bit" >&2
  exit 1
fi

target="$1"
bitfile="$2"
board="${BOARD:-arty_s7_50}"
port="${SSH_PORT:-22}"
remote_file="/tmp/$(basename "$bitfile")"

flash_flag=""
if [ "${FLASH:-}" = "1" ]; then
  flash_flag="-f"
fi

scp -P "$port" "$bitfile" "$target:$remote_file"
ssh -p "$port" "$target" "openFPGALoader -b $board $flash_flag $remote_file"
