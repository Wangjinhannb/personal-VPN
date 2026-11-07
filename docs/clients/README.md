# Client Guides / 客户端指南

## Windows

Install the official WireGuard client. Create a tunnel locally and generate the private/public key pair on the Windows device. Register only the public key on the server. Import the completed client profile locally.

安装官方 WireGuard 客户端。在 Windows 本地创建隧道并生成公私钥。只向服务器注册公钥，完成客户端配置后在本地导入。

## Android and iOS / Android 与 iOS

Install the official WireGuard app. Generate the tunnel on the mobile device or import a locally generated profile. QR export is planned; treat QR codes as secrets because they contain the client private key.

安装官方 WireGuard 应用。在手机本地生成隧道，或导入本地生成的配置。二维码导出属于后续功能；二维码包含客户端私钥，应按秘密信息保护。

## Linux

Install `wireguard-tools`, create a client profile locally, and use `wg-quick` or the distribution's network manager. Keep the private key readable only by the owning user/root.

安装 `wireguard-tools`，在本地创建客户端配置，并使用 `wg-quick` 或发行版网络管理器。客户端私钥仅允许所属用户或 root 读取。
