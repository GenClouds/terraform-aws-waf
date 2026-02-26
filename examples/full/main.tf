################################################################################
# Full WAFv2 Example
# Comprehensive example with IP sets, regex pattern sets, custom rule groups,
# managed rules, rate limiting, geo-blocking, and logging
################################################################################

module "waf_full" {
  source = "../.."

  name        = "full-waf-example"
  description = "Comprehensive WAF configuration with all components"
  scope       = "REGIONAL"

  default_action = "allow"

  # IP Sets
  ip_sets = {
    admin_ips = {
      description        = "Admin IP addresses"
      ip_address_version = "IPV4"
      addresses          = var.admin_ip_cidrs
    }
  }

  # Regex Pattern Sets
  regex_pattern_sets = {
    sql_injection = {
      description = "SQL injection patterns"
      regular_expression = [
        { regex_string = "(?i)(union.*select|select.*from)" },
        { regex_string = "(?i)(drop.*table|delete.*from)" }
      ]
    }
  }

  # Custom Rule Groups
  rule_groups = {
    custom_rules = {
      description = "Custom security rules"
      capacity    = 50
      rules = [
        {
          name     = "BlockSQLi"
          priority = 1
          action   = "block"

          statement = {
            byte_match_statement = {
              positional_constraint = "CONTAINS"
              search_string         = "union select"
              field_to_match = {
                query_string = {}
              }
              text_transformations = [
                { priority = 0, type = "LOWERCASE" }
              ]
            }
          }

          visibility_config = {
            cloudwatch_metrics_enabled = true
            metric_name                = "BlockSQLiMetric"
            sampled_requests_enabled   = true
          }
        }
      ]

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "CustomRulesMetric"
        sampled_requests_enabled   = true
      }
    }
  }

  # Web ACL Rules
  rules = [
    {
      name     = "AllowAdminIPs"
      priority = 1
      action   = "allow"

      statement = {
        ip_set_reference_statement = {
          ip_set_key = "admin_ips"
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AllowAdminIPsMetric"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "CustomRuleGroup"
      priority = 2

      statement = {
        rule_group_reference_statement = {
          rule_group_key = "custom_rules"
        }
      }

      override_action = "none"

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "CustomRuleGroupMetric"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "RateLimitRule"
      priority = 3
      action   = "block"

      statement = {
        rate_based_statement = {
          limit              = var.rate_limit
          aggregate_key_type = "IP"
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "RateLimitMetric"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 4

      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
          rule_action_overrides = {
            "SizeRestrictions_BODY" = { action = "count" }
          }
        }
      }

      override_action = "none"

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "CommonRuleSetMetric"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = 5

      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesKnownBadInputsRuleSet"
          vendor_name = "AWS"
        }
      }

      override_action = "none"

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "KnownBadInputsMetric"
        sampled_requests_enabled   = true
      }
    }
  ]

  resource_arns = var.resource_arns

  # Logging (uncomment and configure when using Kinesis Firehose or CloudWatch)
  # enable_logging          = true
  # log_destination_configs = [aws_kinesis_firehose_delivery_stream.waf_logs.arn]

  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "full-waf-metric"
    sampled_requests_enabled   = true
  }

  tags = {
    Example   = "full"
    ManagedBy = "Terraform"
  }
}
