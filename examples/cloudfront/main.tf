################################################################################
# CloudFront WAFv2 Example
# Web ACL with CLOUDFRONT scope for use with CloudFront distributions
################################################################################

module "waf_cloudfront" {
  source = "../.."

  name        = "cloudfront-waf-example"
  description = "WAF for CloudFront distribution with managed rule groups"
  scope       = "CLOUDFRONT"

  default_action = "allow"

  rules = [
    {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 1

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
    },
    {
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = 2

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
    },
    {
      name     = "RateLimitRule"
      priority = 3
      action   = "block"

      statement = {
        rate_based_statement = {
          limit              = 2000
          aggregate_key_type = "IP"
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "RateLimitMetric"
        sampled_requests_enabled   = true
      }
    }
  ]

  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "cloudfront-waf-metric"
    sampled_requests_enabled   = true
  }

  tags = {
    Example = "cloudfront"
  }
}

# Example: Associate with CloudFront distribution
# resource "aws_cloudfront_distribution" "main" {
#   # ... other configuration ...
#   web_acl_id = module.waf_cloudfront.web_acl_arn
# }
