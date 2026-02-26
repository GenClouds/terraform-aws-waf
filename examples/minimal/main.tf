################################################################################
# Minimal WAFv2 Example
# Creates a basic Web ACL with AWS Managed Rules Common Rule Set
################################################################################

module "waf_minimal" {
  source = "../.."

  name        = "minimal-waf-example"
  description = "Minimal Web ACL with AWS Managed Rules"
  scope       = "REGIONAL"

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
        metric_name                = "AWSManagedRulesCommonRuleSetMetric"
        sampled_requests_enabled   = true
      }
    }
  ]

  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "minimal-waf-metric"
    sampled_requests_enabled   = true
  }

  tags = {
    Example = "minimal"
  }
}
