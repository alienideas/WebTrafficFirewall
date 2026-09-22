#!/bin/bash

# ============================================================
# Full Country/IP Blackout Script (Safe & Dynamic)
# Blocks ALL ports/services for uncommented IPs in the list
# ============================================================

# ====== CONFIGURATION ======
IP_LIST="/path/to/your/restricted_ips.txt"   # ← Change this to your file
CHAIN_NAME="FULL_BLACKOUT"
# ===========================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Starting full blackout update...${NC}"

# Check file
if [[ ! -f "$IP_LIST" ]]; then
    echo -e "${RED}Error: File not found → $IP_LIST${NC}"
    exit 1
fi

# Permission check
has_permission() {
    if command -v iptables >/dev/null 2>&1; then
        iptables -L -n >/dev/null 2>&1 && return 0
    fi
    if command -v nft >/dev/null 2>&1; then
        nft list ruleset >/dev/null 2>&1 && return 0
    fi
    return 1
}

if ! has_permission; then
    echo -e "${RED}No firewall permission (common on shared hosting). Exiting safely.${NC}"
    exit 0
fi

# Detect firewall
FIREWALL=""
if command -v ufw >/dev/null 2>&1 && ufw status 2>/dev/null | grep -q "Status: active"; then
    FIREWALL="ufw"
elif command -v nft >/dev/null 2>&1 && nft list ruleset >/dev/null 2>&1; then
    FIREWALL="nftables"
elif command -v iptables >/dev/null 2>&1; then
    FIREWALL="iptables"
else
    echo -e "${RED}No supported firewall found.${NC}"
    exit 1
fi

echo -e "Detected: ${GREEN}$FIREWALL${NC}"

# Read only uncommented lines
get_ips() {
    grep -v '^\s*#' "$IP_LIST" | grep -v '^\s*$' | sed 's/\s//g'
}

# --------------------------------------------------
# IPTABLES - Full block
# --------------------------------------------------
apply_iptables() {
    iptables -N $CHAIN_NAME 2>/dev/null || true
    iptables -F $CHAIN_NAME

    # Important: allow established connections first
    iptables -A $CHAIN_NAME -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN

    while read -r ip; do
        [[ -z "$ip" ]] && continue
        iptables -A $CHAIN_NAME -s "$ip" -j DROP
    done < <(get_ips)

    # Insert our chain at the top of INPUT (only once)
    if ! iptables -C INPUT -j $CHAIN_NAME 2>/dev/null; then
        iptables -I INPUT -j $CHAIN_NAME
    fi

    echo -e "${GREEN}iptables full blackout applied.${NC}"
}

# --------------------------------------------------
# NFTABLES - Full block
# --------------------------------------------------
apply_nftables() {
    nft add table inet blackout 2>/dev/null || true
    nft add chain inet blackout $CHAIN_NAME { type filter hook input priority -100 \; policy accept \; } 2>/dev/null || true

    nft flush chain inet blackout $CHAIN_NAME

    while read -r ip; do
        [[ -z "$ip" ]] && continue
        nft add rule inet blackout $CHAIN_NAME ip saddr $ip drop
    done < <(get_ips)

    echo -e "${GREEN}nftables full blackout applied.${NC}"
}

# --------------------------------------------------
# UFW - Full block (best effort)
# --------------------------------------------------
apply_ufw() {
    echo -e "${YELLOW}UFW mode: applying deny from rules...${NC}"

    while read -r ip; do
        [[ -z "$ip" ]] && continue
        ufw deny from "$ip" comment "FullBlackout" 2>/dev/null || true
    done < <(get_ips)

    echo -e "${GREEN}UFW rules applied (best effort).${NC}"
    echo -e "${YELLOW}Note: UFW does not easily remove old rules automatically.${NC}"
}

# Execute
case $FIREWALL in
    iptables)  apply_iptables ;;
    nftables)  apply_nftables ;;
    ufw)       apply_ufw ;;
esac

echo -e "${GREEN}Done. All ports are now blocked for the uncommented IPs.${NC}"
