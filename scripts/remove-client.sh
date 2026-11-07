#!/usr/bin/env bash
set -Eeuo pipefail
if [[ ${EUID} -ne 0 ]]; then exec sudo "$0" "$@"; fi
if [[ $# -ne 1 ]]; then echo "Usage: $0 <client-name>" >&2; exit 2; fi
name=$1
state=/var/lib/wgvpn/clients.tsv
[[ -f "$state" ]] || { echo "Client state not found." >&2; exit 1; }
exec 9>/var/lib/wgvpn/clients.lock
flock -x 9
line=$(awk -F '\t' -v n="$name" '$1==n {print; exit}' "$state")
[[ -n "$line" ]] || { echo "Client not found: $name" >&2; exit 1; }
ip4=$(cut -f2 <<<"$line"); pub=$(cut -f3 <<<"$line")
wg set wg0 peer "$pub" remove
python3 - "$name" /etc/wireguard/wg0.conf <<'PY'
import pathlib,re,sys
name,path=sys.argv[1:]
p=pathlib.Path(path)
s=p.read_text()
# Peer blocks are keyed in the registry; remove the matching public-key block.
state=pathlib.Path('/var/lib/wgvpn/clients.tsv').read_text().splitlines()
row=next(x.split('\t') for x in state if x.split('\t')[0]==name)
pub=row[2]
blocks=re.split(r'(?=\n\[Peer\])', s)
blocks=[b for b in blocks if not (b.startswith('\n[Peer]') and re.search(r'^PublicKey\s*=\s*'+re.escape(pub)+r'\s*$',b,re.M))]
p.write_text(''.join(blocks))
p.chmod(0o600)
PY
tmp=$(mktemp)
awk -F '\t' -v n="$name" '$1!=n' "$state" > "$tmp"
install -m 600 "$tmp" "$state"; rm -f "$tmp"
echo "Revoked client: $name"
