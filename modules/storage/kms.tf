data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "kms" {
  #checkov:skip=CKV_AWS_109:In a key policy "*" means this key only.
  #checkov:skip=CKV_AWS_111:A key policy can't grant access to other resources.
  #checkov:skip=CKV_AWS_356:Key policies always use "*" as the resource.
  statement {
    sid       = "EnableAccountAdministration"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_kms_key" "data" {
  count = var.use_kms_cmk ? 1 : 0

  description             = "${var.name} data bucket key"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.kms.json
}

resource "aws_kms_alias" "data" {
  count = var.use_kms_cmk ? 1 : 0

  name          = "alias/${var.name}-data"
  target_key_id = aws_kms_key.data[0].key_id
}
