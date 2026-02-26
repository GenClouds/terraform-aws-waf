module "wrapper" {
  source = "../"

  for_each = var.items

  create                 = try(each.value.create, var.defaults.create, true)
  name                   = try(each.value.name, var.defaults.name, "")
  description            = try(each.value.description, var.defaults.description, "")
  scope                  = try(each.value.scope, var.defaults.scope, "REGIONAL")
  default_action         = try(each.value.default_action, var.defaults.default_action, "allow")
  rules                  = try(each.value.rules, var.defaults.rules, [])
  simple_rules           = try(each.value.simple_rules, var.defaults.simple_rules, [])
  mode                   = try(each.value.mode, var.defaults.mode, "block")
  preset                 = try(each.value.preset, var.defaults.preset, "")
  path_rate_limits       = try(each.value.path_rate_limits, var.defaults.path_rate_limits, [])
  visibility_config      = try(each.value.visibility_config, var.defaults.visibility_config, null)
  custom_response_bodies = try(each.value.custom_response_bodies, var.defaults.custom_response_bodies, {})
  captcha_config         = try(each.value.captcha_config, var.defaults.captcha_config, null)
  challenge_config       = try(each.value.challenge_config, var.defaults.challenge_config, null)
  token_domains          = try(each.value.token_domains, var.defaults.token_domains, [])
  tags                   = try(each.value.tags, var.defaults.tags, {})
  web_acl_tags           = try(each.value.web_acl_tags, var.defaults.web_acl_tags, {})

  ip_sets            = try(each.value.ip_sets, var.defaults.ip_sets, {})
  regex_pattern_sets = try(each.value.regex_pattern_sets, var.defaults.regex_pattern_sets, {})
  rule_groups        = try(each.value.rule_groups, var.defaults.rule_groups, {})

  enable_logging              = try(each.value.enable_logging, var.defaults.enable_logging, false)
  logging_mode                = try(each.value.logging_mode, var.defaults.logging_mode, "cloudwatch")
  log_destination_configs     = try(each.value.log_destination_configs, var.defaults.log_destination_configs, [])
  log_bucket_name             = try(each.value.log_bucket_name, var.defaults.log_bucket_name, "")
  log_bucket_force_destroy    = try(each.value.log_bucket_force_destroy, var.defaults.log_bucket_force_destroy, false)
  log_retention_days          = try(each.value.log_retention_days, var.defaults.log_retention_days, 90)
  enable_kms_encryption       = try(each.value.enable_kms_encryption, var.defaults.enable_kms_encryption, true)
  firehose_cloudwatch_logging = try(each.value.firehose_cloudwatch_logging, var.defaults.firehose_cloudwatch_logging, false)
  redacted_fields             = try(each.value.redacted_fields, var.defaults.redacted_fields, [])
  logging_filter              = try(each.value.logging_filter, var.defaults.logging_filter, null)

  resource_arns = try(each.value.resource_arns, var.defaults.resource_arns, [])
}

