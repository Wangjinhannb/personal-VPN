# Security Policy / 安全策略

## Never commit secrets / 严禁提交密钥

Do not commit `*.pem`, `*.key`, real `wg*.conf`, client exports containing private keys, cloud credentials, or SSH credentials. Client private keys must be generated on and remain on the client device. The server stores only client public keys.

禁止提交 `*.pem`、`*.key`、真实 `wg*.conf`、包含私钥的客户端配置、云凭据或 SSH 凭据。客户端私钥必须在客户端设备本地生成并保留。服务器只保存客户端公钥。

## Reporting / 漏洞报告

Do not publish exploitable details or secrets in public issues. Contact the repository owner privately through GitHub for security-sensitive reports.

请勿在公开 Issue 中发布可利用的漏洞细节或密钥。涉及安全的问题请通过 GitHub 私下联系仓库维护者。

## Scope / 范围

This is a deployment helper, not a security audit or anonymity product. Operators remain responsible for host updates, provider firewalls, access control, backups, and monitoring.

本项目是部署辅助工具，不是安全审计或匿名产品。服务器维护者仍需负责系统更新、服务商防火墙、访问控制、备份和监控。
