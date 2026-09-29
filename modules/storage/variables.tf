variable "name" {
  description = "Prefix for resource names."
  type        = string
}

variable "use_kms_cmk" {
  description = "Use a customer managed KMS key (about 1 USD a month). When false the bucket uses the free aws/s3 key."
  type        = bool
  default     = false
}

variable "log_bucket_name" {
  description = "Log archive bucket for server access logs."
  type        = string
}

variable "access_log_prefix" {
  description = "Access log prefix in the log archive."
  type        = string
}

variable "noncurrent_version_retention_days" {
  description = "Days to keep old object versions."
  type        = number
  default     = 30
}
