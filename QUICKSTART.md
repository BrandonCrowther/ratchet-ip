# Quick Start Guide

Get Ratchet IP up and running in 5 minutes.

## Prerequisites

- AWS account with a Route53 hosted zone already configured
- Docker and Docker Compose installed
- Terraform installed

## Step-by-Step Setup

### 1. Configure Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your Route53 details:
- Find your hosted zone ID in AWS Console → Route53 → Hosted Zones
- Set your domain name and desired subdomain

### 2. Create AWS Resources

```bash
terraform init
terraform apply
```

Save the outputs - you'll need them next.

### 3. Configure Docker

```bash
cd ..
cp .env.example .env
```

Edit `.env` and paste the credentials from Terraform output:

```bash
# Copy these from: terraform output
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...

# Copy from your terraform.tfvars
HOSTED_ZONE_ID=Z...
DNS_RECORD_NAME=home.example.com
```

### 4. Launch

```bash
docker-compose up -d
```

### 5. Verify

```bash
docker-compose logs -f
```

You should see the initial IP detection and Route53 update.

## That's It!

Your DNS record will now automatically update every 30 minutes when your IP changes.

## Quick Commands

```bash
# View logs
docker-compose logs -f

# Force immediate update
docker-compose exec ratchet-ip /app/update-ip.sh

# Restart
docker-compose restart

# Stop
docker-compose down
```

## Using the Makefile

```bash
# Setup config files
make setup

# Deploy infrastructure
make terraform-init
make terraform-apply

# Run the container
make build
make up
make logs
```

## Troubleshooting

**Container won't start?**
- Check `.env` file has all variables filled in
- Verify AWS credentials are correct

**DNS not updating?**
- Check logs: `make logs`
- Verify hosted zone ID matches your Route53 zone
- Ensure DNS record name includes the full domain (e.g., `home.example.com` not just `home`)

**Need to change update frequency?**
- Edit `scripts/entrypoint.sh`
- Change `*/30` to desired interval
- Rebuild: `docker-compose down && docker-compose build && docker-compose up -d`
