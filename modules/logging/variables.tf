variable "name" {
  description = "Prefix for resource names."
  type        = string
}

variable "log_retention_days" {
  description = "Days to keep log files."
  type        = number
  default     = 90
}

variable "enable_s3_data_events" {
  description = "Log object writes and deletes in data buckets. Paid (about 0.10 USD per 100k events), off by default."
  type        = bool
  default     = false
}

variable "data_event_bucket_arns" {
  description = "Bucket ARNs to log object events for when enable_s3_data_events is on."
  type        = list(string)
  default     = []
}
