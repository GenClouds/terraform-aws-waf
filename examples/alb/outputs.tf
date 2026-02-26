output "web_acl_id" {
  description = "The ID of the WAF Web ACL"
  value       = module.waf_alb.web_acl_id
}

output "web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = module.waf_alb.web_acl_arn
}

output "ip_set_arns" {
  description = "Map of IP set ARNs"
  value       = module.waf_alb.ip_set_arns
}
