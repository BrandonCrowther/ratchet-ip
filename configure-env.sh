#!/bin/bash
set -euo pipefail

echo "Configuring .env from Terraform outputs..."

cp .env.example .env
echo "Created .env from .env.example"

# Get Terraform outputs
echo "Retrieving Terraform outputs..."
HOSTED_ZONE_ID=$(terraform output -raw hosted_zone_id)
DNS_RECORD_NAMES=$(terraform output -raw dns_record_names)
AWS_ACCESS_KEY_ID=$(terraform output -raw aws_access_key_id)
AWS_SECRET_ACCESS_KEY=$(terraform output -raw aws_secret_access_key)

# Update .env file with actual values
echo "Updating .env with Terraform outputs..."
sed -i "s|^HOSTED_ZONE_ID=.*|HOSTED_ZONE_ID=$HOSTED_ZONE_ID|g" .env
sed -i "s|^DNS_RECORD_NAMES=.*|DNS_RECORD_NAMES=$DNS_RECORD_NAMES|g" .env
sed -i "s|^AWS_ACCESS_KEY_ID=.*|AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID|g" .env
sed -i "s|^AWS_SECRET_ACCESS_KEY=.*|AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY|g" .env

echo ""
echo "Configuration applied:"
echo "  HOSTED_ZONE_ID: $HOSTED_ZONE_ID"
echo "  DNS_RECORD_NAMES: $DNS_RECORD_NAMES"
echo "  AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
echo "  AWS_SECRET_ACCESS_KEY: ****"
