locals {
  name = "${var.project_name}-${var.environment}"
}

module "logging" {
  source = "../../modules/logging"

  name                   = local.name
  enable_s3_data_events  = var.enable_s3_data_events
  data_event_bucket_arns = [module.storage.data_bucket_arn]
}

module "network" {
  source = "../../modules/network"

  name                = local.name
  vpc_cidr            = var.vpc_cidr
  azs                 = var.azs
  enable_nat          = var.enable_nat
  flow_log_bucket_arn = module.logging.log_bucket_arn
}

module "storage" {
  source = "../../modules/storage"

  name              = local.name
  use_kms_cmk       = var.use_kms_cmk
  log_bucket_name   = module.logging.log_bucket_name
  access_log_prefix = module.logging.access_log_prefix
}

module "iam" {
  source = "../../modules/iam"

  name              = local.name
  github_repository = var.github_repository
  log_bucket_arn    = module.logging.log_bucket_arn
  data_bucket_arn   = module.storage.data_bucket_arn
  data_kms_key_arn  = module.storage.kms_key_arn
}

module "detection" {
  source = "../../modules/detection"

  name                   = local.name
  enable_guardduty       = var.enable_guardduty
  enable_config          = var.enable_config
  enable_security_hub    = var.enable_security_hub
  enable_security_alerts = var.enable_security_alerts
  alert_email            = var.alert_email
  log_bucket_name        = module.logging.log_bucket_name
}
