module "waf_s3_logging" {
  source = "../.."

  name        = "s3-logging-example"
  description = "S3 logging pipeline example"
  scope       = "REGIONAL"

  simple_rules = [
    {
      name               = "AWSManagedCommon"
      priority           = 1
      managed_rule_group = "AWSManagedRulesCommonRuleSet"
    }
  ]

  enable_logging        = true
  logging_mode          = "s3"
  log_retention_days    = 30
  enable_kms_encryption = true

  tags = {
    Example = "s3-logging"
  }
}

output "web_acl_id" {
  value = module.waf_s3_logging.web_acl_id
}

output "log_bucket_name" {
  value = module.waf_s3_logging.log_bucket_name
}

output "firehose_arn" {
  value = module.waf_s3_logging.firehose_arn
}

output "kms_key_arn" {
  value = module.waf_s3_logging.kms_key_arn
}
