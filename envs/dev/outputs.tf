output "vpc_id" {
  description = "VPC ID."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.network.private_subnet_ids
}

output "log_bucket_name" {
  description = "Log archive bucket."
  value       = module.logging.log_bucket_name
}

output "iam_role_arns" {
  description = "IAM role ARNs."
  value = {
    security_auditor = module.iam.security_auditor_role_arn
    log_reader       = module.iam.log_reader_role_arn
    ci_readonly      = module.iam.ci_readonly_role_arn
    app              = module.iam.app_role_arn
  }
}

output "data_bucket_name" {
  description = "Encrypted data bucket."
  value       = module.storage.data_bucket_name
}
