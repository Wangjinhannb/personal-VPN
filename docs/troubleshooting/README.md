# Troubleshooting / 故障排查

## No handshake / 没有握手

Check the endpoint IP/port, provider firewall UDP rule, host firewall, server listener (`sudo ss -lunp`), and packet arrival (`sudo tcpdump -ni any udp port 51820`). Then verify the client public key is registered and the server public key in the client profile is correct.

检查 Endpoint IP/端口、服务商 UDP 防火墙规则、主机防火墙、服务端监听状态（`sudo ss -lunp`）和数据包是否到达（`sudo tcpdump -ni any udp port 51820`）。随后确认客户端公钥已注册，客户端配置中的服务端公钥正确。

## Handshake but no Internet / 有握手但无法上网

Check IPv4/IPv6 forwarding, nftables forward and NAT rules, the uplink interface, provider egress policy, and DNS separately. A handshake proves the encrypted peer connection, not internet forwarding.

检查 IPv4/IPv6 转发、nftables forward 和 NAT 规则、出口网卡、服务商出站策略，并单独检查 DNS。握手成功只证明加密 Peer 连接建立，不代表互联网转发正常。

## IPv6 unavailable / IPv6 不可用

Check `ip -6 addr`, `ip -6 route`, provider IPv6 enablement, IPv6 forwarding, and NAT66 counters. Do not silently fall back and report dual-stack success.

检查 `ip -6 addr`、`ip -6 route`、服务商 IPv6 开通情况、IPv6 转发和 NAT66 计数器。不得静默降级后仍报告双栈成功。

## Proxy or TUN conflicts / 代理或 TUN 冲突

A second full-tunnel VPN or proxy TUN can alter routes or policy routing. Capture packets on the server and inspect client route tables before attributing a handshake failure to the proxy. Exclude the WireGuard endpoint from the other tunnel if necessary.

第二个全隧道 VPN 或代理 TUN 可能改变路由或策略路由。应先在服务器抓包并检查客户端路由表，再判断握手失败是否由代理引起。必要时将 WireGuard Endpoint 从另一个隧道中排除。
