#!/usr/bin/env bash
# 一键脚本：SSH 到目标机器，安装 nyanpass nodeclient (yuwan) 并做内核网络调优
#
# 用法（本地）:
#   ./yuwan.sh <IP> <PASSWORD>
#
# 用法（远程）:
#   bash <(curl -fsSL https://raw.githubusercontent.com/inifcloud/inifcloudsh/main/yuwan.sh) <IP> <PASSWORD>
#
# 例：
#   ./yuwan.sh 202.155.155.254 'wasd123yuwan/'

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "用法: $0 <IP> <PASSWORD>" >&2
  exit 1
fi

HOST="$1"
PASS="$2"
USER="${SSH_USER:-root}"
PORT="${SSH_PORT:-22}"

NYP_TOKEN="3c0a68ec-9ce5-4811-8214-e52994407caf"
NODE_NAME="yuwan"

ensure_sshpass() {
  if command -v sshpass >/dev/null 2>&1; then return; fi
  echo "[*] 本机未检测到 sshpass，尝试自动安装..."
  case "$(uname -s)" in
    Darwin)
      command -v brew >/dev/null 2>&1 || { echo "请先安装 Homebrew: https://brew.sh" >&2; exit 1; }
      brew install hudochenkov/sshpass/sshpass
      ;;
    Linux)
      if   command -v apt-get >/dev/null 2>&1; then sudo apt-get update -y && sudo apt-get install -y sshpass
      elif command -v yum     >/dev/null 2>&1; then sudo yum     install -y sshpass
      elif command -v dnf     >/dev/null 2>&1; then sudo dnf     install -y sshpass
      elif command -v apk     >/dev/null 2>&1; then sudo apk add --no-cache sshpass
      elif command -v pacman  >/dev/null 2>&1; then sudo pacman -S --noconfirm sshpass
      else echo "未识别的 Linux 发行版，请手动安装 sshpass" >&2; exit 1
      fi
      ;;
    *) echo "未支持的平台，请手动安装 sshpass" >&2; exit 1 ;;
  esac
}
ensure_sshpass

echo "[*] 连接 ${USER}@${HOST}:${PORT} ..."

sshpass -p "$PASS" ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o ConnectTimeout=15 \
  -p "$PORT" "${USER}@${HOST}" \
  "NODE_NAME='${NODE_NAME}' NYP_TOKEN='${NYP_TOKEN}' bash -s" <<'REMOTE'
set -e

echo "[远端] 1/2 安装 nyanpass nodeclient (${NODE_NAME}) ..."
printf '%s\nn\nn\n' "${NODE_NAME}" | bash <(curl -fLSs https://dispatch.nyafw.com/download/nyanpass-install.sh) \
  rel_nodeclient "-t ${NYP_TOKEN} -u https://nyp.pccwg.us"

echo "[远端] 2/2 写入 sysctl 调优 ..."
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

echo "[远端] 完成 ✓"
REMOTE

echo "[*] 全部完成 ✓"
