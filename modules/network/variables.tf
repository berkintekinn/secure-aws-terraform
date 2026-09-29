variable "name" {
  description = "Prefix for resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones for the subnets, at least two."
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "Use at least two AZs."
  }
}

variable "enable_nat" {
  description = "Give private subnets internet access through a NAT gateway. Billed hourly plus data, so off by default."
  type        = bool
  default     = false
}

variable "flow_log_bucket_arn" {
  description = "ARN of the bucket that receives VPC flow logs."
  type        = string
}
