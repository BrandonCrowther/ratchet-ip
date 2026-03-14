output "hosted_zone_id" {
  description = "The Route53 hosted zone ID (for .env file)"
  value       = data.aws_route53_zone.main.zone_id
}

output "hosted_zone_name" {
  description = "The Route53 hosted zone name"
  value       = data.aws_route53_zone.main.name
}

output "dns_record_names" {
  description = "Comma-separated list of DNS record names to update (for .env file)"
  value       = join(",", var.dns_record_names)
}

output "iam_user_name" {
  description = "Name of the IAM user"
  value       = module.route53_iam_user.iam_user_name
}

output "iam_user_arn" {
  description = "ARN of the IAM user"
  value       = module.route53_iam_user.iam_user_arn
}

output "aws_access_key_id" {
  description = "AWS Access Key ID for the IAM user"
  value       = module.route53_iam_user.aws_access_key_id
}

output "aws_secret_access_key" {
  description = "AWS Secret Access Key for the IAM user"
  value       = module.route53_iam_user.aws_secret_access_key
  sensitive   = true
}

output "credentials_summary" {
  description = "Summary of credentials for Docker container"
  value = {
    AWS_ACCESS_KEY_ID     = module.route53_iam_user.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = module.route53_iam_user.aws_secret_access_key
  }
  sensitive = true
}
