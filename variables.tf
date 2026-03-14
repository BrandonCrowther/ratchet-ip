variable "hosted_zone_name" {
  description = "The Route53 hosted zone name (e.g., example.com)"
  type        = string
}

variable "dns_record_names" {
  description = "List of DNS record names to update (e.g., [\"home.example.com\", \"*.example.com\"])"
  type        = list(string)
}

variable "iam_user_name" {
  description = "Name for the IAM user"
  type        = string
  default     = "ratchet-ip-updater"
}
