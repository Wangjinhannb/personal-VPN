# Automated Deployment / 自动化部署

> Initial release scope. Review the script and provider firewall requirements before running it. / 首版范围。运行前请阅读脚本并确认服务商防火墙要求。

## Requirements / 环境要求

- Ubuntu Server 24.04 LTS or 26.04 LTS, AMD64 or ARM64.
- Root access, working public IPv4 and IPv6, and an inbound UDP rule for the chosen WireGuard port (default `51820`).
- A provider firewall/security group allowing UDP `51820`; SSH should remain restricted to your own management IP.
- No active UFW/firewalld management in this initial implementation.

- Ubuntu Server 24.04 LTS 或 26.04 LTS，AMD64 或 ARM64。
- Root 权限、可用的公网 IPv4 和 IPv6，以及服务商侧放行所选 WireGuard UDP 端口（默认 `51820`）。
- 云防火墙/安全组允许 UDP `51820`；SSH 应继续限制为管理员自己的管理 IP。
- 首版不支持由 UFW/firewalld 管理防火墙的主机。

## Install / 安装

Clone the repository, inspect the scripts, then run as root:

克隆仓库并检查脚本后，以 root 执行：

```bash
sudo bash scripts/install-server.sh
```

The installer is designed to refuse unsupported hosts, preserve existing server keys, and avoid flushing unrelated nftables rules. It does not configure provider security groups or create a cloud instance for you.

安装程序应拒绝不受支持的系统、保留已有服务端密钥，并避免清空无关 nftables 规则。它不会替你配置云安全组或创建云服务器。

## Client enrollment / 客户端接入

Generate the client key pair on the client device. Submit only its public key to the server-side enrollment command. Never copy a client private key to the server.

在客户端设备本地生成密钥对。向服务端接入命令提交公钥即可。绝不要把客户端私钥复制到服务器。

## Verify / 验证

After enrollment, check `sudo wg show`, confirm a recent handshake, test an IPv4 address endpoint and an IPv6 address endpoint, and verify DNS resolution. A successful handshake alone does not prove forwarding or DNS is correct.

接入后运行 `sudo wg show`，确认最近握手时间；分别测试 IPv4、IPv6 出口，并验证 DNS。握手成功本身不能证明转发或 DNS 配置正确。
