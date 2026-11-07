# Network Flow / 网络流量路径

## IPv4 / IPv4 流量

Client `10.66.66.x` -> WireGuard `wg0` -> Linux forwarding -> nftables forward chain -> NAT44 masquerade on uplink -> public IPv4.

客户端 `10.66.66.x` -> WireGuard `wg0` -> Linux 转发 -> nftables forward 链 -> 出口网卡 NAT44 masquerade -> 公网 IPv4。

## IPv6 / IPv6 流量

Client ULA -> WireGuard `wg0` -> Linux IPv6 forwarding -> nftables forward chain -> NAT66 masquerade on uplink -> server global IPv6.

客户端 ULA -> WireGuard `wg0` -> Linux IPv6 转发 -> nftables forward 链 -> 出口网卡 NAT66 masquerade -> 服务器全球 IPv6。

## Important / 注意

This V1 design assumes IPv4 and IPv6 share one uplink. It intentionally refuses installation when the routes use different interfaces. NAT66 is an outbound compatibility mode, not routed-prefix delegation. IPv6 router-advertisement behavior varies by provider and must be validated on the target VPS.

V1 假设 IPv4 和 IPv6 共用一张出口网卡；若两者出口不同则拒绝安装。NAT66 是出站兼容模式，不是 IPv6 前缀委派。IPv6 路由通告行为因服务商而异，必须在目标 VPS 上验证。
