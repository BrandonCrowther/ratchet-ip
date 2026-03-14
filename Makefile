.PHONY: help setup build up down logs restart clean terraform-init terraform-plan terraform-apply terraform-destroy

help:
	@echo "Ratchet IP - Makefile Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup           - Initial setup (copy example files)"
	@echo "  make terraform-init  - Initialize Terraform"
	@echo "  make terraform-plan  - Plan Terraform changes"
	@echo "  make terraform-apply - Apply Terraform changes"
	@echo ""
	@echo "Docker:"
	@echo "  make build           - Build Docker image"
	@echo "  make up              - Start container"
	@echo "  make down            - Stop container"
	@echo "  make restart         - Restart container"
	@echo "  make logs            - View container logs"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean           - Remove containers and volumes"
	@echo "  make terraform-destroy - Destroy Terraform resources"

setup:
	@echo "Setting up configuration files..."
	@if [ ! -f .env ]; then cp .env.example .env && echo "Created .env - please edit with your values"; else echo ".env already exists"; fi
	@if [ ! -f terraform.tfvars ]; then cp terraform.tfvars.example terraform.tfvars && echo "Created terraform.tfvars - please edit with your values"; else echo "terraform.tfvars already exists"; fi

terraform-init:
	terraform init

terraform-plan:
	terraform plan

terraform-apply:
	terraform apply

terraform-destroy:
	terraform destroy

build:
	docker-compose build

up:
	docker-compose up -d
	@echo "Container started. View logs with: make logs"

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f

clean:
	docker-compose down -v
	@echo "Containers and volumes removed"
