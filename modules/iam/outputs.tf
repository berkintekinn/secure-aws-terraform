output "security_auditor_role_arn" {
  description = "Security auditor role."
  value       = aws_iam_role.security_auditor.arn
}

output "log_reader_role_arn" {
  description = "Log reader role."
  value       = aws_iam_role.log_reader.arn
}

output "ci_readonly_role_arn" {
  description = "Read only role for GitHub Actions."
  value       = aws_iam_role.ci_readonly.arn
}

output "guardrails_policy_arn" {
  description = "Deny only guardrail policy attached to every role."
  value       = aws_iam_policy.guardrails.arn
}

output "app_role_arn" {
  description = "Application role."
  value       = aws_iam_role.app.arn
}

output "app_instance_profile_name" {
  description = "EC2 instance profile for the application role."
  value       = aws_iam_instance_profile.app.name
}
