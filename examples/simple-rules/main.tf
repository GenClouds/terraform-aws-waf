module "waf_simple" {
  source = "../.."

  name        = "simple-rules-example"
  description = "Simple Rules DSL demonstration"
  scope       = "REGIONAL"

  simple_rules = [
    {
      name          = "BlockBadCountries"
      priority      = 1
      action        = "block"
      country_codes = ["CN", "RU", "KP"]
    },
    {
      name       = "RateLimit"
      priority   = 2
      action     = "block"
      rate_limit = 2000
    },
    {
      name               = "AWSManagedCommon"
      priority           = 3
      managed_rule_group = "AWSManagedRulesCommonRuleSet"
    }
  ]

  tags = {
    Example = "simple-rules"
  }
}

output "web_acl_id" {
  value = module.waf_simple.web_acl_id
}

output "web_acl_arn" {
  value = module.waf_simple.web_acl_arn
}
