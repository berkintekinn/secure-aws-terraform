output "data_bucket_arn" {
  description = "Data bucket ARN."
  value       = aws_s3_bucket.data.arn
}

output "data_bucket_name" {
  description = "Data bucket name."
  value       = aws_s3_bucket.data.id
}

output "kms_key_arn" {
  description = "Customer managed key ARN, null when use_kms_cmk is false."
  value       = local.kms_key_arn
}
