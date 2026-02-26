module "waf_api_hardened" {
  source = "../.."

  name        = "api-hardened-preset"
  description = "API hardened preset with path rate limits"
  scope       = "REGIONAL"
  preset      = "api_hardened"

  path_rate_limits = [
    {
      path  = "/api/login"
      limit = 100
    },
    {
      path  = "/api/register"
      limit = 50
    }
  ]

  enable_logging = true
  logging_mode   = "s3"

  tags = {
    Example = "preset-api-hardened"
  }
}

output "web_acl_id" {
  value = module.waf_api_hardened.web_acl_id
}

output "web_acl_arn" {
  value = module.waf_api_hardened.web_acl_arn
}

output "log_bucket_name" {
  value = module.waf_api_hardened.log_bucket_name
}
