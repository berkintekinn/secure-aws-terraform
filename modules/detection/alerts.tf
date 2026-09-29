data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  all_alert_rules = {
    root-usage = {
      description = "Root account was used"
      pattern = {
        detail-type = ["AWS API Call via CloudTrail", "AWS Console Sign In via CloudTrail"]
        detail      = { userIdentity = { type = ["Root"] } }
      }
    }
    console-login-without-mfa = {
      description = "Console login without MFA"
      pattern = {
        detail-type = ["AWS Console Sign In via CloudTrail"]
        detail = {
          eventName           = ["ConsoleLogin"]
          additionalEventData = { MFAUsed = ["No"] }
        }
      }
    }
    iam-policy-change = {
      description = "IAM policy or role changed"
      pattern = {
        source      = ["aws.iam"]
        detail-type = ["AWS API Call via CloudTrail"]
        detail = {
          eventName = [
            "CreatePolicy", "DeletePolicy", "CreatePolicyVersion", "SetDefaultPolicyVersion",
            "AttachRolePolicy", "DetachRolePolicy", "PutRolePolicy", "DeleteRolePolicy",
            "AttachUserPolicy", "PutUserPolicy", "CreateAccessKey", "UpdateAssumeRolePolicy",
          ]
        }
      }
    }
    logging-tampering = {
      description = "Logging or detection service changed"
      pattern = {
        detail-type = ["AWS API Call via CloudTrail"]
        detail = {
          eventName = [
            "StopLogging", "DeleteTrail", "UpdateTrail", "PutEventSelectors",
            "DeleteDetector", "UpdateDetector", "DeleteFlowLogs",
            "StopConfigurationRecorder", "DeleteConfigurationRecorder",
          ]
        }
      }
    }
    security-group-open = {
      description = "Security group or NACL rule changed"
      pattern = {
        source      = ["aws.ec2"]
        detail-type = ["AWS API Call via CloudTrail"]
        detail = {
          eventName = [
            "AuthorizeSecurityGroupIngress", "RevokeSecurityGroupIngress",
            "CreateNetworkAclEntry", "ReplaceNetworkAclEntry", "DeleteNetworkAclEntry",
          ]
        }
      }
    }
    s3-bucket-exposure = {
      description = "S3 bucket access settings changed"
      pattern = {
        source      = ["aws.s3"]
        detail-type = ["AWS API Call via CloudTrail"]
        detail = {
          eventName = [
            "PutBucketPolicy", "DeleteBucketPolicy", "PutBucketAcl",
            "PutBucketPublicAccessBlock", "DeleteBucketPublicAccessBlock",
            "DeleteBucketEncryption",
          ]
        }
      }
    }
  }

  alert_rules = { for k, v in local.all_alert_rules : k => v if var.enable_security_alerts }
}

resource "aws_sns_topic" "alerts" {
  #checkov:skip=CKV_AWS_26:EventBridge can't publish to a topic encrypted with aws/sns and a customer managed key costs money. Messages only carry event summaries.
  count = var.enable_security_alerts ? 1 : 0

  name = "${var.name}-security-alerts"
}

data "aws_iam_policy_document" "alerts_topic" {
  count = var.enable_security_alerts ? 1 : 0

  statement {
    sid       = "AllowEventBridgePublish"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.alerts[0].arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_sns_topic_policy" "alerts" {
  count = var.enable_security_alerts ? 1 : 0

  arn    = aws_sns_topic.alerts[0].arn
  policy = data.aws_iam_policy_document.alerts_topic[0].json
}

resource "aws_sns_topic_subscription" "email" {
  count = var.enable_security_alerts && var.alert_email != null ? 1 : 0

  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_event_rule" "alerts" {
  for_each = local.alert_rules

  name          = "${var.name}-${each.key}"
  description   = each.value.description
  event_pattern = jsonencode(each.value.pattern)
}

resource "aws_cloudwatch_event_target" "alerts" {
  for_each = local.alert_rules

  rule = aws_cloudwatch_event_rule.alerts[each.key].name
  arn  = aws_sns_topic.alerts[0].arn
}
