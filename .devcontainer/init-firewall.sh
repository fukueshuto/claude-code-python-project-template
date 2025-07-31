#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Flush existing rules and delete existing ipsets
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
ipset destroy blocked-domains 2>/dev/null || true
ipset destroy allowed-inbound 2>/dev/null || true

# First allow DNS and localhost before any restrictions
# Allow outbound DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
# Allow inbound DNS responses
iptables -A INPUT -p udp --sport 53 -j ACCEPT
# Allow localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Create ipsets
ipset create blocked-domains hash:net
ipset create allowed-inbound hash:net

# Get host IP from default route
HOST_IP=$(ip route | grep default | cut -d" " -f3)
if [ -z "$HOST_IP" ]; then
    echo "ERROR: Failed to detect host IP"
    exit 1
fi

HOST_NETWORK=$(echo "$HOST_IP" | sed "s/\.[0-9]*$/.0\/24/")
echo "Host network detected as: $HOST_NETWORK"

# Add local network to allowed inbound
ipset add allowed-inbound "$HOST_NETWORK"

# Add specific trusted networks for inbound access (customize as needed)
# Example: Add your office network, VPN ranges, etc.
# ipset add allowed-inbound "10.0.0.0/8"
# ipset add allowed-inbound "172.16.0.0/12"
# ipset add allowed-inbound "192.168.0.0/16"

echo "Setting up blocked domains (blacklist for outbound)..."

# Add domains/IPs to block for outbound traffic
# Add known malicious or unwanted domains/networks
for blocked_network in \
    "0.0.0.0/8" \
    "127.0.0.0/8" \
    "169.254.0.0/16" \
    "224.0.0.0/4" \
    "240.0.0.0/4"; do
    echo "Adding blocked network: $blocked_network"
    ipset add blocked-domains "$blocked_network"
done

# Resolve and block specific unwanted domains (examples)
for domain in \
    "facebook.com" \
    "twitter.com" \
    "tiktok.com" \
    "instagram.com" \
    "doubleclick.net" \
    "googleadservices.com" \
    "googlesyndication.com"; do
    echo "Resolving and blocking $domain..."
    ips=$(dig +short A "$domain" 2>/dev/null || true)
    if [ -n "$ips" ]; then
        while read -r ip; do
            if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                echo "Blocking $ip for $domain"
                ipset add blocked-domains "$ip"
            fi
        done < <(echo "$ips")
    else
        echo "WARNING: Failed to resolve $domain, skipping..."
    fi
done

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT  # Allow outbound by default

echo "Setting up INPUT rules (whitelist for inbound)..."

# Allow established and related connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow inbound from trusted networks only
iptables -A INPUT -m set --match-set allowed-inbound src -j ACCEPT

# Allow specific inbound services from trusted networks
# SSH (only from trusted networks)
iptables -A INPUT -p tcp --dport 22 -m set --match-set allowed-inbound src -j ACCEPT

# Add other services as needed (examples)
# HTTP/HTTPS (if running web server)
# iptables -A INPUT -p tcp --dport 80 -m set --match-set allowed-inbound src -j ACCEPT
# iptables -A INPUT -p tcp --dport 443 -m set --match-set allowed-inbound src -j ACCEPT

# ICMP (ping) from trusted networks only
iptables -A INPUT -p icmp -m set --match-set allowed-inbound src -j ACCEPT

echo "Setting up OUTPUT rules (blacklist for outbound)..."

# Block outbound traffic to blacklisted domains/IPs
iptables -A OUTPUT -m set --match-set blocked-domains dst -j DROP

# Log blocked outbound attempts (optional, comment out if too noisy)
# iptables -A OUTPUT -m set --match-set blocked-domains dst -j LOG --log-prefix "BLOCKED_OUT: "

# Allow all other outbound traffic (default policy is ACCEPT)

echo "Firewall configuration complete"
echo ""
echo "=== Configuration Summary ==="
echo "INPUT Policy: DROP (whitelist based)"
echo "OUTPUT Policy: ACCEPT (blacklist based)"
echo "FORWARD Policy: DROP"
echo ""
echo "Inbound whitelist networks:"
ipset list allowed-inbound | grep -E "^[0-9]" || echo "  (none configured)"
echo ""
echo "Outbound blacklist networks/IPs:"
ipset list blocked-domains | grep -E "^[0-9]" | head -10
echo "  ... (showing first 10 entries)"
echo ""

echo "Verifying firewall rules..."

# Test that we can still make outbound connections
if curl --connect-timeout 5 https://api.github.com/zen >/dev/null 2>&1; then
    echo "✓ Outbound access verified - able to reach GitHub API"
else
    echo "✗ WARNING: Unable to reach GitHub API"
fi

# Test that blocked domains are actually blocked
if curl --connect-timeout 3 https://facebook.com >/dev/null 2>&1; then
    echo "✗ WARNING: Blacklist may not be working - able to reach blocked domain"
else
    echo "✓ Blacklist verified - unable to reach blocked domain as expected"
fi

# Test DNS resolution
if nslookup google.com >/dev/null 2>&1; then
    echo "✓ DNS resolution working"
else
    echo "✗ WARNING: DNS resolution may be blocked"
fi

echo ""
echo "Firewall setup complete!"
echo ""
echo "To add more inbound trusted networks:"
echo "  ipset add allowed-inbound <network/cidr>"
echo ""
echo "To add more outbound blocked domains/IPs:"
echo "  ipset add blocked-domains <ip_or_network>"
echo ""
echo "To view current rules:"
echo "  iptables -L -n -v"
echo "  ipset list allowed-inbound"
echo "  ipset list blocked-domains"