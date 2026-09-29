resource "aws_guardduty_detector" "this" {
  #checkov:skip=CKV2_AWS_3:Single account without AWS Organizations, so there is no org level GuardDuty setup.
  count = var.enable_guardduty ? 1 : 0

  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
}

resource "aws_cloudwatch_event_rule" "guardduty_high" {
  count = var.enable_guardduty && var.enable_security_alerts ? 1 : 0

  name        = "${var.name}-guardduty-high"
  description = "High severity GuardDuty finding"
  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail      = { severity = [{ numeric = [">=", 7] }] }
  })
}

resource "aws_cloudwatch_event_target" "guardduty_high" {
  count = var.enable_guardduty && var.enable_security_alerts ? 1 : 0

  rule = aws_cloudwatch_event_rule.guardduty_high[0].name
  arn  = aws_sns_topic.alerts[0].arn
}
