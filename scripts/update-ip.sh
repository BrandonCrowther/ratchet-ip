#!/bin/bash

# Ratchet IP - Dynamic DNS updater for AWS Route53
# This script checks the current public IP and updates Route53 if it has changed

set -euo pipefail

# Configuration
IP_FILE="/var/ratchet-ip/current_ip.txt"
DNS_TTL="${DNS_TTL:-300}"

# Log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Get current public IP
get_public_ip() {
    local ip
    ip=$(curl -s https://checkip.amazonaws.com)
    if [ -z "$ip" ]; then
        log "ERROR: Failed to retrieve public IP"
        exit 1
    fi
    echo "$ip"
}

# Read stored IP from file
get_stored_ip() {
    if [ -f "$IP_FILE" ]; then
        cat "$IP_FILE"
    else
        echo ""
    fi
}

# Update a single Route53 record
update_route53_record() {
    local record_name=$1
    local new_ip=$2

    log "Updating Route53 record: $record_name -> $new_ip"

    # Create the change batch JSON
    local change_batch=$(cat <<EOF
{
    "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
            "Name": "$record_name",
            "Type": "A",
            "TTL": $DNS_TTL,
            "ResourceRecords": [{"Value": "$new_ip"}]
        }
    }]
}
EOF
)

    # Execute the Route53 change
    local change_info
    change_info=$(aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch "$change_batch" \
        --output json 2>&1)

    if [ $? -eq 0 ]; then
        local change_id=$(echo "$change_info" | grep -o '"Id": "[^"]*"' | cut -d'"' -f4)
        log "  ✓ Route53 update successful. Change ID: $change_id"
        return 0
    else
        log "  ✗ ERROR: Route53 update failed for $record_name"
        log "  $change_info"
        return 1
    fi
}

# Update all Route53 records
update_all_records() {
    local new_ip=$1
    local all_success=0

    # Split comma-separated DNS_RECORD_NAMES into array
    IFS=',' read -ra RECORDS <<< "$DNS_RECORD_NAMES"

    log "Updating ${#RECORDS[@]} DNS record(s)..."

    for record in "${RECORDS[@]}"; do
        # Trim whitespace
        record=$(echo "$record" | xargs)

        if update_route53_record "$record" "$new_ip"; then
            continue
        else
            all_success=1
        fi
    done

    return $all_success
}

# Main logic
main() {
    log "Starting IP check..."

    # Get current public IP
    local current_ip
    current_ip=$(get_public_ip)
    log "Current public IP: $current_ip"

    # Get stored IP
    local stored_ip
    stored_ip=$(get_stored_ip)

    if [ -z "$stored_ip" ]; then
        log "No stored IP found. This is the first run."
        log "Updating Route53 with initial IP..."
        if update_all_records "$current_ip"; then
            echo "$current_ip" > "$IP_FILE"
            log "Initial IP saved: $current_ip"
        fi
    elif [ "$current_ip" != "$stored_ip" ]; then
        log "IP address changed!"
        log "  Old IP: $stored_ip"
        log "  New IP: $current_ip"
        if update_all_records "$current_ip"; then
            echo "$current_ip" > "$IP_FILE"
            log "IP file updated with new address"
        fi
    else
        log "IP address unchanged: $current_ip"
        log "No update needed."
    fi

    log "IP check complete."
}

# Run main function
main
