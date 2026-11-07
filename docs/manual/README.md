# Manual Deployment / 手动部署

This guide explains the steps instead of hiding them in a one-click script. Commands assume a clean Ubuntu host and must be reviewed for your provider and firewall. / 本指南逐步解释操作，不把步骤隐藏在一键脚本中。命令以干净的 Ubuntu 主机为前提，执行前必须结合服务商和防火墙环境检查。

## 1. Check the OS / 检查系统

```bash
cat /etc/os-release
uname -m
```

Confirm Ubuntu 24.04/26.04 and `x86_64` or `aarch64`. / 确认系统为 Ubuntu 24.04/26.04，架构为 `x86_64` 或 `aarch64`。

## 2. Check public routes / 检查公网路由

```bash
ip -4 route show default
ip -6 route show default
ip -4 addr show scope global
ip -6 addr show scope global
```

Dual-stack mode requires a usable global IPv6 address and IPv6 default route. If either is absent, fix provider networking first; do not claim dual-stack readiness. / 双栈模式要求存在可用全球 IPv6 地址和 IPv6 默认路由。若缺少任一项，应先修复服务商网络，不得宣称已具备双栈条件。

## 3. Install packages / 安装软件包

```bash
sudo apt update
sudo apt install -y wireguard-tools nftables
```

## 4. Detect the uplink / 检测出口网卡

```bash
ip -4 route get 1.1.1.1
ip -6 route get 2606:4700:4700::1111
```

Record the `dev` interface from both results. The design assumes a common uplink; if IPv4 and IPv6 use different interfaces, adapt the nftables rules accordingly. / 记录两条结果中的 `dev` 网卡。设计默认 IPv4/IPv6 共用出口；若出口不同，必须相应调整 nftables 规则。

## 5. Generate server keys / 生成服务端密钥

```bash
sudo install -d -m 700 /etc/wireguard
sudo sh -c 'umask 077; wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key'
```

Do not repeat key generation on an existing installation. Back up the private key securely and never commit it. / 已有安装不要重复生成密钥。请安全备份私钥，绝不能提交到仓库。

## 6. Enable forwarding / 开启转发

```bash
sudo tee /etc/sysctl.d/70-wg-vpn.conf >/dev/null <<'EOF'
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.default.forwarding=1
EOF
sudo sysctl --system
```

IPv6 forwarding can affect router advertisements on some providers. Confirm the provider's IPv6 gateway behavior before applying this setting. / IPv6 转发可能影响部分服务商的路由通告。应用前需确认服务商 IPv6 网关行为。

## 7. Configure provider firewall / 配置服务商防火墙

Allow inbound UDP `51820` to the server. Keep SSH TCP `22` restricted to your current management IP. Permit required outbound traffic. / 允许 UDP `51820` 入站。SSH TCP `22` 仅允许当前管理 IP。确保出站流量规则满足需要。

## 8. Configure WireGuard and nftables / 配置 WireGuard 与 nftables

Use the examples in `config/` only as templates. Replace interface names, keys, endpoint and the generated ULA prefix. Do not copy placeholder keys into a live configuration. / `config/` 中的文件仅为模板。必须替换网卡名称、密钥、Endpoint 和生成的 ULA 前缀。不得将占位密钥直接用于真实配置。

## 9. Verify both stacks / 验证双栈

```bash
sudo wg show
sudo nft list ruleset
sysctl net.ipv4.ip_forward net.ipv6.conf.all.forwarding
```

Test actual IPv4 and IPv6 egress from a connected client and test DNS separately. / 从已连接客户端实际测试 IPv4、IPv6 出口，并单独测试 DNS。
