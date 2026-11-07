#!/usr/bin/env bash
set -uo pipefail
fail=0
check(){ if eval "$2" >/dev/null 2>&1; then printf '[OK] %s\n' "$1"; else printf '[FAIL] %s\n' "$1"; fail=1; fi; }
check 'WireGuard interface exists' 'ip link show wg0'
check 'WireGuard service active' 'systemctl is-active --quiet wg-quick@wg0'
check 'UDP 51820 listener' 'ss -lun | grep -q ":51820"'
check 'IPv4 forwarding enabled' 'test "$(sysctl -n net.ipv4.ip_forward)" = 1'
check 'IPv6 forwarding enabled' 'test "$(sysctl -n net.ipv6.conf.all.forwarding)" = 1'
check 'nftables table exists' 'nft list table inet wgvpn'
check 'IPv4 default route exists' 'ip -4 route show default | grep -q default'
check 'IPv6 default route exists' 'ip -6 route show default | grep -q default'
echo; echo 'For handshake diagnosis run: sudo tcpdump -ni any udp port 51820'
echo 'For peer status run: sudo wg show'
exit "$fail"
