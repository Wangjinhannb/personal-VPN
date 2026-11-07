# AWS EC2 / AWS EC2 部署说明

## English

1. Assign a public IPv4 address and configure IPv6 CIDR on the VPC and subnet if dual-stack is required.
2. Assign a global IPv6 address to the instance and ensure the subnet route table has `::/0` to an Internet Gateway.
3. Add inbound UDP `51820` to the instance security group. Keep SSH TCP `22` limited to the administrator's current public IP.
4. Disable EC2 source/destination checks because the instance forwards traffic for VPN clients.
5. Ensure outbound security-group rules and network ACLs permit the required traffic.
6. Configure the guest OS only after verifying both IPv4 and IPv6 routes.

## 中文

1. 分配公网 IPv4；如需双栈，在 VPC 和子网配置 IPv6 CIDR。
2. 为实例分配全球 IPv6 地址，并确认子网路由表存在指向 Internet Gateway 的 `::/0` 路由。
3. 在实例安全组开放入站 UDP `51820`。SSH TCP `22` 仅允许管理员当前公网 IP。
4. 由于实例需要转发 VPN 客户端流量，必须关闭 EC2 源/目标检查。
5. 确认安全组出站规则和网络 ACL 允许所需流量。
6. 确认 IPv4、IPv6 路由正常后，再配置 Ubuntu 内部网络。

Provider networking is outside the installer. The script must not claim to create or modify AWS VPC, security groups, route tables, or instance attributes.

云平台网络设置不属于安装脚本职责。脚本不得声称能够创建或修改 AWS VPC、安全组、路由表或实例属性。
