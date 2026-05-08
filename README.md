# inifcloudsh

一键脚本：在**本机 Linux** 上装 nyanpass nodeclient + 内核网络调优。
安装时的网络流量经 `ssh -D` SOCKS5 隧道走指定的代理服务器（仅安装期间用，结束后隧道自动关闭）。

## 用法

```bash
sudo -E bash <(curl -fsSL <脚本URL>) <PROXY_IP> '<PROXY_PASSWORD>'
```

- 必须 root 运行（`sysctl` 与 nyanpass 安装都要 root）
- 密码用单引号包裹，避免末尾 `/` 等特殊字符被吞
- 自动安装 `sshpass` / `curl` / `openssh-client`（apt/dnf/yum/apk/pacman）

## 脚本

| 节点 | token | 文件 |
| --- | --- | --- |
| yuwan | `3c0a68ec-9ce5-4811-8214-e52994407caf` | `yuwan.sh` |
| miya  | `3d3ff588-3466-44c2-a4f4-161a3e297fef` | `miya.sh` |
| yzt   | `18e45f7a-fba8-4d69-a69d-2ad87f3e3843` | `yzt.sh` |

## 加速地址（实测可用，按速度排）

把 `<file>` 替换成 `yuwan.sh` / `miya.sh` / `yzt.sh`。

| 来源 | URL | 备注 |
| --- | --- | --- |
| gcore jsDelivr   | `https://gcore.jsdelivr.net/gh/inifcloud/inifcloudsh@main/<file>` | 全球 CDN，有缓存 |
| fastly jsDelivr  | `https://fastly.jsdelivr.net/gh/inifcloud/inifcloudsh@main/<file>` | 全球 CDN，有缓存 |
| gh-proxy.com     | `https://gh-proxy.com/https://raw.githubusercontent.com/inifcloud/inifcloudsh/main/<file>` | 无缓存 |
| ghproxy.net      | `https://ghproxy.net/https://raw.githubusercontent.com/inifcloud/inifcloudsh/main/<file>` | 无缓存 |
| ghfast.top       | `https://ghfast.top/https://raw.githubusercontent.com/inifcloud/inifcloudsh/main/<file>` | 无缓存 |
| statically.io    | `https://cdn.statically.io/gh/inifcloud/inifcloudsh/main/<file>` | 全球 CDN，有缓存 |
| GitHub 直连      | `https://raw.githubusercontent.com/inifcloud/inifcloudsh/main/<file>` | 国外用 |

## 可选环境变量

```bash
PROXY_USER=root PROXY_PORT=22 SOCKS_PORT=11080 \
  sudo -E bash <(curl -fsSL <URL>) <PROXY_IP> '<PASS>'
```

> ⚠️ **注意**：装好后 nyanpass nodeclient 是常驻 daemon，需要直连 `nyp.pccwg.us`。
> 本脚本只在**安装阶段**临时拉一条 SOCKS5 隧道走 202，安装完就拆。
> 如果本机后续连不上 `nyp.pccwg.us`，需要另外配置常驻代理（不在本脚本范围内）。
