################################################################################
# API Gateway WAFv2 Example
# Web ACL with rate-based rules, geo-blocking, and API Gateway association
################################################################################

module "waf_apigw" {
  source = "../.."

  name        = "apigw-waf-example"
  description = "WAF for API Gateway with rate limiting and geo-blocking"
  scope       = "REGIONAL"

  default_action = "allow"

  rules = [
    {
      name     = "GeoBlockRule"
      priority = 1
      action   = "block"

      statement = {
        geo_match_statement = {
          country_codes = var.blocked_countries
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "GeoBlockMetric"
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

  resource_arns = var.api_gateway_stage_arns

  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "apigw-waf-metric"
    sampled_requests_enabled   = true
  }

  tags = {
    Example = "apigw"
  }
}
