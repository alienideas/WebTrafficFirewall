What this script does
This script creates a full blackout for any IP/CIDR that is uncommented in your restricted_ips.txt file.

It blocks all ports (80, 443, 25, 110, SSH, etc.)
It only affects the IPs that are not commented with #
It is designed to be relatively safe (doesn’t flush your whole firewall)


Section-by-Section Explanation
1. Configuration
BashIP_LIST="/path/to/your/restricted_ips.txt"
CHAIN_NAME="FULL_BLACKOUT"

You set the path to your IP list.
It creates its own separate chain called FULL_BLACKOUT so it doesn’t mess with other rules.

2. Safety Checks

Checks if the IP list file exists.
Checks whether the script has permission to manage the firewall.
If you’re on shared hosting (no permission), it exits safely without doing anything.

3. Firewall Detection
It automatically detects which firewall is available, in this order:

ufw
nftables
iptables

4. Reading the IP List
Bashget_ips() {
    grep -v '^\s*#' "$IP_LIST" | grep -v '^\s*$' | sed 's/\s//g'
}

Ignores empty lines
Ignores lines starting with # (commented countries)
Only uses the uncommented CIDRs


How it blocks (depending on firewall)

Important Behavior

Established connections are allowed first (ESTABLISHED,RELATED). This prevents breaking already open connections.
The script only adds/updates its own chain. It does not flush your entire firewall.
It inserts its chain at the top of the INPUT chain so the blackout rules are evaluated early.


Limitations

Removing a countryYou must re-run the script after commenting the IPs

Summary
This script is designed to:

Read your restricted_ips.txt
Take only the uncommented IPs/CIDRs
Completely block those IPs from accessing any service on the server
Work automatically with iptables / nftables / ufw
Stay as safe as possible (won’t destroy existing firewall rules)
