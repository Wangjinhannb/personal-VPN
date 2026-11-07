# Personal VPN — WireGuard VPN Toolkit

> A bilingual, self-hosted WireGuard deployment toolkit for Ubuntu 24.04 LTS and 26.04 LTS, with automated and step-by-step installation paths.

> 面向 Ubuntu 24.04 LTS 和 26.04 LTS 的双语自建 WireGuard 部署工具，提供自动化部署和逐条命令手动部署两种方式。

**Project status / 项目状态:** Initial implementation in progress. Do not use on production hosts until the deployment and dual-stack tests pass. / 首版实现与测试进行中；部署和双栈测试通过前，请勿用于生产服务器。

## Deployment paths / 部署方式

- [Automated deployment / 自动化部署](docs/automated/README.md)
- [Manual deployment / 手动部署](docs/manual/README.md)
- [Architecture / 技术架构](docs/architecture/README.md)
- [AWS EC2 notes / AWS EC2 说明](docs/providers/aws.md)
- [Generic VPS notes / 通用 VPS 说明](docs/providers/generic-vps.md)
- [Client guides / 客户端指南](docs/clients/README.md)
- [Troubleshooting / 故障排查](docs/troubleshooting/README.md)

## Scope / 项目范围

- Ubuntu 24.04 LTS and 26.04 LTS; AMD64 and ARM64.
- WireGuard with IPv4 and IPv6 client addressing.
- IPv4 NAT (NAT44) and IPv6 NAT (NAT66) for outbound client traffic.
- Windows, Android, iOS and Linux clients.
- Client public-key registration and revocation. Client private keys are generated and kept on the client device.
- nftables rules are isolated in project-owned tables; existing firewall managers are not silently disabled.

- 支持 Ubuntu 24.04 LTS、26.04 LTS，以及 AMD64、ARM64。
- WireGuard 同时分配 IPv4 和 IPv6 客户端地址。
- 使用 NAT44 和 NAT66 转发客户端出站流量。
- 支持 Windows、Android、iOS 和 Linux 客户端。
- 支持客户端公钥注册和撤销；客户端私钥只在客户端设备本地生成和保存。
- nftables 规则使用独立表管理，不会静默关闭用户已有的防火墙管理工具。

## Important limitations / 重要限制

This toolkit provides a self-hosted VPN tunnel, not anonymity, a residential IP address, or a commercial VPN network. The public egress address is the VPS provider's address. Dual-stack mode requires working public IPv4 and IPv6 connectivity on the server. NAT66 provides outbound IPv6 through the server's public IPv6 address; it does not give clients independently routed global IPv6 addresses.

本项目提供自托管 VPN 隧道，不提供匿名性、住宅 IP 或商业 VPN 网络。公网出口地址属于 VPS 服务商。双栈模式要求服务器具备可用的公网 IPv4 和 IPv6 出站能力。NAT66 让客户端通过服务器公网 IPv6 出站，但不会为客户端分配可从公网独立路由的全球 IPv6 地址。

## Security / 安全

Never commit private keys, real WireGuard configuration files, SSH keys, cloud credentials, or generated client profiles containing private keys. See [SECURITY.md](SECURITY.md).

禁止提交私钥、真实 WireGuard 配置、SSH 密钥、云凭据，以及包含客户端私钥的配置文件。详见 [SECURITY.md](SECURITY.md)。

## License / 许可证

MIT. See [LICENSE](LICENSE).
