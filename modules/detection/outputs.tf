output "alerts_topic_arn" {
  description = "SNS topic for security alerts, null when disabled."
  value       = var.enable_security_alerts ? aws_sns_topic.alerts[0].arn : null
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID, null when disabled."
  value       = var.enable_guardduty ? aws_guardduty_detector.this[0].id : null
}
