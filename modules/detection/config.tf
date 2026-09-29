resource "aws_iam_service_linked_role" "config" {
  count = var.enable_config ? 1 : 0

  aws_service_name = "config.amazonaws.com"
}

resource "aws_config_configuration_recorder" "this" {
  count = var.enable_config ? 1 : 0

  name     = "${var.name}-recorder"
  role_arn = aws_iam_service_linked_role.config[0].arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "this" {
  count = var.enable_config ? 1 : 0

  name           = "${var.name}-delivery"
  s3_bucket_name = var.log_bucket_name

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  count = var.enable_config ? 1 : 0

  name       = aws_config_configuration_recorder.this[0].name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this]
}

locals {
  config_rules = var.enable_config ? {
    cloudtrail-enabled            = "CLOUD_TRAIL_ENABLED"
    cloudtrail-log-validation     = "CLOUD_TRAIL_LOG_FILE_VALIDATION_ENABLED"
    root-no-access-key            = "IAM_ROOT_ACCESS_KEY_CHECK"
    mfa-for-console               = "MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS"
    iam-password-policy           = "IAM_PASSWORD_POLICY"
    s3-public-read-prohibited     = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
    s3-public-write-prohibited    = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
    s3-ssl-requests-only          = "S3_BUCKET_SSL_REQUESTS_ONLY"
    s3-encryption-enabled         = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
    vpc-flow-logs-enabled         = "VPC_FLOW_LOGS_ENABLED"
    vpc-default-sg-closed         = "VPC_DEFAULT_SECURITY_GROUP_CLOSED"
    incoming-ssh-disabled         = "INCOMING_SSH_DISABLED"
    guardduty-enabled-centralized = "GUARDDUTY_ENABLED_CENTRALIZED"
  } : {}
}

resource "aws_config_config_rule" "managed" {
  for_each = local.config_rules

  name = "${var.name}-${each.key}"

  source {
    owner             = "AWS"
    source_identifier = each.value
  }

  depends_on = [aws_config_configuration_recorder_status.this]
}
