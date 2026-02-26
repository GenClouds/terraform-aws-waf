################################################################################
# WAFv2 Module - Variables
################################################################################

variable "create" {
  description = "Controls whether WAF resources should be created"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the Web ACL and prefix for child resources"
  type        = string
}

variable "description" {
  description = "Description of the Web ACL"
  type        = string
  default     = ""
}

variable "scope" {
  description = "Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values: CLOUDFRONT, REGIONAL"
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["CLOUDFRONT", "REGIONAL"], var.scope)
    error_message = "Scope must be either CLOUDFRONT or REGIONAL."
  }
}

variable "default_action" {
  description = "Action to perform if none of the rules match. Valid values: allow, block"
  type        = string
  default     = "allow"

  validation {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "Default action must be either allow or block."
  }
}

variable "rules" {
  description = "List of WAF rules to attach to the Web ACL. Use action for non-rule-group rules; use override_action for managed/custom rule group rules."
  type        = any
  default     = []
}

variable "simple_rules" {
  description = "Simplified DSL for common rule patterns. Automatically transformed into full rules."
  type = list(object({
    name               = string
    priority           = number
    action             = optional(string, "block")
    enabled            = optional(bool, true)
    ip_set_key         = optional(string)
    ip_addresses       = optional(list(string))
    country_codes      = optional(list(string))
    rate_limit         = optional(number)
    aggregate_key_type = optional(string, "IP")
    managed_rule_group = optional(string)
    vendor_name        = optional(string, "AWS")
    override_action    = optional(string, "none")
    visibility_config  = optional(map(any), {})
  }))
  default = []
}

variable "mode" {
  description = "Operating mode: 'block' (default) or 'monitor' (converts all actions to count)"
  type        = string
  default     = "block"
  validation {
    condition     = contains(["block", "monitor"], var.mode)
    error_message = "Mode must be either 'block' or 'monitor'."
  }
}

variable "preset" {
  description = "Apply a preset configuration: '', 'api_hardened', 'website', 'bot_defense', 'zero_trust'"
  type        = string
  default     = ""
  validation {
    condition     = contains(["", "api_hardened", "website", "bot_defense", "zero_trust"], var.preset)
    error_message = "Preset must be one of: '', 'api_hardened', 'website', 'bot_defense', 'zero_trust'."
  }
}

variable "path_rate_limits" {
  description = "Per-path rate limiting configuration"
  type = list(object({
    path  = string
    limit = number
  }))
  default = []
}

variable "visibility_config" {
  description = "Visibility configuration for the Web ACL CloudWatch metrics"
  type = object({
    cloudwatch_metrics_enabled = optional(bool, true)
    metric_name                = optional(string)
    sampled_requests_enabled   = optional(bool, true)
  })
  default = null
}

variable "custom_response_bodies" {
  description = "Map of custom response body key to content and content_type for use in block/captcha/challenge actions"
  type = map(object({
    content      = string
    content_type = string # Valid: TEXT_PLAIN, TEXT_HTML, APPLICATION_JSON
  }))
  default = {}
}

variable "captcha_config" {
  description = "CAPTCHA configuration for the Web ACL"
  type = object({
    immunity_time_property = object({
      immunity_time = number
    })
  })
  default = null
}

variable "challenge_config" {
  description = "Challenge configuration for the Web ACL"
  type = object({
    immunity_time_property = object({
      immunity_time = number
    })
  })
  default = null
}

variable "token_domains" {
  description = "Token domains for use with CAPTCHA and Challenge"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "web_acl_tags" {
  description = "A map of tags to add specifically to the Web ACL"
  type        = map(string)
  default     = {}
}

################################################################################
# IP Sets
################################################################################

variable "ip_sets" {
  description = "Map of IP sets to create. Key is used as suffix for the resource name."
  type = map(object({
    description        = optional(string, "")
    ip_address_version = string # IPV4 or IPV6
    addresses          = list(string)
    tags               = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# Regex Pattern Sets
################################################################################

variable "regex_pattern_sets" {
  description = "Map of regex pattern sets to create"
  type = map(object({
    description = optional(string, "")
    regular_expression = list(object({
      regex_string = string
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# Rule Groups
################################################################################

variable "rule_groups" {
  description = "Map of custom rule groups to create"
  type        = any
  default     = {}
}

################################################################################
# Logging
################################################################################

variable "enable_logging" {
  description = "Enable logging for the Web ACL"
  type        = bool
  default     = false
}

variable "logging_mode" {
  description = "Logging mode: 'cloudwatch' (use provided log_destination_configs) or 's3' (auto-create S3/Firehose)"
  type        = string
  default     = "cloudwatch"
  validation {
    condition     = contains(["cloudwatch", "s3"], var.logging_mode)
    error_message = "Logging mode must be either 'cloudwatch' or 's3'."
  }
}

variable "log_destination_configs" {
  description = "ARNs of Kinesis Firehose delivery stream, CloudWatch Log group, or S3 bucket for WAF logs (used when logging_mode = 'cloudwatch')"
  type        = list(string)
  default     = []
}

variable "log_bucket_name" {
  description = "S3 bucket name for WAF logs (auto-generated if empty, used when logging_mode = 's3')"
  type        = string
  default     = ""
}

variable "log_bucket_force_destroy" {
  description = "Force destroy S3 bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Number of days to retain logs in S3 (0 = never expire)"
  type        = number
  default     = 90
}

variable "enable_kms_encryption" {
  description = "Enable KMS encryption for S3 logs"
  type        = bool
  default     = true
}

variable "firehose_cloudwatch_logging" {
  description = "Enable CloudWatch logging for Firehose delivery stream"
  type        = bool
  default     = false
}

variable "redacted_fields" {
  description = "List of field identifiers to redact from logs"
  type        = any
  default     = []
}

variable "logging_filter" {
  description = "Filter configuration for WAF logging"
  type = object({
    default_behavior = string # KEEP or DROP
    filter = list(object({
      behavior    = string # KEEP or DROP
      requirement = string # MEETS_ALL or MEETS_ANY
      condition = optional(list(object({
        action_condition = optional(object({
          action = string
        }))
        label_name_condition = optional(object({
          label_name = string
        }))
      })), [])
    }))
  })
  default = null
}

################################################################################
# Associations
################################################################################

variable "resource_arns" {
  description = "List of ARNs of resources to associate with the Web ACL (ALB, API Gateway stage, AppSync API, CloudFront distribution, etc.)"
  type        = list(string)
  default     = []
}

