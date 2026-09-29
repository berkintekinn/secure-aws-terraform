variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
  default     = "secure-aws-terraform"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Everything lives in a single region."
  type        = string
  default     = "eu-central-1"

  validation {
    condition     = var.region == "eu-central-1"
    error_message = "This project only targets eu-central-1."
  }
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to use."
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "enable_nat" {
  description = "Create a NAT gateway. Paid, off by default."
  type        = bool
  default     = false
}

variable "github_repository" {
  description = "GitHub repo allowed to assume the CI role through OIDC."
  type        = string
  default     = "berkintekinn/secure-aws-terraform"
}

variable "use_kms_cmk" {
  description = "Use a customer managed KMS key for the data bucket. Paid, off by default."
  type        = bool
  default     = false
}

variable "enable_s3_data_events" {
  description = "Log data bucket object events in CloudTrail. Paid, off by default."
  type        = bool
  default     = false
}

variable "enable_guardduty" {
  description = "Enable GuardDuty. 30 day trial, then paid. Off by default."
  type        = bool
  default     = false
}

variable "enable_config" {
  description = "Enable AWS Config. Paid, off by default."
  type        = bool
  default     = false
}

variable "enable_security_hub" {
  description = "Enable Security Hub. 30 day trial, then paid. Off by default."
  type        = bool
  default     = false
}

variable "enable_security_alerts" {
  description = "Free security alerts through EventBridge and SNS."
  type        = bool
  default     = true
}

variable "alert_email" {
  description = "Email address for alerts (optional)."
  type        = string
  default     = null
}
