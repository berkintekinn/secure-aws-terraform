data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  account_root = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
}

data "aws_iam_policy_document" "human_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [local.account_root]
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "security_auditor" {
  name                 = "${var.name}-security-auditor"
  description          = "Read only security audit, MFA required."
  assume_role_policy   = data.aws_iam_policy_document.human_assume.json
  max_session_duration = var.max_session_duration
}

resource "aws_iam_role_policy_attachment" "security_auditor" {
  role       = aws_iam_role.security_auditor.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role" "log_reader" {
  name                 = "${var.name}-log-reader"
  description          = "Reads the log archive only, MFA required."
  assume_role_policy   = data.aws_iam_policy_document.human_assume.json
  max_session_duration = var.max_session_duration
}

data "aws_iam_policy_document" "log_reader" {
  statement {
    sid       = "ListLogBucket"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [var.log_bucket_arn]
  }

  statement {
    sid       = "ReadLogObjects"
    actions   = ["s3:GetObject"]
    resources = ["${var.log_bucket_arn}/*"]
  }
}

resource "aws_iam_role_policy" "log_reader" {
  name   = "read-log-archive"
  role   = aws_iam_role.log_reader.id
  policy = data.aws_iam_policy_document.log_reader.json
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "ci_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:ref:refs/heads/${var.github_branch}"]
    }
  }
}

resource "aws_iam_role" "ci_readonly" {
  name                 = "${var.name}-ci-readonly"
  description          = "Read only role for GitHub Actions (terraform plan)."
  assume_role_policy   = data.aws_iam_policy_document.ci_assume.json
  max_session_duration = var.max_session_duration
}

resource "aws_iam_role_policy_attachment" "ci_readonly" {
  role       = aws_iam_role.ci_readonly.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "ci_deny_data" {
  statement {
    sid    = "DenyDataAccess"
    effect = "Deny"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "secretsmanager:GetSecretValue",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "kms:Decrypt",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ci_deny_data" {
  name   = "deny-data-access"
  role   = aws_iam_role.ci_readonly.id
  policy = data.aws_iam_policy_document.ci_deny_data.json
}

data "aws_iam_policy_document" "app_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "app" {
  name                 = "${var.name}-app"
  description          = "Application role, limited to objects in the data bucket."
  assume_role_policy   = data.aws_iam_policy_document.app_assume.json
  max_session_duration = var.max_session_duration
}

data "aws_iam_policy_document" "app" {
  statement {
    sid       = "ListDataBucket"
    actions   = ["s3:ListBucket"]
    resources = [var.data_bucket_arn]
  }

  statement {
    sid       = "ReadWriteDataObjects"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${var.data_bucket_arn}/*"]
  }

  dynamic "statement" {
    for_each = var.data_kms_key_arn == null ? [] : [var.data_kms_key_arn]
    content {
      sid       = "UseDataKeyViaS3"
      actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
      resources = [statement.value]

      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = ["s3.${data.aws_region.current.region}.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_role_policy" "app" {
  name   = "data-bucket-access"
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.app.json
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.name}-app"
  role = aws_iam_role.app.name
}

locals {
  guarded_roles = {
    security_auditor = aws_iam_role.security_auditor.name
    log_reader       = aws_iam_role.log_reader.name
    ci_readonly      = aws_iam_role.ci_readonly.name
    app              = aws_iam_role.app.name
  }
}

resource "aws_iam_role_policy_attachment" "guardrails" {
  for_each = local.guarded_roles

  role       = each.value
  policy_arn = aws_iam_policy.guardrails.arn
}
