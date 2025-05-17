#!/bin/bash

# Require script to run with sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run with sudo privileges."
    exec sudo "$0" "$@"
    exit
fi

# Logging directory
LOG_DIR="./netlogs"
mkdir -p "$LOG_DIR"

# Get the current date and time for log file naming
DATE=$(date +%F_%H%M)
LOG_FILE="$LOG_DIR/nettools_$DATE.log"

# Function to check if a command is installed, and if not, prompt to install
check_and_install() {
    command=$1
    package=$2
    if ! command -v "$command" &>/dev/null; then
        echo "Error: $command not found."
        read -rp "Do you want to install it? (y/N): " install_choice
        if [[ "$install_choice" == "y" || "$install_choice" == "Y" ]]; then
            sudo apt-get install -y "$package" && echo "$command installed successfully."
        else
            echo "$command is required. Exiting."
            exit 1
        fi
    fi
}

# Check for required tools
check_and_install "ping" "iputils-ping"
check_and_install "traceroute" "traceroute"
check_and_install "whois" "whois"
check_and_install "dig" "dnsutils"
check_and_install "ss" "iproute2"

# Function to display the main menu
display_menu() {
    echo "=== Network Tools Menu ==="
    echo "1) Ping a host"
    echo "2) Traceroute to a host"
    echo "3) Whois lookup"
    echo "4) DNS Lookup (dig)"
    echo "5) Reverse DNS Lookup"
    echo "6) Check open ports with netcat"
    echo "7) Check active connections (ss)"
    echo "8) Check interface IP addresses (ip addr)"
    echo "9) Run DNS Query Tool (Dig.sh)"
    echo "0) Exit"
    echo "============================"
}

# Function to log outputs
log_output() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Function to ping a host
ping_host() {
    clear
    echo "=== Ping a host ==="
    read -rp "Enter host or IP to ping: " host
    echo "Pinging $host..."
    ping -c 4 "$host" | tee -a "$LOG_FILE"
}

# Function to run traceroute
traceroute_host() {
    clear
    echo "=== Traceroute to a host ==="
    read -rp "Enter host for traceroute: " host
    echo "--- Traceroute to $host ---"
    traceroute "$host" | tee -a "$LOG_FILE"
}

# Function to run whois lookup
whois_lookup() {
    clear
    echo "=== Whois lookup ==="
    read -rp "Enter domain for Whois lookup: " domain
    whois "$domain" | tee -a "$LOG_FILE"
}

# Function to run DNS query (dig)
dns_query() {
    clear
    echo "=== DNS Lookup (dig) ==="
    read -rp "Enter domain for DNS lookup: " domain
    dig "$domain" | tee -a "$LOG_FILE"
}

# Function to reverse DNS lookup
reverse_dns_lookup() {
    clear
    echo "=== Reverse DNS Lookup ==="
    read -rp "Enter IP address for reverse lookup: " ip
    dig -x "$ip" | tee -a "$LOG_FILE"
}

# Function to check open ports with netcat
check_open_ports() {
    clear
    echo "=== Check open ports with netcat ==="
    read -rp "Enter IP address to check for open ports: " ip
    read -rp "Enter port range (e.g., 20-80): " port_range
    nc -zv "$ip" "$port_range" | tee -a "$LOG_FILE"
}

# Function to check active connections with ss
check_active_connections() {
    clear
    echo "=== Active Connections ==="
    ss -tuln | tee -a "$LOG_FILE"
}

# Function to display IP addresses for interfaces
check_ip_addresses() {
    clear
    echo "=== IP Addresses for Interfaces ==="
    ip addr show | tee -a "$LOG_FILE"
}

# Function to run the external Dig.sh script
run_dns_tool() {
    clear
    echo "=== Running DNS Query Tool (Dig.sh) ==="
    if [[ -f "./Dig.sh" ]]; then
        chmod +x ./Dig.sh
        ./Dig.sh | tee -a "$LOG_FILE"
    else
        echo "Error: Dig.sh not found!" | tee -a "$LOG_FILE"
    fi
}

# Main script loop
while true; do
    display_menu
    read -rp "Select an option [1-9]: " choice

    case "$choice" in
        1) ping_host ;;
        2) traceroute_host ;;
        3) whois_lookup ;;
        4) dns_query ;;
        5) reverse_dns_lookup ;;
        6) check_open_ports ;;
        7) check_active_connections ;;
        8) check_ip_addresses ;;
        9) run_dns_tool ;;
        0)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac

    echo "Press [Enter] to continue..."
    read -r
done
