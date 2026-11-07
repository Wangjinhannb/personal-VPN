# Contributing / 贡献指南

## English

- Keep documentation bilingual (Chinese and English).
- Never add real keys, server addresses tied to a private deployment, credentials, or client exports.
- Shell scripts must pass ShellCheck and use `set -Eeuo pipefail` where appropriate.
- Changes to firewall rules must be idempotent, scoped to the toolkit's own nftables table, and documented with rollback steps.
- Test on clean Ubuntu 24.04 and 26.04 hosts before claiming support.

## 中文

- 文档必须保持中英文双语。
- 禁止加入真实密钥、私人部署服务器地址、凭据或客户端导出配置。
- Shell 脚本应通过 ShellCheck，并在适当情况下使用 `set -Eeuo pipefail`。
- 防火墙规则必须幂等、仅作用于工具自己的 nftables 表，并提供回滚步骤。
- 声称支持 Ubuntu 24.04/26.04 前，必须在干净系统上测试。
