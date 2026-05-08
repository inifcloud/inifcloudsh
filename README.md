# inifcloudsh

一键脚本：装 nyanpass nodeclient + 自定义 sysctl。

## 关键设计

直接走 `dl.nyafw.com`，绕过 `dispatch.nyafw.com` 的国家检测。
dispatch 用 `apple.com geo=cn` 头判断国别，AWS 中国区 / 部分网络环境会被误判成 CN，走慢镜像 `dispatch.nyafw.com/mirror`。
dispatch 自己的脚本里都写了：
> `[错误] AWS EC2 机器（以及任何海外月抛机器）请使用 dl.nyafw.com 不要使用 dispatch.nyafw.com`

用 `S=<服务名>` 进入官方静默模式跳过所有 `read`，`REINSTALL=1` 允许覆盖已存在的同名服务。

## 用法

```bash
bash <(curl -fsSL <脚本URL>)
```

必须 root 运行。

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

## 万一 dl.nyafw.com 不通

如果本机连不上 Cloudflare（`dl.nyafw.com`），可以走 HTTPS 代理（脚本里的 install 子脚本会继承）：

```bash
HTTPS_PROXY=http://your-proxy:port \
  bash <(curl -fsSL <URL>)
```
