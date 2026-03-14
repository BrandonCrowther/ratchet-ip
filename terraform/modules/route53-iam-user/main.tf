# IAM User for Route53 updates
resource "aws_iam_user" "route53_updater" {
  name = var.iam_user_name
  path = "/ratchet-ip/"

  tags = {
    Name        = "Ratchet IP Updater"
    Description = "IAM user for updating Route53 DNS records"
    ManagedBy   = "Terraform"
  }
}

# IAM Policy with minimal permissions - only update specific Route53 record
resource "aws_iam_user_policy" "route53_update_policy" {
  name = "route53-record-update"
  user = aws_iam_user.route53_updater.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListHostedZones"
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:GetHostedZone"
        ]
        Resource = "*"
      },
      {
        Sid    = "UpdateSpecificRecordSet"
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ]
        Resource = "arn:aws:route53:::hostedzone/${var.hosted_zone_id}"
      },
      {
        Sid    = "GetChangeStatus"
        Effect = "Allow"
        Action = [
          "route53:GetChange"
        ]
        Resource = "arn:aws:route53:::change/*"
      }
    ]
  })
}

# Access Key for the IAM user
resource "aws_iam_access_key" "route53_updater_key" {
  user = aws_iam_user.route53_updater.name
}
