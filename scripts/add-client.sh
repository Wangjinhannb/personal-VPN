#!/usr/bin/env bash
set -Eeuo pipefail
if [[ ${EUID} -ne 0 ]]; then exec sudo "$0" "$@"; fi
if [[ $# -ne 2 ]]; then echo "Usage: $0 <client-name> <client-public-key>" >&2; exit 2; fi
name=$1; pub=$2
[[ "$name" =~ ^[A-Za-z0-9_-]{1,32}$ ]] || { echo "Client name must be 1-32 ASCII letters, digits, _ or -." >&2; exit 2; }
[[ "$pub" =~ ^[A-Za-z0-9+/]{43}=$ ]] || { echo "Invalid WireGuard public key format." >&2; exit 2; }
wg pubkey >/dev/null 2>&1 || { echo "wireguard-tools is required." >&2; exit 1; }
state=/var/lib/wgvpn/clients.tsv
[[ -f "$state" ]] || { echo "Server state missing. Run install-server.sh first." >&2; exit 1; }
# shellcheck disable=SC1091
source /var/lib/wgvpn/server.env
exec 9>/var/lib/wgvpn/clients.lock
flock -x 9
if grep -q "^${name}[[:space:]]" "$state" || grep -q "[[:space:]]${pub}$" "$state"; then echo "Client name or key already registered." >&2; exit 1; fi
used=$(awk '{print $2}' "$state" 2>/dev/null | awk -F. '$1==10&&$2==66&&$3==66 {print $4}' | sort -n | tail -n1)
last=${used:-1}; next=$((last+1)); ((next <= 254)) || { echo "IPv4 client pool exhausted." >&2; exit 1; }
ip4="10.66.66.$next"
ula_base=${ula_prefix%::/64}
ip6="${ula_base}::$(printf '%x' "$next")"
wg set wg0 peer "$pub" allowed-ips "$ip4/32,$ip6/128"
printf '\n[Peer]\nPublicKey = %s\nAllowedIPs = %s/32, %s/128\n' "$pub" "$ip4" "$ip6" >> /etc/wireguard/wg0.conf
chmod 600 /etc/wireguard/wg0.conf
printf '%s\t%s\t%s\n' "$name" "$ip4" "$pub" >> "$state"
printf 'Registered %s\nIPv4: %s\nIPv6: %s\n' "$name" "$ip4" "$ip6"
echo 'Client private key must remain on the client device. Build the local profile using the server public key and endpoint.'
