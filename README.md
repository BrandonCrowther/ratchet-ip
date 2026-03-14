# Ratchet IP

Ratchet-Ip is a Docker-based dynamic DNS solution for AWS Route53 that automatically updates your DNS records when your home IP address changes.

Is this a good idea? Not really. Will it violate the terms of service of your ISP? Definitely. Is it really funny? Absolutely.

## Components

- A small Terraform module containing:
  - a single IAM user with permissions scoped to update your hosted zone only.
- A Docker container containing:
  - `awscli`
  - `cron`
- A bash script to periodically probe your ip address, and update your Route53 hosted zone when it changes.

## Features

- Automatic IP detection using AWS's own service
- Support for multiple DNS records (apex, wildcard, subdomains)
- Intelligent updates (only updates Route53 when IP actually changes)
- Runs every 30 minutes via cron
- Minimal AWS IAM permissions (principle of least privilege)
- Docker-based for easy deployment
- Terraform infrastructure-as-code for AWS resources

## Prerequisites

- AWS Account with Route53 hosted zone
- Docker and Docker Compose
- Terraform

## Setup

### 1. Configure and Deploy Terraform

```bash
# Copy and edit terraform variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Route53 domain name and DNS records

# Deploy AWS infrastructure
terraform init
terraform apply
```

### 2. Configure and Start Docker

```bash
# Automatically configure .env from Terraform outputs
./configure-env.sh

# Start the container
docker-compose up -d

# View logs to verify
docker-compose logs -f
```

You should see output like:

```
[2026-03-14 10:00:00] Starting IP check...
[2026-03-14 10:00:00] Current public IP: 203.0.113.45
[2026-03-14 10:00:00] Updating 2 DNS record(s)...
[2026-03-14 10:00:00] Updating Route53 record: home.example.com -> 203.0.113.45
[2026-03-14 10:00:01]   ✓ Route53 update successful. Change ID: /change/C123
[2026-03-14 10:00:01] Updating Route53 record: *.example.com -> 203.0.113.45
[2026-03-14 10:00:02]   ✓ Route53 update successful. Change ID: /change/C124
```

## How It Works

1. **Cron Schedule**: Every 30 minutes, the container runs the update script
2. **IP Detection**: Queries `https://checkip.amazonaws.com` for current public IP
3. **Comparison**: Compares current IP with stored IP from previous run
4. **Update**: If different (or first run), updates all configured Route53 A records via AWS CLI
5. **Storage**: Saves new IP to `/var/ratchet-ip/current_ip.txt`

## Security

The Terraform module creates an IAM user with minimal permissions scoped to only your specified hosted zone:

- `route53:ListHostedZones` - List available hosted zones
- `route53:GetHostedZone` - Get hosted zone details
- `route53:ChangeResourceRecordSets` - Update DNS records (scoped to specific zone)
- `route53:ListResourceRecordSets` - List records in the zone
- `route53:GetChange` - Check status of DNS changes

## Additional Commands

Kill the container

```bash
docker compose down -v
```

**Check current stored IP:**

```bash
docker-compose exec ratchet-ip cat /var/ratchet-ip/current_ip.txt
```

**Force immediate update:**

```bash
docker-compose exec ratchet-ip /app/update-ip.sh
```

## Customization

- **Change update frequency:** Edit the cron schedule in `scripts/entrypoint.sh` (TODO: parameterize this too)
- **Change DNS TTL:** Update `DNS_TTL` in `.env` (default: 300 seconds)
