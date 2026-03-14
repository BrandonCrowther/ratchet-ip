#!/bin/bash
set -euo pipefail

echo "Configuring .env from Terraform outputs..."

# Check if terraform has been initialized and applied
if [ ! -f "main.tf" ]; then
    echo "ERROR: This script must be run from the ratchet-ip project root"
    exit 1
fi

# Copy example .env if .env doesn't exist
if [ -f ".env" ]; then
    echo "WARNING: .env already exists. Creating backup at .env.backup"
    cp .env .env.backup
fi

cp .env.example .env
echo "Created .env from .env.example"

# Get Terraform outputs
echo "Retrieving Terraform outputs..."
HOSTED_ZONE_ID=$(terraform output -raw hosted_zone_id)
AWS_ACCESS_KEY_ID=$(terraform output -raw aws_access_key_id)
AWS_SECRET_ACCESS_KEY=$(terraform output -raw aws_secret_access_key)

# Update .env file with actual values
echo "Updating .env with Terraform outputs..."
sed -i "s|^HOSTED_ZONE_ID=.*|HOSTED_ZONE_ID=$HOSTED_ZONE_ID|g" .env
sed -i "s|^AWS_ACCESS_KEY_ID=.*|AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID|g" .env
sed -i "s|^AWS_SECRET_ACCESS_KEY=.*|AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY|g" .env

echo "✓ .env configured successfully!"
echo ""
echo "Configuration applied:"
echo "  HOSTED_ZONE_ID: $HOSTED_ZONE_ID"
echo "  AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
echo "  AWS_SECRET_ACCESS_KEY: ****"
echo ""
echo "Next steps:"
echo "  1. Review .env and update DNS_RECORD_NAME if needed"
echo "  2. Run: docker-compose up -d"
