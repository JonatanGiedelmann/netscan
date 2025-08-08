#!/bin/bash

# Trap Ctrl+C (SIGINT) to exit cleanly
trap ctrl_c INT

function ctrl_c() {
    echo -e "\n\033[1;31mScan aborted by user!\033[0m"
    echo -e "\033[1;33mPartial results:\033[0m"
    echo -e "\033[1;32mActive hosts found:\033[0m $active_hosts"
    echo -e "\033[1;32mScanned hosts:\033[0m $scanned_count/$hosts_to_scan"
    exit 1
}

# Display NETSCAN ASCII art logo and slogan
echo -e "\033[1;36m
  ███╗   ██╗███████╗████████╗███████╗ ██████╗ █████╗ ███╗   ██╗
  ████╗  ██║██╔════╝╚══██╔══╝██╔════╝██╔════╝██╔══██╗████╗  ██║
  ██╔██╗ ██║█████╗     ██║   ███████╗██║     ███████║██╔██╗ ██║
  ██║╚██╗██║██╔══╝     ██║   ╚════██║██║     ██╔══██║██║╚██╗██║
  ██║ ╚████║███████╗   ██║   ███████║╚██████╗██║  ██║██║ ╚████║
  ╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝
  \033[1;33mNetwork Discovery Tool - Ping Your Way Through the Network\033[0m
"

# Function to calculate network address
calculate_network() {
    local ip=$1
    local cidr=$2
    IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
    
    # Convert to integer
    ip_int=$(( (o1 << 24) + (o2 << 16) + (o3 << 8) + o4 ))
    
    # Create netmask
    mask=$((0xFFFFFFFF << (32 - cidr) & 0xFFFFFFFF))
    
    # Calculate network address
    net_int=$((ip_int & mask))
    
    # Convert back to dotted decimal
    echo "$(( (net_int >> 24) & 0xFF )).$(( (net_int >> 16) & 0xFF )).$(( (net_int >> 8) & 0xFF )).$(( net_int & 0xFF ))"
}

# List available interfaces
echo -e "\033[1;32mAvailable network interfaces:\033[0m"
ip -o link show | awk -F': ' '{print $2}' | sort -u
echo

# Get interface from user
read -p "Enter network interface [default: eth0]: " interface
interface=${interface:-eth0}

# Verify interface exists
if ! ip link show "$interface" &>/dev/null; then
    echo "Error: Interface $interface does not exist"
    exit 1
fi

# Get IP address information
ip_info=$(ip -o -4 addr show dev "$interface" | awk '{print $4}')
if [[ -z "$ip_info" ]]; then
    echo "Error: No IP address found on $interface"
    exit 1
fi

# Extract IP and CIDR
base_ip="${ip_info%/*}"
cidr="${ip_info#*/}"

# Show current configuration
echo -e "\n\033[1;32mCurrent interface configuration:\033[0m"
echo "  IP Address: $base_ip"
echo "  Subnet Mask: /$cidr"

# Get CIDR from user
while true; do
    read -p "Enter subnet prefix (CIDR 16-30) [default: $cidr]: " user_cidr
    user_cidr=${user_cidr:-$cidr}
    
    if [[ $user_cidr =~ ^[0-9]+$ ]] && [ $user_cidr -ge 16 ] && [ $user_cidr -le 30 ]; then
        cidr=$user_cidr
        break
    else
        echo "Invalid CIDR. Please enter a value between 16 and 30."
    fi
done

# Calculate network address
network=$(calculate_network "$base_ip" "$cidr")
echo -e "\n\033[1;32mScanning network:\033[0m $network/$cidr"

# Calculate number of hosts
host_bits=$((32 - cidr))
total_hosts=$((2 ** host_bits))
hosts_to_scan=$((total_hosts - 2))

# Confirm for large networks
if [ $hosts_to_scan -gt 1000 ]; then
    read -p "This will scan $hosts_to_scan hosts. Continue? [y/N] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
fi

# Convert network address to integer
IFS='.' read -r i1 i2 i3 i4 <<< "$network"
network_int=$(( (i1 << 24) + (i2 << 16) + (i3 << 8) + i4 ))

echo -e "\033[1;33mStarting scan... (Press Ctrl+C to stop)\033[0m"
active_hosts=0
scanned_count=0

# Scan all hosts in the subnet
for (( i = 1; i < total_hosts; i++ )); do
    # Skip network (0) and broadcast (last) addresses
    if [[ $i -eq 0 || $i -eq $((total_hosts - 1)) ]]; then
        continue
    fi
    
    # Calculate current IP
    ip_int=$((network_int + i))
    o1=$(( (ip_int >> 24) & 0xFF ))
    o2=$(( (ip_int >> 16) & 0xFF ))
    o3=$(( (ip_int >> 8) & 0xFF ))
    o4=$(( ip_int & 0xFF ))
    ip="$o1.$o2.$o3.$o4"
    
    # Ping with 0.2s timeout
    if ping -c1 -W0.2 -I "$interface" "$ip" &>/dev/null; then
        echo -e "\033[1;32m  Active:\033[0m $ip"
        ((active_hosts++))
    fi
    
    # Display progress
    ((scanned_count++))
    if (( scanned_count % 50 == 0 )); then
        percentage=$(( (scanned_count * 100) / hosts_to_scan ))
        echo -ne "\033[1;33mScanned: $scanned_count/$hosts_to_scan ($percentage%) - Found: $active_hosts\033[0m\r"
    fi
done

# Final report
echo -e "\n\n\033[1;36mScan complete!\033[0m"
echo -e "\033[1;32mActive hosts found:\033[0m $active_hosts"
echo -e "\033[1;32mScanned hosts:\033[0m $hosts_to_scan"
