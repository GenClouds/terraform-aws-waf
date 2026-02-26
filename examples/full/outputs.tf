output "web_acl_id" {
  description = "The ID of the WAF Web ACL"
  value       = module.waf_full.web_acl_id
}

output "web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = module.waf_full.web_acl_arn
}

output "ip_set_arns" {
  description = "Map of IP set ARNs"
  value       = module.waf_full.ip_set_arns
}

output "regex_pattern_set_arns" {
  description = "Map of regex pattern set ARNs"
  value       = module.waf_full.regex_pattern_set_arns
}

output "rule_group_arns" {
  description = "Map of rule group ARNs"
  value       = module.waf_full.rule_group_arns
}
