#!/bin/bash

# Ensure the log directory exists
log_dir="/var/log/honeyfile_logs"
mkdir -p "$log_dir"

# Directory to place honeyfiles
honey_dir="/home/user/honeyfiles" # Change the directory path as needed

# Create honeyfiles with random content
generate_honeyfiles() {
    mkdir -p "$honey_dir"
    for i in {1..5}; do
        file_name="$honey_dir/confidential_$RANDOM.txt"
        fake_data=$(openssl rand -base64 32)  # Generate unique random string for each file
        echo "Sensitive information: $fake_data" > "$file_name"
        chmod 644 "$file_name"
    done
    echo "Honeyfiles created in $honey_dir."
}

# Monitor honeyfiles for access and dynamically respond to suspicious activity
monitor_honeyfiles() {
    inotifywait -m -e open --format '%w%f %T' --timefmt '%F %T' "$honey_dir" | while read file time; do
        # Capture the user who owns the file
        user=$(stat -c '%U' "$file")  # Use 'stat' to get file's user

        # Attempt to capture IP if accessed via a network
        ip=$(ss -tnp | grep "$pid" | awk '{print $5}' | cut -d':' -f1 | head -n 1)
        
         # Check if IP is not found or only 'Address' is displayed
        if [ -z "$ip" ] || [ "$ip" == "Address" ]; then
            ip="Local Access"
        fi
        
        echo "ALERT: $file was accessed at $time by IP: $ip, User: $user"
        send_email_alert "$file" "$time" "$ip" "$user"
        check_and_block_ip "$ip"
    done
}

# Send email alert
send_email_alert() {
    file="$1"
    time="$2"
    ip="$3"
    user="$4"
    subject="Honeyfile Access Alert"
    body="ALERT: The file $file was accessed at $time by IP: $ip, User: $user"
    echo "$body" | mail -s "$subject" scottchristophertrunzo@gmail.com # Change your.email@example.com to your real email
}

# Check if IP should be blocked and block if not on the allowed list
check_and_block_ip() {
    ip=$1
    # List of allowed IPs
    allowed_ips=("192.168.1.100" "192.168.1.101") # Update with your actual allowed IP addresses

    if [[ ! " ${allowed_ips[@]} " =~ " ${ip} " ]]; then
          # Block the IP using iptables
        sudo iptables -A INPUT -s "$ip" -j DROP
        echo "Blocked IP: $ip for unauthorized access." >> "$log_dir/honey_access_blocked.log"
    fi
    echo "$ip $time" >> /var/log/honey_access.log # Ensure the path to the log file is correct for your system
}

# Start the process
generate_honeyfiles
monitor_honeyfiles
