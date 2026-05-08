# inifcloudsh

一键脚本：SSH 到目标机，安装 nyanpass nodeclient + 写入内核网络调优。

## 用法

```bash
bash <(curl -fsSL <脚本URL>) <IP> '<PASSWORD>'
```

密码用单引号包裹，避免末尾 `/` 等特殊字符被吞。

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
SSH_USER=root SSH_PORT=22 bash <(curl -fsSL <URL>) <IP> '<PASS>'
```
