variable "hosted_zone_id" {
  description = "The Route53 hosted zone ID where DNS records will be updated"
  type        = string
}

variable "iam_user_name" {
  description = "Name for the IAM user"
  type        = string
  default     = "ratchet-ip-updater"
}
