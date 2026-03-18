#!/bin/bash
set -e

echo "Starting Ratchet IP updater..."

# Validate required environment variables
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "ERROR: AWS_ACCESS_KEY_ID environment variable is not set"
    exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "ERROR: AWS_SECRET_ACCESS_KEY environment variable is not set"
    exit 1
fi

if [ -z "$HOSTED_ZONE_ID" ]; then
    echo "ERROR: HOSTED_ZONE_ID environment variable is not set"
    exit 1
fi

if [ -z "$DNS_RECORD_NAMES" ]; then
    echo "ERROR: DNS_RECORD_NAMES environment variable is not set"
    exit 1
fi

# Set default AWS region if not provided
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

echo "Configuration:"
echo "  DNS Records: $DNS_RECORD_NAMES"
echo "  Hosted Zone ID: $HOSTED_ZONE_ID"
echo "  AWS Region: $AWS_DEFAULT_REGION"

# Export environment variables to a file for cron to use
cat > /app/env.sh << EOF
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION"
export HOSTED_ZONE_ID="$HOSTED_ZONE_ID"
export DNS_RECORD_NAMES="$DNS_RECORD_NAMES"
export DNS_TTL="$DNS_TTL"
EOF

chmod 600 /app/env.sh

# Create crontab entry - run every 30 minutes
# Note: /etc/cron.d/ files require user field and must end with newline
cat > /etc/cron.d/ratchet-ip << 'CRONEOF'
*/30 * * * * root . /app/env.sh && /app/update-ip.sh >> /var/log/ratchet-ip.log 2>&1

CRONEOF

# Give execution rights on the cron job
chmod 0644 /etc/cron.d/ratchet-ip

# Create log file
touch /var/log/ratchet-ip.log

# Run the update script once immediately on startup
echo "Running initial IP check..."
/app/update-ip.sh

# Start cron in the foreground and tail the log file to stdout
echo "Starting cron daemon..."
cron && tail -f /var/log/ratchet-ip.log
