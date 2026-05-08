#!/usr/bin/env bash
# yuwan.sh - 装 nyanpass nodeclient (yuwan) + 自定义 sysctl
#
# 直接走 dl.nyafw.com，绕过 dispatch.nyafw.com 的国家检测
# （dispatch 用 apple.com geo=cn 头判断，AWS 中国区会被误判为 CN，走慢镜像）。
# S=yuwan       走官方静默/无交互模式（跳过所有 read）
# REINSTALL=1   允许覆盖已存在的同名服务（避免半成品装上后 token 重复报错）
#
# 用法（root 运行）:
#   bash <(curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/inifcloud/inifcloudsh/main/miya.sh)

set -euo pipefail
[[ $EUID -ne 0 ]] && { echo "需 root 运行" >&2; exit 1; }

NYP_TOKEN="3d3ff588-3466-44c2-a4f4-161a3e297fef"
NODE_NAME="miya"

echo "[*] 1/2 安装 nyanpass nodeclient (${NODE_NAME})..."
S="$NODE_NAME" REINSTALL=1 bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) \
  rel_nodeclient "-t ${NYP_TOKEN} -u https://nyp.pccwg.us"

echo "[*] 2/2 写入自定义 sysctl..."
rm -rf /etc/sysctl.d/*
cat > /etc/sysctl.d/yuwan.conf <<'SYSCTL'
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq_pie

fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
fs.pipe-max-size = 1048576
fs.pipe-user-pages-hard = 0
fs.pipe-user-pages-soft = 0

net.core.somaxconn = 3276800
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_retries1 = 5
net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_orphan_retries = 3
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_max_tw_buckets = 4096
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_abort_on_overflow = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_stdurg = 0
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_frto = 2
net.ipv4.tcp_ecn = 1
net.ipv4.tcp_ecn_fallback = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_reordering = 300
net.ipv4.tcp_retrans_collapse = 0
net.ipv4.tcp_autocorking = 1
net.ipv4.tcp_low_latency = 0
net.ipv4.tcp_slow_start_after_idle = 1
net.ipv4.tcp_no_metrics_save = 0
net.ipv4.tcp_moderate_rcvbuf = 1
net.ipv4.tcp_tso_win_divisor = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_rfc1337 = 1

net.ipv4.ip_forward = 1
net.ipv4.route.gc_timeout = 100
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

net.core.netdev_max_backlog = 16384
net.core.netdev_budget = 600

net.core.optmem_max = 81920
net.core.wmem_default = 262144
net.core.wmem_max = 67108864
net.core.rmem_default = 262144
net.core.rmem_max = 67108864

net.ipv4.tcp_mem = 786432 2097152 3145728
net.ipv4.tcp_rmem = 4096 524288 67108864
net.ipv4.tcp_wmem = 4096 524288 67108864
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192
SYSCTL

echo '' > /etc/sysctl.conf
sysctl --system

echo "[*] 全部完成 ✓"
