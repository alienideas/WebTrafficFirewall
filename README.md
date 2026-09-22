# WebTrafficFirewall
WebTrafficFirewall  Web Application Firewall country specific firewall
# Full Country/IP Blackout Script

**Dynamic Linux Firewall Country Blocker**

---

## About this

This is a safe and dynamic Linux bash script designed to **block entire countries or specific IP ranges** at the firewall level. It reads a simple text file containing CIDR ranges (with support for commented lines) and automatically applies a **full port blackout** for all uncommented IPs. The script is useful for developers and system administrators who need to **block country by IP**, create a **firewall country blacklist**, implement **iptables country block**, **nftables geo block**, or enforce a **full service blackout** against unwanted regions. It supports dynamic reloading, works with iptables, nftables, and UFW, and is intended for VPS and dedicated servers where full network-level restriction is required.

---

## Features

- Full blackout of **all ports** (80, 443, 25, 110, SSH, and others)
- Reads IPs/CIDRs from a plain text file
- Supports commented lines (`#`) — only uncommented entries are blocked
- Automatically detects firewall type (`iptables`, `nftables`, or `ufw`)
- Creates its own dedicated chain (does not destroy existing rules)
- Safe permission detection (exits cleanly on shared hosting)
- Can be run multiple times safely (idempotent)
- Easy to update — just edit the text file and re-run the script

---

## Requirements

- Linux server (VPS or Dedicated recommended)
- Root or sudo privileges
- One of the following firewalls installed:
  - `iptables`
  - `nftables`
  - `ufw`
- A text file containing IP ranges in CIDR format

> **Note:** This script will **not** work on most shared hosting environments because users usually do not have permission to manage firewall rules.

---

## Installation

1. Download or copy the script to your server:

```bash
nano full-blackout.sh

Paste the script content and save the file.
Make it executable:

Bashchmod +x full-blackout.sh

Edit the configuration section inside the script:

BashIP_LIST="/path/to/your/restricted_ips.txt"
CHAIN_NAME="FULL_BLACKOUT"

IP List Format
Create a file (example: restricted_ips.txt) with the following format:
text# ==================================================
# COUNTRY: CN
# ==================================================
# 1.0.1.0/24
# 1.0.2.0/23

# ==================================================
# COUNTRY: RU
# ==================================================
5.1.0.0/16
5.2.0.0/16
31.13.0.0/16

Lines starting with # are ignored
Empty lines are ignored
Only uncommented CIDRs will be blocked


Usage
Run the script with root privileges:
Bashsudo ./full-blackout.sh
Updating the Block List

Edit your restricted_ips.txt file (comment or uncomment countries/CIDRs)
Run the script again:

Bashsudo ./full-blackout.sh
The script will update the firewall rules automatically.

How It Works

Checks if the IP list file exists
Verifies whether the user has permission to manage the firewall
Detects the active firewall in this order: ufw → nftables → iptables
Reads only uncommented CIDRs from the list
Creates or updates a dedicated firewall chain
Drops all traffic from the listed IPs/CIDRs
Inserts the custom chain into the main INPUT chain (only once)


Supported Firewalls

























FirewallSupport LevelBehavioriptablesFullCreates a custom chain and applies DROP rulesnftablesFullCreates a dedicated table/chain and applies drop rulesufwBest effortAdds ufw deny from rules for each IP

Safety Notes

The script never flushes your entire firewall
It only manages its own custom chain
Existing rules and default policies remain untouched
Established connections are allowed before new connections are dropped
On systems without sufficient permissions, the script exits safely without making any changes


Limitations

Does not work on most shared hosting plans
UFW mode does not automatically remove old rules when IPs are commented out
Very large lists (tens of thousands of CIDRs) may impact firewall performance
IPv6 is not supported in the current version


Example Output
BashStarting full blackout update...
Detected: iptables
iptables full blackout applied.
Done. All ports are now blocked for the uncommented IPs.

License
This script is released under the MIT License.
You are free to use, modify, and distribute it for both personal and commercial projects.

Disclaimer
This tool is provided as-is. Incorrect firewall configuration can lock you out of your server. Always test on a non-production environment first and make sure you have alternative access (such as console/VNC) before applying full blackout rules.
