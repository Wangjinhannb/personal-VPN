# Architecture / 技术架构

## Data path / 数据流

Client IPv4/IPv6 traffic enters the WireGuard interface (`wg0`). Linux forwarding routes it to the detected uplink. nftables applies source NAT (NAT44 and NAT66) for outbound traffic. Replies are tracked and returned through the tunnel.

客户端 IPv4/IPv6 流量进入 WireGuard 接口（`wg0`）。Linux 将流量转发至自动检测的出口网卡。nftables 对出站流量执行源地址转换（NAT44、NAT66），连接跟踪负责将返回流量送回隧道。

## Address plan / 地址规划

- IPv4 server: `10.66.66.1/24`; client pool: `10.66.66.2`–`10.66.66.254`.
- IPv6: a randomly generated RFC 4193 ULA `/64`; server `::1`, clients `::2` onward.
- UDP listen port: `51820` by default.

- IPv4 服务端：`10.66.66.1/24`；客户端地址池：`10.66.66.2` 至 `10.66.66.254`。
- IPv6：随机生成符合 RFC 4193 的 ULA `/64`；服务端使用 `::1`，客户端从 `::2` 开始。
- 默认 UDP 监听端口：`51820`。

## IPv6 requirement / IPv6 要求

Dual-stack mode requires a working global IPv6 address and IPv6 default route on the VPS. ULA addresses are used inside the tunnel; NAT66 provides outbound IPv6 using the server's global IPv6. This is not routed-prefix delegation and does not make client ULA addresses globally reachable.

双栈模式要求 VPS 拥有可用的全球 IPv6 地址和 IPv6 默认路由。隧道内部使用 ULA 地址；NAT66 让客户端通过服务器全球 IPv6 出站。这不是 IPv6 前缀委派，也不会让客户端 ULA 地址可被公网直接访问。

## Firewall ownership / 防火墙管理边界

The toolkit owns a dedicated nftables table and does not flush the global ruleset. V1 must stop and ask for operator intervention if UFW or firewalld is active; it must not disable or rewrite an existing firewall manager. Cloud security groups and provider firewalls are configured separately.

工具仅管理专用 nftables 表，不清空全局规则集。V1 检测到 UFW 或 firewalld 正在运行时必须停止并要求管理员处理；不得自动关闭或重写现有防火墙管理器。云安全组和服务商防火墙需另行配置。
