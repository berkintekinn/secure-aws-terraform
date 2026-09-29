variable "name" {
  description = "Prefix for resource names."
  type        = string
}

variable "github_repository" {
  description = "GitHub repo allowed to assume the CI role (owner/name)."
  type        = string
}

variable "github_branch" {
  description = "Only workflows on this branch can assume the CI role."
  type        = string
  default     = "main"
}

variable "log_bucket_arn" {
  description = "ARN of the log archive bucket the log reader can read."
  type        = string
}

variable "max_session_duration" {
  description = "Maximum session duration for the roles, in seconds."
  type        = number
  default     = 3600
}

variable "data_bucket_arn" {
  description = "ARN of the data bucket the application role can use."
  type        = string
}

variable "data_kms_key_arn" {
  description = "ARN of the data bucket CMK, or null when the bucket uses aws/s3."
  type        = string
  default     = null
}
