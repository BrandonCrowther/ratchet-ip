output "iam_user_name" {
  description = "Name of the IAM user"
  value       = aws_iam_user.route53_updater.name
}

output "iam_user_arn" {
  description = "ARN of the IAM user"
  value       = aws_iam_user.route53_updater.arn
}

output "aws_access_key_id" {
  description = "AWS Access Key ID for the IAM user"
  value       = aws_iam_access_key.route53_updater_key.id
}

output "aws_secret_access_key" {
  description = "AWS Secret Access Key for the IAM user"
  value       = aws_iam_access_key.route53_updater_key.secret
  sensitive   = true
}

output "credentials_summary" {
  description = "Summary of credentials for Docker container"
  value = {
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.route53_updater_key.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.route53_updater_key.secret
  }
  sensitive = true
}
