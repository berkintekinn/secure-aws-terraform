variable "name" {
  description = "Prefix for resource names."
  type        = string
}

variable "enable_guardduty" {
  description = "Enable GuardDuty. 30 day trial, then paid. Off by default."
  type        = bool
  default     = false
}

variable "enable_config" {
  description = "Enable the AWS Config recorder and rules. Billed per recorded item and rule evaluation. Off by default."
  type        = bool
  default     = false
}

variable "enable_security_hub" {
  description = "Enable Security Hub with the AWS Foundational Security Best Practices standard. 30 day trial, then paid. Off by default."
  type        = bool
  default     = false
}

variable "enable_security_alerts" {
  description = "Free security alerts built on CloudTrail events (EventBridge and SNS). On by default."
  type        = bool
  default     = true
}

variable "alert_email" {
  description = "Email address for alerts. When null the topic is created without a subscriber."
  type        = string
  default     = null
}

variable "log_bucket_name" {
  description = "Log archive bucket where AWS Config writes its history."
  type        = string
}
