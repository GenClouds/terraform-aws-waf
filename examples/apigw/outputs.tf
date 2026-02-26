output "web_acl_id" {
  description = "The ID of the WAF Web ACL"
  value       = module.waf_apigw.web_acl_id
}

output "web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = module.waf_apigw.web_acl_arn
}
