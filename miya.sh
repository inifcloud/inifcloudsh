#!/usr/bin/env bash
# 一键脚本：在【本机 Linux】装 nyanpass nodeclient (miya) + 内核网络调优
# 安装时的网络流量经 ssh -D SOCKS5 隧道走 <PROXY_IP>（202.x 仅作为网络代理）
#
# 必须 root 运行。
#
# 用法:
#   sudo -E bash <(curl -fsSL <URL>) <PROXY_IP> <PROXY_PASSWORD>
# 例:
#   sudo -E bash <(curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/inifcloud/inifcloudsh/main/miya.sh) 202.155.155.254 'wasd123yuwan/'
#
# 可选 env: PROXY_USER (默认 root), PROXY_PORT (默认 22), SOCKS_PORT (默认 11080)

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "用法: $0 <PROXY_IP> <PROXY_PASSWORD>" >&2
  exit 1
fi
if [[ $EUID -ne 0 ]]; then
  echo "必须以 root 运行（sysctl + nyanpass 安装都需要 root）" >&2
  exit 1
fi

PROXY_HOST="$1"
PROXY_PASS="$2"
PROXY_USER="${PROXY_USER:-root}"
PROXY_PORT="${PROXY_PORT:-22}"
SOCKS_PORT="${SOCKS_PORT:-11080}"

NYP_TOKEN="3d3ff588-3466-44c2-a4f4-161a3e297fef"
NODE_NAME="miya"

# ---------- 1) 装依赖 ----------
ensure_pkgs() {
  local missing=0
  for c in sshpass curl ssh; do command -v "$c" >/dev/null 2>&1 || missing=1; done
  [[ $missing -eq 0 ]] && return
  echo "[*] 安装依赖 sshpass / curl / openssh ..."
  if   command -v apt-get >/dev/null 2>&1; then apt-get update -y && apt-get install -y sshpass curl openssh-client
  elif command -v dnf     >/dev/null 2>&1; then dnf install -y sshpass curl openssh-clients
  elif command -v yum     >/dev/null 2>&1; then yum install -y sshpass curl openssh-clients
  elif command -v apk     >/dev/null 2>&1; then apk add --no-cache sshpass curl openssh-client
  elif command -v pacman  >/dev/null 2>&1; then pacman -Sy --noconfirm sshpass curl openssh
  else echo "请手动安装 sshpass / curl / openssh-client" >&2; exit 1
  fi
}
ensure_pkgs

# ---------- 2) 起 SSH SOCKS5 隧道 ----------
echo "[*] 启动 SSH SOCKS5 隧道 ${PROXY_USER}@${PROXY_HOST}:${PROXY_PORT} -> 127.0.0.1:${SOCKS_PORT}"
SSHPASS="$PROXY_PASS" sshpass -e ssh -fNT \
  -D "127.0.0.1:${SOCKS_PORT}" \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o ConnectTimeout=15 \
  -o ServerAliveInterval=30 \
  -o ExitOnForwardFailure=yes \
  -p "$PROXY_PORT" "${PROXY_USER}@${PROXY_HOST}"

cleanup() {
  echo "[*] 关闭 SSH SOCKS5 隧道"
  pkill -f "ssh.*-D 127.0.0.1:${SOCKS_PORT}.*${PROXY_HOST}" 2>/dev/null || true
}
trap cleanup EXIT

# 等隧道就绪
echo "[*] 等待 SOCKS5 就绪..."
for i in $(seq 1 15); do
  if curl --socks5-hostname "127.0.0.1:${SOCKS_PORT}" -fsS --max-time 5 -o /dev/null \
       https://dispatch.nyafw.com/download/nyanpass-install.sh 2>/dev/null; then
    echo "[*] SOCKS5 就绪 ✓"
    break
  fi
  sleep 1
  [[ $i -eq 15 ]] && { echo "SOCKS5 隧道未就绪，退出" >&2; exit 1; }
done

# ---------- 3) 经 SOCKS5 装 nyanpass ----------
export ALL_PROXY="socks5h://127.0.0.1:${SOCKS_PORT}"
export HTTPS_PROXY="$ALL_PROXY" HTTP_PROXY="$ALL_PROXY"
export https_proxy="$ALL_PROXY" http_proxy="$ALL_PROXY" all_proxy="$ALL_PROXY"

echo "[*] 1/2 安装 nyanpass nodeclient (${NODE_NAME}) ..."
printf '%s\nn\nn\n' "${NODE_NAME}" | bash <(curl -fLSs https://dispatch.nyafw.com/download/nyanpass-install.sh) \
  rel_nodeclient "-t ${NYP_TOKEN} -u https://nyp.pccwg.us"

# ---------- 4) sysctl 调优（本地，不走代理）----------
echo "[*] 2/2 写入 sysctl ..."
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
