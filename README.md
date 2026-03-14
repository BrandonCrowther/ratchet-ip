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

## Architecture

```
┌─────────────┐      ┌──────────────┐      ┌──────────────┐
│   Docker    │      │  checkip.    │      │   Route53    │
│  Container  │─────▶│ amazonaws.   │      │              │
│   (cron)    │      │     com      │      │              │
└─────────────┘      └──────────────┘      └──────────────┘
       │                                            ▲
       │                                            │
       └────────────────────────────────────────────┘
                  Update DNS if IP changed
```

## Prerequisites

- AWS Account with Route53 hosted zone
- Docker and Docker Compose
- Terraform (for AWS infrastructure setup)
- Your domain's nameservers pointed to Route53

## Setup

### 1. Configure Terraform Variables

Copy the example terraform variables file:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
hosted_zone_id   = "Z1234567890ABC"        # Your Route53 hosted zone ID
hosted_zone_name = "example.com"           # Your domain name
dns_record_name  = "home.example.com"      # The A record to update
iam_user_name    = "ratchet-ip-updater"    # IAM user name (optional)
```

### 2. Deploy AWS Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

After applying, retrieve the AWS credentials:

```bash
# Get the access key ID (shown in output)
terraform output aws_access_key_id

# Get the secret access key (sensitive)
terraform output -raw aws_secret_access_key
```

### 3. Configure Docker Environment

Copy the example environment file:

```bash
cd ..
cp .env.example .env
```

Edit `.env` with the Terraform outputs:

```bash
AWS_ACCESS_KEY_ID=<from terraform output>
AWS_SECRET_ACCESS_KEY=<from terraform output>
AWS_DEFAULT_REGION=us-east-1

HOSTED_ZONE_ID=Z1234567890ABC
DNS_RECORD_NAME=home.example.com
DNS_TTL=300
```

### 4. Start the Container

```bash
docker-compose up -d
```

### 5. Verify Operation

Check the logs to ensure it's working:

```bash
docker-compose logs -f
```

You should see output like:

```
[2026-03-14 10:00:00] Starting IP check...
[2026-03-14 10:00:00] Current public IP: 203.0.113.45
[2026-03-14 10:00:00] No stored IP found. This is the first run.
[2026-03-14 10:00:00] Updating Route53 with initial IP...
[2026-03-14 10:00:01] Route53 update successful. Change ID: /change/C1234567890ABC
[2026-03-14 10:00:01] Initial IP saved: 203.0.113.45
```

## Usage

### View Logs

```bash
# Follow logs in real-time
docker-compose logs -f

# View recent logs
docker-compose logs --tail=50
```

### Manual IP Update

Force an immediate IP check:

```bash
docker-compose exec ratchet-ip /app/update-ip.sh
```

### Stop the Service

```bash
docker-compose down
```

### Restart the Service

```bash
docker-compose restart
```

## How It Works

1. **Cron Schedule**: Every 30 minutes, the container runs the update script
2. **IP Detection**: Queries `https://checkip.amazonaws.com` for current public IP
3. **Comparison**: Compares current IP with stored IP from previous run
4. **Update**: If different (or first run), updates Route53 A record via AWS CLI
5. **Storage**: Saves new IP to `/var/ratchet-ip/current_ip.txt`

## Security

The Terraform configuration creates an IAM user with minimal permissions:

- `route53:ListHostedZones` - List available hosted zones
- `route53:GetHostedZone` - Get hosted zone details
- `route53:ChangeResourceRecordSets` - Update DNS records (scoped to specific zone)
- `route53:ListResourceRecordSets` - List records in the zone
- `route53:GetChange` - Check status of DNS changes

These permissions are scoped to only the specified hosted zone, following AWS security best practices.

## Troubleshooting

### Container won't start

Check environment variables:
```bash
docker-compose config
```

### DNS not updating

1. Verify AWS credentials are correct
2. Check IAM user has proper permissions
3. Verify hosted zone ID is correct
4. Check container logs for errors

### Check current stored IP

```bash
docker-compose exec ratchet-ip cat /var/ratchet-ip/current_ip.txt
```

## Customization

### Change Update Frequency

Edit the cron schedule in `scripts/entrypoint.sh`:

```bash
# Current: Every 30 minutes
echo "*/30 * * * * /app/update-ip.sh >> /var/log/ratchet-ip.log 2>&1"

# Every 15 minutes
echo "*/15 * * * * /app/update-ip.sh >> /var/log/ratchet-ip.log 2>&1"

# Every hour
echo "0 * * * * /app/update-ip.sh >> /var/log/ratchet-ip.log 2>&1"
```

### Change DNS TTL

Update the `DNS_TTL` value in `.env` (in seconds):

```bash
DNS_TTL=60    # 1 minute
DNS_TTL=300   # 5 minutes (default)
DNS_TTL=3600  # 1 hour
```

## File Structure

```
ratchet-ip/
├── Dockerfile                      # Container definition
├── docker-compose.yml              # Docker Compose configuration
├── .env.example                    # Environment variable template
├── scripts/
│   ├── entrypoint.sh              # Container startup script
│   └── update-ip.sh               # Main IP update logic
├── terraform/
│   ├── main.tf                    # AWS resources (IAM user, policy)
│   ├── variables.tf               # Input variables
│   ├── outputs.tf                 # Output values (credentials)
│   └── terraform.tfvars.example   # Variable values template
└── README.md                      # This file
```

## License

MIT

## Contributing

Issues and pull requests welcome!
