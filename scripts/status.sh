#!/usr/bin/env bash
set -euo pipefail
if [[ ${EUID} -ne 0 ]]; then exec sudo "$0" "$@"; fi
echo '== WireGuard service =='
systemctl --no-pager --full status wg-quick@wg0.service || true
echo '\n== WireGuard peers =='
wg show || true
echo '\n== Forwarding =='
sysctl net.ipv4.ip_forward net.ipv6.conf.all.forwarding
echo '\n== nftables project table =='
nft list table inet wgvpn 2>/dev/null || echo 'Table inet wgvpn not found'
echo '\n== Default routes =='
ip -4 route show default
ip -6 route show default
