data "aws_iam_policy_document" "guardrails" {
  statement {
    sid    = "DenyPrivilegeEscalation"
    effect = "Deny"
    actions = [
      "iam:Create*",
      "iam:Delete*",
      "iam:Put*",
      "iam:Attach*",
      "iam:Detach*",
      "iam:Update*",
      "iam:PassRole",
      "iam:AddUserToGroup",
      "iam:SetDefaultPolicyVersion",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DenyDisablingSecurityControls"
    effect = "Deny"
    actions = [
      "cloudtrail:StopLogging",
      "cloudtrail:DeleteTrail",
      "cloudtrail:UpdateTrail",
      "guardduty:DeleteDetector",
      "guardduty:UpdateDetector",
      "config:StopConfigurationRecorder",
      "config:DeleteConfigurationRecorder",
      "config:DeleteDeliveryChannel",
      "access-analyzer:DeleteAnalyzer",
      "ec2:DeleteFlowLogs",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DenyLogTampering"
    effect = "Deny"
    actions = [
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "s3:PutBucketPolicy",
      "s3:PutLifecycleConfiguration",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
    ]
    resources = [
      var.log_bucket_arn,
      "${var.log_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_policy" "guardrails" {
  name        = "${var.name}-guardrails"
  description = "Attached to every role. Blocks privilege escalation, turning off security controls and deleting logs."
  policy      = data.aws_iam_policy_document.guardrails.json
}
