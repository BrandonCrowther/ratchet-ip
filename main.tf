terraform {
  required_version = ">= 1.0"

  backend "s3" {
    region  = "ca-central-1"
    bucket  = "bcrowthe-tfstate"
    key     = "ratchet-ip.tfstate"
    profile = "default"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
  default_tags {
    tags = {
      Terraform = "true"
      Project   = "ratchet-ip"
    }
  }
}

# Look up the hosted zone by domain name
data "aws_route53_zone" "main" {
  name         = var.hosted_zone_name
  private_zone = false
}

module "route53_iam_user" {
  source = "./terraform/modules/route53-iam-user"

  hosted_zone_id = data.aws_route53_zone.main.zone_id
  iam_user_name  = var.iam_user_name
}
