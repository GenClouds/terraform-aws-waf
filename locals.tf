locals {
  create = var.create

  # Simple rules DSL transformation
  transformed_simple_rules = [
    for idx, rule in var.simple_rules : merge(
      {
        name            = rule.name
        priority        = rule.priority
        action          = try(rule.action, "block")
        enabled         = try(rule.enabled, true)
        override_action = lookup(rule, "managed_rule_group", null) != null ? try(rule.override_action, "none") : null

        visibility_config = {
          cloudwatch_metrics_enabled = try(rule.visibility_config.cloudwatch_metrics_enabled, true)
          metric_name                = try(rule.visibility_config.metric_name, "${rule.name}-metric")
          sampled_requests_enabled   = try(rule.visibility_config.sampled_requests_enabled, true)
        }
      },
      lookup(rule, "ip_addresses", null) != null ? {
        statement = {
          ip_set_reference_statement = {
            ip_set_key = rule.ip_set_key
          }
        }
      } : {},
      lookup(rule, "country_codes", null) != null ? {
        statement = {
          geo_match_statement = {
            country_codes = rule.country_codes
          }
        }
      } : {},
      lookup(rule, "rate_limit", null) != null ? {
        statement = {
          rate_based_statement = {
            limit              = rule.rate_limit
            aggregate_key_type = try(rule.aggregate_key_type, "IP")
          }
        }
      } : {},
      lookup(rule, "managed_rule_group", null) != null ? {
        statement = {
          managed_rule_group_statement = {
            name        = rule.managed_rule_group
            vendor_name = try(rule.vendor_name, "AWS")
          }
        }
      } : {}
    )
  ]

  # Merge simple_rules and rules
  effective_rules = concat(
    [for r in local.transformed_simple_rules : r if try(r.enabled, true)],
    [for r in var.rules : r if try(r.enabled, true)]
  )

  # Mode switching: rewrite actions based on var.mode
  final_rules = var.mode == "monitor" ? [
    for rule in local.effective_rules : merge(rule, {
      action          = rule.action != null ? "count" : null
      override_action = rule.override_action != null ? "count" : rule.override_action
    })
  ] : local.effective_rules

  # Web ACL visibility config
  web_acl_visibility_config = {
    cloudwatch_metrics_enabled = try(var.visibility_config.cloudwatch_metrics_enabled, true)
    metric_name                = try(var.visibility_config.metric_name, "${var.name}-metric")
    sampled_requests_enabled   = try(var.visibility_config.sampled_requests_enabled, true)
  }

  # Logging configuration
  create_logging_resources = var.enable_logging && var.logging_mode == "s3"
  log_bucket_name          = var.log_bucket_name != "" ? var.log_bucket_name : "${var.name}-waf-logs"
  firehose_name            = "${var.name}-waf-firehose"

  # Path rate limits transformation
  path_rate_limit_rules = [
    for idx, limit in var.path_rate_limits : {
      name     = "PathRateLimit-${idx}"
      priority = 100 + idx
      action   = "block"
      enabled  = true

      statement = {
        rate_based_statement = {
          limit              = limit.limit
          aggregate_key_type = "IP"
          scope_down_statement = {
            byte_match_statement = {
              positional_constraint = "STARTS_WITH"
              search_string         = limit.path
              field_to_match = {
                uri_path = {}
              }
              text_transformations = [
                { priority = 0, type = "NONE" }
              ]
            }
          }
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "PathRateLimit-${idx}-metric"
        sampled_requests_enabled   = true
      }
    }
  ]

  # Preset configurations
  preset_rules = var.preset != "" ? try(local.presets[var.preset], []) : []

  presets = {
    api_hardened = [
      {
        name     = "AWSManagedRulesCommonRuleSet"
        priority = 10
        statement = {
          managed_rule_group_statement = {
            name        = "AWSManagedRulesCommonRuleSet"
            vendor_name = "AWS"
          }
        }
        override_action   = "none"
        visibility_config = { metric_name = "CommonRuleSet" }
      },
      {
        name     = "AWSManagedRulesKnownBadInputsRuleSet"
        priority = 20
        statement = {
          managed_rule_group_statement = {
            name        = "AWSManagedRulesKnownBadInputsRuleSet"
            vendor_name = "AWS"
          }
        }
        override_action   = "none"
        visibility_config = { metric_name = "KnownBadInputs" }
      },
      {
        name     = "RateLimit-API"
        priority = 30
        action   = "block"
        statement = {
          rate_based_statement = {
            limit              = 2000
            aggregate_key_type = "IP"
          }
        }
        visibility_config = { metric_name = "APIRateLimit" }
      }
    ]

    website = [
      {
        name     = "AWSManagedRulesCommonRuleSet"
        priority = 10
        statement = {
          managed_rule_group_statement = {
            name        = "AWSManagedRulesCommonRuleSet"
            vendor_name = "AWS"
          }
        }
        override_action   = "none"
        visibility_config = { metric_name = "CommonRuleSet" }
      },
      {
        name     = "AWSManagedRulesAmazonIpReputationList"
        priority = 20
        statement = {
          managed_rule_group_statement = {
            name        = "AWSManagedRulesAmazonIpReputationList"
            vendor_name = "AWS"
          }
        }
        override_action   = "none"
        visibility_config = { metric_name = "IpReputation" }
      }
    ]

    bot_defense = [
      {
        name     = "AWSManagedRulesBotControlRuleSet"
        priority = 10
        statement = {
          managed_rule_group_statement = {
            name        = "AWSManagedRulesBotControlRuleSet"
            vendor_name = "AWS"
          }
        }
        override_action   = "none"
        visibility_config = { metric_name = "BotControl" }
      }
    ]

    zero_trust = [
      {
        name     = "AWSManagedRulesCommonRuleSet"
        priority = 10
        statement = {
          managed_rule_group_statement = {
            name        = "AWSManagedRulesCommonRuleSet"
            vendor_name = "AWS"
          }
        }
        override_action   = "none"
        visibility_config = { metric_name = "CommonRuleSet" }
      },
      {
        name     = "AWSManagedRulesKnownBadInputsRuleSet"
        priority = 20
        statement = {
          managed_rule_group_statement = {
            name        = "AWSManagedRulesKnownBadInputsRuleSet"
            vendor_name = "AWS"
          }
        }
        override_action   = "none"
        visibility_config = { metric_name = "KnownBadInputs" }
      },
      {
        name     = "AWSManagedRulesAmazonIpReputationList"
        priority = 30
        statement = {
          managed_rule_group_statement = {
            name        = "AWSManagedRulesAmazonIpReputationList"
            vendor_name = "AWS"
          }
        }
        override_action   = "none"
        visibility_config = { metric_name = "IpReputation" }
      },
      {
        name     = "RateLimit-Strict"
        priority = 40
        action   = "block"
        statement = {
          rate_based_statement = {
            limit              = 1000
            aggregate_key_type = "IP"
          }
        }
        visibility_config = { metric_name = "StrictRateLimit" }
      }
    ]
  }

  # Combine all rules
  all_rules = concat(
    local.preset_rules,
    local.path_rate_limit_rules,
    local.final_rules
  )
}
