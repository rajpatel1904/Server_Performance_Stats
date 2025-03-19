#!/bin/bash

# server-stats.sh - A script to analyze basic server performance statistics
# Created: March 19, 2025

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print header with styling
print_header() {
    echo -e "\n${BLUE}===== $1 =====${NC}\n"
}

# Function to convert values to readable format
readable_size() {
    # Convert bytes to human-readable format
    local size=$1
    local power=0
    local units=('B' 'KB' 'MB' 'GB' 'TB')
    
    while [[ $size -ge 1024 && $power -lt ${#units[@]}-1 ]]; do
        size=$(echo "scale=2; $size/1024" | bc)
        ((power++))
    done
    
    printf "%.2f %s" $size "${units[$power]}"
}

# Function to display colored percentages
colored_percentage() {
    local percentage=$1
    
    if [[ $(echo "$percentage < 70" | bc) -eq 1 ]]; then
        echo -e "${GREEN}${percentage}%${NC}"
    elif [[ $(echo "$percentage < 85" | bc) -eq 1 ]]; then
        echo -e "${YELLOW}${percentage}%${NC}"
    else
        echo -e "${RED}${percentage}%${NC}"
    fi
}

# Display script banner
echo -e "${GREEN}"
echo "  _____                            _____ _        _       "
echo " / ____|                          / ____| |      | |      "
echo "| (___   ___ _ ____   _____ _ __| (___ | |_ __ _| |_ ___ "
echo " \___ \ / _ \ '__\ \ / / _ \ '__|\___ \| __/ _\` | __/ __|"
echo " ____) |  __/ |   \ V /  __/ |   ____) | || (_| | |_\__ \\"
echo "|_____/ \___|_|    \_/ \___|_|  |_____/ \__\__,_|\__|___/"
echo -e "${NC}"
echo -e "Server Performance Statistics Tool - $(date)"
echo -e "--------------------------------------------\n"

# OS VERSION INFORMATION
print_header "System Information"
echo -e "Hostname:\t\t$(hostname)"
if [ -f /etc/os-release ]; then
    echo -e "OS:\t\t\t$(grep -w "PRETTY_NAME" /etc/os-release | cut -d= -f2 | tr -d '"')"
elif [ -f /etc/redhat-release ]; then
    echo -e "OS:\t\t\t$(cat /etc/redhat-release)"
else
    echo -e "OS:\t\t\tUnable to determine"
fi

echo -e "Kernel:\t\t\t$(uname -r)"
echo -e "Architecture:\t\t$(uname -m)"

# UPTIME AND LOAD AVERAGE
print_header "System Uptime and Load"
uptime_output=$(uptime)
echo -e "Uptime:\t\t\t$(uptime -p)"
echo -e "Load Average (1,5,15):\t$(uptime | grep -ohe 'load average[s:][: ].*' | awk '{ print $3" "$4" "$5 }')"

# CPU INFORMATION
print_header "CPU Usage"

# Get the number of CPU cores
cpu_cores=$(grep -c "processor" /proc/cpuinfo)
echo -e "CPU Cores:\t\t$cpu_cores"

# CPU usage using top (non-interactive mode)
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
cpu_percentage=$(printf "%.1f" $cpu_usage)

echo -e "Total CPU Usage:\t$(colored_percentage $cpu_percentage)"

# MEMORY USAGE
print_header "Memory Usage"

# Parse memory info
mem_total=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
mem_free=$(grep "MemFree" /proc/meminfo | awk '{print $2}')
mem_available=$(grep "MemAvailable" /proc/meminfo | awk '{print $2}')
mem_buffers=$(grep "Buffers" /proc/meminfo | awk '{print $2}')
mem_cached=$(grep "Cached" /proc/meminfo | awk '{print $2}' | head -1)

# Calculate actual used memory (accounting for buffers/cache)
mem_used=$((mem_total - mem_available))
mem_usage_percentage=$(echo "scale=1; ($mem_used * 100) / $mem_total" | bc)

# Convert to human-readable format
mem_total_hr=$(echo "scale=2; $mem_total/1024" | bc)
mem_used_hr=$(echo "scale=2; $mem_used/1024" | bc)
mem_available_hr=$(echo "scale=2; $mem_available/1024" | bc)

echo -e "Total Memory:\t\t${mem_total_hr} MB"
echo -e "Used Memory:\t\t${mem_used_hr} MB"
echo -e "Available Memory:\t${mem_available_hr} MB"
echo -e "Memory Usage:\t\t$(colored_percentage $mem_usage_percentage)"

# SWAP USAGE
swap_total=$(grep "SwapTotal" /proc/meminfo | awk '{print $2}')

if [ "$swap_total" != "0" ]; then
    swap_free=$(grep "SwapFree" /proc/meminfo | awk '{print $2}')
    swap_used=$((swap_total - swap_free))
    swap_percentage=$(echo "scale=1; ($swap_used * 100) / $swap_total" | bc)
    
    # Convert to human-readable format
    swap_total_hr=$(echo "scale=2; $swap_total/1024" | bc)
    swap_used_hr=$(echo "scale=2; $swap_used/1024" | bc)
    swap_free_hr=$(echo "scale=2; $swap_free/1024" | bc)
    
    echo -e "\nSwap Total:\t\t${swap_total_hr} MB"
    echo -e "Swap Used:\t\t${swap_used_hr} MB"
    echo -e "Swap Free:\t\t${swap_free_hr} MB"
    echo -e "Swap Usage:\t\t$(colored_percentage $swap_percentage)"
fi

# DISK USAGE
print_header "Disk Usage"

# Get filesystem information excluding virtual filesystems
df_output=$(df -h -x tmpfs -x devtmpfs -x squashfs 2>/dev/null)
echo "$df_output" | head -1
echo "$df_output" | tail -n +2 | sort -rn -k 5 | while read -r line; do
    # Extract the percentage and device name
    device=$(echo "$line" | awk '{print $1}')
    size=$(echo "$line" | awk '{print $2}')
    used=$(echo "$line" | awk '{print $3}')
    avail=$(echo "$line" | awk '{print $4}')
    usage_percent=$(echo "$line" | awk '{print $5}' | tr -d '%')
    mount=$(echo "$line" | awk '{print $6}')
    
    # Print with colored percentage
    formatted=$(printf "%-15s %-8s %-8s %-8s " "$device" "$size" "$used" "$avail")
    echo -e "$formatted$(colored_percentage $usage_percent) $mount"
done

# TOP PROCESSES BY CPU USAGE
print_header "Top 5 Processes by CPU Usage"
echo -e "PID\tCPU%\tMEM%\tCMD"
ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "%-7s %-7s %-7s %s\n", $2, $3, $4, $11}'

# TOP PROCESSES BY MEMORY USAGE
print_header "Top 5 Processes by Memory Usage"
echo -e "PID\tCPU%\tMEM%\tCMD"
ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "%-7s %-7s %-7s %s\n", $2, $3, $4, $11}'

# LOGGED IN USERS
print_header "Currently Logged In Users"
who | awk '{print $1, $2, $3, $4, $5}' | column -t

# RECENT FAILED LOGIN ATTEMPTS (last 10)
if [ -f /var/log/auth.log ]; then
    print_header "Recent Failed Login Attempts"
    grep "Failed password" /var/log/auth.log | tail -10
elif [ -f /var/log/secure ]; then
    print_header "Recent Failed Login Attempts"
    grep "Failed password" /var/log/secure | tail -10
fi

# NETWORK CONNECTIONS
print_header "Network Connection Summary"
echo -e "Active Internet connections (established only):"
netstat -tunapl 2>/dev/null | grep ESTABLISHED | awk '{print $5, $6, $7}' | 
    sort | uniq -c | sort -nr | head -5 |
    awk '{printf "%-5s %-40s %-15s %s\n", $1, $2, $3, $4}'

# RECENT SYSTEM MESSAGES (last 5)
print_header "Recent System Messages"
dmesg | tail -5

echo -e "\n${BLUE}Script completed at: $(date)${NC}"
echo -e "${YELLOW}NOTE: Some statistics may require root privileges to display properly.${NC}\n"




