output "log_bucket_arn" {
  description = "Log archive bucket ARN."
  value       = aws_s3_bucket.log_archive.arn
}

output "log_bucket_name" {
  description = "Log archive bucket name."
  value       = aws_s3_bucket.log_archive.id
}

output "access_log_prefix" {
  description = "Prefix for S3 server access logs in the log archive."
  value       = local.access_log_prefix
}

output "cloudtrail_arn" {
  description = "CloudTrail trail ARN."
  value       = aws_cloudtrail.this.arn
}
