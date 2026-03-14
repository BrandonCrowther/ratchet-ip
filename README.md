# Ratchet IP

A Docker-based dynamic DNS solution for AWS Route53 that automatically updates your DNS records when your home IP address changes. Perfect for homelabs and self-hosted services.

## Overview

Ratchet IP monitors your public IP address and automatically updates an AWS Route53 A record when it changes. This allows you to access your homelab using a consistent domain name even with a dynamic IP address from your ISP.

## Features

- Automatic IP detection using AWS's own service
- Intelligent updates (only updates Route53 when IP actually changes)
- Runs every 30 minutes via cron
- Minimal AWS IAM permissions (principle of least privilege)
- Docker-based for easy deployment
- Terraform infrastructure-as-code for AWS resources

## Prerequisites

- AWS Account with Route53 hosted zone
- Docker and Docker Compose
- Terraform
- Your domain's nameservers pointed to Route53

## Setup

### 1. Configure and Deploy Terraform

```bash
# Copy and edit terraform variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Route53 domain name and DNS record

# Deploy AWS infrastructure
terraform init
terraform apply
```

### 2. Configure and Start Docker

```bash
# Automatically configure .env from Terraform outputs
./configure-env.sh

# (Optional) Edit .env to customize DNS_RECORD_NAME or DNS_TTL

# Start the container
docker-compose up -d

# View logs to verify
docker-compose logs -f
```

You should see output like:
```
[2026-03-14 10:00:00] Starting IP check...
[2026-03-14 10:00:00] Current public IP: 203.0.113.45
[2026-03-14 10:00:00] Updating Route53 with initial IP...
[2026-03-14 10:00:01] Route53 update successful.
```

### 3. Stop the Container

```bash
docker-compose down
```

## How It Works

1. **Cron Schedule**: Every 30 minutes, the container runs the update script
2. **IP Detection**: Queries `https://checkip.amazonaws.com` for current public IP
3. **Comparison**: Compares current IP with stored IP from previous run
4. **Update**: If different (or first run), updates Route53 A record via AWS CLI
5. **Storage**: Saves new IP to `/var/ratchet-ip/current_ip.txt`

## Security

The Terraform module creates an IAM user with minimal permissions scoped to only your specified hosted zone:

- `route53:ListHostedZones` - List available hosted zones
- `route53:GetHostedZone` - Get hosted zone details
- `route53:ChangeResourceRecordSets` - Update DNS records (scoped to specific zone)
- `route53:ListResourceRecordSets` - List records in the zone
- `route53:GetChange` - Check status of DNS changes

## Troubleshooting

**Container won't start?**
- Check environment variables: `docker-compose config`
- Verify AWS credentials are correct

**DNS not updating?**
- Check logs: `docker-compose logs -f`
- Verify hosted zone name in terraform.tfvars matches your Route53 zone
- Ensure DNS record name includes the full domain

**Check current stored IP:**
```bash
docker-compose exec ratchet-ip cat /var/ratchet-ip/current_ip.txt
```

**Force immediate update:**
```bash
docker-compose exec ratchet-ip /app/update-ip.sh
```

## Customization

**Change update frequency:** Edit the cron schedule in `scripts/entrypoint.sh`

**Change DNS TTL:** Update `DNS_TTL` in `.env` (default: 300 seconds)

## File Structure

```
ratchet-ip/
├── main.tf                         # Root Terraform config (backend & module)
├── variables.tf                    # Terraform input variables
├── outputs.tf                      # Terraform outputs
├── terraform.tfvars.example        # Variable values template
├── configure-env.sh                # Auto-configure .env from Terraform outputs
├── Dockerfile                      # Container definition
├── docker-compose.yml              # Docker Compose configuration
├── .env.example                    # Environment variable template
├── scripts/
│   ├── entrypoint.sh              # Container startup script
│   └── update-ip.sh               # Main IP update logic
└── terraform/modules/
    └── route53-iam-user/          # Reusable Terraform module
        ├── main.tf                # IAM user and policy resources
        ├── variables.tf           # Module input variables
        └── outputs.tf             # Module outputs (credentials)
```

## License

MIT
