################################################################################
# Web ACL
################################################################################

output "web_acl_id" {
  description = "The ID of the WAF WebACL"
  value       = try(aws_wafv2_web_acl.this[0].id, null)
}

output "web_acl_arn" {
  description = "The ARN of the WAF WebACL"
  value       = try(aws_wafv2_web_acl.this[0].arn, null)
}

output "web_acl_capacity" {
  description = "The web ACL capacity units (WCUs) currently being used by this web ACL"
  value       = try(aws_wafv2_web_acl.this[0].capacity, null)
}

output "web_acl_name" {
  description = "The name of the WAF WebACL"
  value       = try(aws_wafv2_web_acl.this[0].name, null)
}

output "web_acl_visibility_config" {
  description = "The visibility configuration of the WAF WebACL"
  value       = try(aws_wafv2_web_acl.this[0].visibility_config, null)
}

################################################################################
# IP Sets
################################################################################

output "ip_sets" {
  description = "Map of IP sets created and their attributes"
  value = {
    for k, v in aws_wafv2_ip_set.this : k => {
      id   = v.id
      arn  = v.arn
      name = v.name
    }
  }
}

output "ip_set_arns" {
  description = "Map of IP set ARNs"
  value       = { for k, v in aws_wafv2_ip_set.this : k => v.arn }
}

################################################################################
# Regex Pattern Sets
################################################################################

output "regex_pattern_sets" {
  description = "Map of regex pattern sets created and their attributes"
  value = {
    for k, v in aws_wafv2_regex_pattern_set.this : k => {
      id   = v.id
      arn  = v.arn
      name = v.name
    }
  }
}

output "regex_pattern_set_arns" {
  description = "Map of regex pattern set ARNs"
  value       = { for k, v in aws_wafv2_regex_pattern_set.this : k => v.arn }
}

################################################################################
# Rule Groups
################################################################################

output "rule_groups" {
  description = "Map of rule groups created and their attributes"
  value = {
    for k, v in aws_wafv2_rule_group.this : k => {
      id       = v.id
      arn      = v.arn
      name     = v.name
      capacity = v.capacity
    }
  }
}

output "rule_group_arns" {
  description = "Map of rule group ARNs"
  value       = { for k, v in aws_wafv2_rule_group.this : k => v.arn }
}

################################################################################
# Logging Configuration
################################################################################

output "logging_configuration_id" {
  description = "The ID of the WAF WebACL logging configuration"
  value       = try(aws_wafv2_web_acl_logging_configuration.this[0].id, null)
}

output "logging_configuration_enabled" {
  description = "Whether logging is enabled for the Web ACL"
  value       = var.enable_logging
}

output "log_bucket_name" {
  description = "Name of the S3 bucket for WAF logs"
  value       = try(aws_s3_bucket.waf_logs[0].id, null)
}

output "log_bucket_arn" {
  description = "ARN of the S3 bucket for WAF logs"
  value       = try(aws_s3_bucket.waf_logs[0].arn, null)
}

output "firehose_arn" {
  description = "ARN of the Kinesis Firehose delivery stream"
  value       = try(aws_kinesis_firehose_delivery_stream.waf_logs[0].arn, null)
}

output "kms_key_arn" {
  description = "ARN of the KMS key for log encryption"
  value       = try(aws_kms_key.waf_logs[0].arn, null)
}

################################################################################
# Web ACL Associations
################################################################################

output "web_acl_associations" {
  description = "Map of Web ACL associations"
  value       = { for k, v in aws_wafv2_web_acl_association.this : k => v.id }
}
