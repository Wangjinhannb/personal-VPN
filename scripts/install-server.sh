#!/usr/bin/env bash
set -Eeuo pipefail

# Initial installer for a clean Ubuntu host. Provider firewall/VPC settings are external.
if [[ ${EUID} -ne 0 ]]; then echo "Run with sudo/root." >&2; exit 1; fi
. /etc/os-release
if [[ ${ID:-} != ubuntu || ! ${VERSION_ID:-} =~ ^(24\.04|26\.04)$ ]]; then echo "Supported systems: Ubuntu 24.04 and 26.04 only." >&2; exit 1; fi
arch=$(dpkg --print-architecture)
case "$arch" in amd64|arm64) ;; *) echo "Unsupported architecture: $arch" >&2; exit 1;; esac
if systemctl is-active --quiet ufw 2>/dev/null || systemctl is-active --quiet firewalld 2>/dev/null; then
  echo "UFW/firewalld is active. Refusing to change firewall ownership. Resolve this manually before continuing." >&2; exit 1
fi
if [[ -e /etc/wireguard/wg0.conf ]]; then echo "Existing /etc/wireguard/wg0.conf found; refusing to overwrite." >&2; exit 1; fi
for cmd in ip nft systemctl; do command -v "$cmd" >/dev/null || { echo "Missing required command: $cmd" >&2; exit 1; }; done
v4_route=$(ip -4 route get 1.1.1.1 2>/dev/null | head -n1 || true)
v6_route=$(ip -6 route get 2606:4700:4700::1111 2>/dev/null | head -n1 || true)
v4_dev=$(awk '{for(i=1;i<=NF;i++) if($i=="dev") {print $(i+1); exit}}' <<<"$v4_route")
v6_dev=$(awk '{for(i=1;i<=NF;i++) if($i=="dev") {print $(i+1); exit}}' <<<"$v6_route")
[[ -n "$v4_dev" && -n "$v6_dev" ]] || { echo "Working IPv4 and IPv6 default routes are required for dual-stack mode." >&2; exit 1; }
if [[ "$v4_dev" != "$v6_dev" ]]; then echo "IPv4 and IPv6 use different uplinks ($v4_dev / $v6_dev); this release requires one shared uplink." >&2; exit 1; fi
uplink=$v4_dev
v6_global=$(ip -6 -o addr show dev "$uplink" scope global | awk '{print $4}' | head -n1)
[[ -n "$v6_global" ]] || { echo "No global IPv6 address found on $uplink." >&2; exit 1; }
read -rp "Public IPv4 or DNS endpoint (not including port): " endpoint
[[ -n "$endpoint" ]] || { echo "Endpoint is required." >&2; exit 1; }
read -rp "WireGuard UDP port [51820]: " port
port=${port:-51820}
[[ "$port" =~ ^[0-9]+$ ]] && ((port > 0 && port < 65536)) || { echo "Invalid UDP port." >&2; exit 1; }
read -rp "Server public IPv6 address (global IPv6 on this VPS): " server_v6
server_v6=${server_v6:-${v6_global%%/*}}
python3 - "$server_v6" <<'PY'
import ipaddress,sys
ip=ipaddress.ip_address(sys.argv[1])
if ip.version != 6 or not ip.is_global: raise SystemExit("A global IPv6 address is required")
PY
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y wireguard-tools nftables python3
install -d -m 700 /etc/wireguard
umask 077
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
ula=$(python3 - <<'PY'
import secrets
x=secrets.token_hex(5)
print(f"fd{x[:4]}:{x[4:8]}:{x[8:]}:1::/64")
PY
)
server_priv=$(cat /etc/wireguard/server_private.key)
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = 10.66.66.1/24, ${ula%/64}1/64
ListenPort = $port
PrivateKey = $server_priv
MTU = 1380
EOF
chmod 600 /etc/wireguard/wg0.conf
cat > /etc/sysctl.d/70-wgvpn.conf <<'EOF'
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.default.forwarding=1
EOF
sysctl --system >/dev/null
install -d -m 755 /usr/local/libexec/wgvpn
cat > /usr/local/libexec/wgvpn/firewall.sh <<'FW'
#!/usr/bin/env bash
set -euo pipefail
ACTION=${1:?apply|remove required}
UPLINK=${2:?uplink required}
WG_IF=${3:-wg0}
case "$ACTION" in
 apply)
  nft list table inet wgvpn >/dev/null 2>&1 && nft delete table inet wgvpn || true
  nft -f - <<EOF
 table inet wgvpn {
  chain forward { type filter hook forward priority filter; policy accept;
   iifname "$WG_IF" oifname "$UPLINK" accept
   iifname "$UPLINK" oifname "$WG_IF" ct state established,related accept
  }
  chain postrouting { type nat hook postrouting priority srcnat; policy accept;
   ip saddr 10.66.66.0/24 oifname "$UPLINK" masquerade
   ip6 saddr $ULA_PREFIX oifname "$UPLINK" masquerade
  }
 }
EOF
  ;;
 remove) nft delete table inet wgvpn 2>/dev/null || true ;;
 *) echo "Unknown action" >&2; exit 2 ;;
esac
FW
# Inject generated ULA prefix into the root-owned firewall helper.
ula_prefix=${ula%::/64}::/64
sed -i "s|ULA_PREFIX|$ula_prefix|g" /usr/local/libexec/wgvpn/firewall.sh
chmod 700 /usr/local/libexec/wgvpn/firewall.sh
cat > /etc/systemd/system/wgvpn-firewall.service <<EOF
[Unit]
Description=WireGuard VPN nftables rules
Before=wg-quick@wg0.service
After=network-online.target nftables.service
Wants=network-online.target
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/libexec/wgvpn/firewall.sh apply $uplink wg0
ExecStop=/usr/local/libexec/wgvpn/firewall.sh remove $uplink wg0
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now wgvpn-firewall.service
systemctl enable --now wg-quick@wg0.service
install -d -m 700 /var/lib/wgvpn
install -m 600 /dev/null /var/lib/wgvpn/clients.tsv
printf 'uplink=%s\nendpoint=%s\nport=%s\nula_prefix=%s\nserver_ipv6=%s\n' "$uplink" "$endpoint" "$port" "$ula_prefix" "$server_v6" > /var/lib/wgvpn/server.env
chmod 600 /var/lib/wgvpn/server.env
printf '\nInstall complete. Server public key:\n'
cat /etc/wireguard/server_public.key
printf '\nServer VPN IPv4: 10.66.66.1/24\nServer VPN IPv6: %s1/64\nEndpoint: %s:%s\n' "${ula%/64}" "$endpoint" "$port"
echo "Next: open UDP $port in your provider firewall, then register client public keys."
