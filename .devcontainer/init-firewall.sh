#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'      # Stricter word splitting

# --- 関数定義 ---
# ドメイン名を解決してIPセットに追加する関数
resolve_and_add_to_set() {
    local ipset_name="$1"
    local domain="$2"
    echo "Resolving and adding '$domain' to '$ipset_name'..."
    local ips
    ips=$(dig +short A "$domain" 2>/dev/null || true)
    if [ -n "$ips" ]; then
        while read -r ip; do
            if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                echo "  -> Adding IP: $ip"
                ipset add -exist "$ipset_name" "$ip"
            fi
        done < <(echo "$ips")
    else
        echo "  WARNING: Failed to resolve '$domain', skipping..."
    fi
} # ★★★★★ 関数定義の正しい終了位置 ★★★★★

# --- 初期化 ---
echo "Flushing existing firewall rules and ipsets..."
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
ipset destroy allowed-inbound 2>/dev/null || true
ipset destroy allowed-outbound 2>/dev/null || true
ipset destroy blocked-domains 2>/dev/null || true

# --- IPセットの作成 ---
echo "Creating new ipsets..."
ipset create allowed-inbound hash:net
ipset create allowed-outbound hash:net
ipset create blocked-domains hash:net

# --- 基本的な許可ルール (INPUT/OUTPUT共通) ---
echo "Setting up basic access rules (localhost, DNS)..."
# localhost (最優先で許可するため -I オプションで先頭にルールを挿入)
iptables -I INPUT 1 -i lo -j ACCEPT
iptables -I OUTPUT 1 -o lo -j ACCEPT
# DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT
# 確立済みの接続
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# --- INPUTルール (インバウンド) ---
echo "Setting up INPUT rules (whitelist for inbound)..."
HOST_IP=$(ip route | grep default | cut -d" " -f3)
if [ -z "$HOST_IP" ]; then
    echo "ERROR: Failed to detect host IP"
    exit 1
fi
HOST_NETWORK=$(echo "$HOST_IP" | sed "s/\.[0-9]*$/.0\/24/")
echo "Host network detected as: $HOST_NETWORK"
ipset add -exist allowed-inbound "$HOST_NETWORK"

iptables -A INPUT -m set --match-set allowed-inbound src -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -m set --match-set allowed-inbound src -j ACCEPT
iptables -A INPUT -p icmp -m set --match-set allowed-inbound src -j ACCEPT

# --- OUTPUTルール (アウトバウンド) ---
echo "Setting up OUTPUT rules (allow essential -> block unwanted)..."

# 1. 最初に許可したいドメインを `allowed-outbound` に追加
echo "[Phase 1] Populating outbound allow-list..."
for domain in \
    "github.com" \
    "api.github.com" \
    "anthropic.com" \
    "api.anthropic.com" \
    "pypi.org" \
    "files.pythonhosted.org"; do
    resolve_and_add_to_set "allowed-outbound" "$domain"
done

# 2. 許可リストへの通信を許可するルールをiptablesに追加
iptables -A OUTPUT -m set --match-set allowed-outbound dst -j ACCEPT

# 3. 次にブロックしたいドメインを `blocked-domains` に追加
echo "[Phase 2] Populating outbound block-list..."
# 予約済み/特殊なネットワーク範囲
for blocked_network in \
    "0.0.0.0/8" "127.0.0.0/8" "169.254.0.0/16" "224.0.0.0/4" "240.0.0.0/4"; do
    echo "Adding blocked network: $blocked_network"
    ipset add -exist blocked-domains "$blocked_network"
done
# ブロックしたいドメイン
for domain in \
    "facebook.com" "twitter.com" "tiktok.com" "instagram.com" \
    "doubleclick.net" "googleadservices.com" "googlesyndication.com"; do
    resolve_and_add_to_set "blocked-domains" "$domain"
done

# 4. ブロックリストへの通信を拒否するルールをiptablesに追加
iptables -A OUTPUT -m set --match-set blocked-domains dst -j DROP

# --- デフォルトポリシーの設定 ---
echo "Setting default policies..."
iptables -P INPUT   DROP
iptables -P FORWARD DROP
iptables -P OUTPUT  ACCEPT

# --- 設定完了と確認 ---
echo "Firewall configuration complete."
echo "=============================="
echo "INPUT Policy: DROP, OUTPUT Policy: ACCEPT (with exceptions)"
echo "Outbound traffic to essential services (GitHub/Anthropic) is explicitly allowed."
echo "Outbound traffic to blacklisted domains is blocked."
echo "All other outbound traffic is allowed."