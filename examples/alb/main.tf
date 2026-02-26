################################################################################
# ALB WAFv2 Example
# Web ACL with IP sets, rate limiting, and ALB association
################################################################################

module "waf_alb" {
  source = "../.."

  name        = "alb-waf-example"
  description = "WAF for Application Load Balancer with IP blocking and rate limiting"
  scope       = "REGIONAL"

  default_action = "allow"

  # IP set for blocked IPs (example - replace with your CIDRs)
  ip_sets = {
    blocked_ips = {
      description        = "Blocked IP addresses"
      ip_address_version = "IPV4"
      addresses          = var.blocked_ip_cidrs
    }
  }

  rules = [
    {
      name     = "BlockIPSet"
      priority = 1
      action   = "block"

      statement = {
        ip_set_reference_statement = {
          ip_set_key = "blocked_ips" # References module-created IP set
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "BlockIPSetMetric"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "RateLimitRule"
      priority = 2
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
      priority = 3

      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }

      override_action = "none"

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "CommonRuleSetMetric"
        sampled_requests_enabled   = true
      }
    }
  ]

  resource_arns = var.alb_arns

  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "alb-waf-metric"
    sampled_requests_enabled   = true
  }

  tags = {
    Example = "alb"
  }
}
