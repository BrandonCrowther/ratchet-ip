variable "hosted_zone_name" {
  description = "The Route53 hosted zone name (e.g., example.com)"
  type        = string
}

variable "dns_record_name" {
  description = "The DNS record name to update (e.g., home.example.com)"
  type        = string
}

variable "iam_user_name" {
  description = "Name for the IAM user"
  type        = string
  default     = "ratchet-ip-updater"
}
