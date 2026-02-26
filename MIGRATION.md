# Migration Guide

This guide helps you migrate from other popular Terraform WAF modules to this module.

## Comparison Matrix

| Feature | This Module | CloudPosse | DNXLabs | UMOTIF | SourceFuse |
|---------|-------------|------------|---------|--------|------------|
| Simple Rules DSL | ✅ | ❌ | ❌ | ❌ | ❌ |
| Presets | ✅ | ❌ | ❌ | ❌ | ❌ |
| Monitor Mode | ✅ | ❌ | ❌ | ❌ | ❌ |
| Auto S3 Logging | ✅ | ❌ | ❌ | ❌ | ❌ |
| Path Rate Limits | ✅ | ❌ | ❌ | ❌ | ❌ |
| Self-Referencing | ✅ | ❌ | ✅ | ❌ | ❌ |
| Rule Groups | ✅ | ✅ | ✅ | ✅ | ✅ |
| IP Sets | ✅ | ✅ | ✅ | ✅ | ✅ |
| Managed Rules | ✅ | ✅ | ✅ | ✅ | ✅ |

## From CloudPosse (cloudposse/waf/aws)

### Before
```hcl
module "waf" {
  source  = "cloudposse/waf/aws"
  version = "~> 1.0"

  name = "my-waf"
  
  managed_rule_group_statement_rules = [
    {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 1
      statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
  ]
}
```

### After
```hcl
module "waf" {
  source = "terraform-aws-modules/waf/aws"

  name = "my-waf"
  
  simple_rules = [
    {
      name               = "AWSManagedCommon"
      priority           = 1
      managed_rule_group = "AWSManagedRulesCommonRuleSet"
    }
  ]
}
```

## From DNXLabs (DNXLabs/waf/aws)

### Before
```hcl
module "waf" {
  source = "DNXLabs/waf/aws"

  waf_name = "my-waf"
  
  rules = [
    {
      name     = "RateLimit"
      priority = 1
      action   = "block"
      rate_limit = 2000
    }
  ]
}
```

### After
```hcl
module "waf" {
  source = "terraform-aws-modules/waf/aws"

  name = "my-waf"
  
  simple_rules = [
    {
      name       = "RateLimit"
      priority   = 1
      rate_limit = 2000
    }
  ]
}
```

## From UMOTIF (umotif-public/waf-webaclv2/aws)

### Before
```hcl
module "waf" {
  source = "umotif-public/waf-webaclv2/aws"

  name_prefix = "my-waf"
  
  rules = [
    {
      name     = "GeoBlock"
      priority = 1
      action   = "block"
      geo_match_statement = {
        country_codes = ["CN", "RU"]
      }
    }
  ]
}
```

### After
```hcl
module "waf" {
  source = "terraform-aws-modules/waf/aws"

  name = "my-waf"
  
  simple_rules = [
    {
      name          = "GeoBlock"
      priority      = 1
      country_codes = ["CN", "RU"]
    }
  ]
}
```

## Using Presets

Instead of manually configuring common patterns:

```hcl
module "waf" {
  source = "terraform-aws-modules/waf/aws"

  name   = "my-api-waf"
  preset = "api_hardened"
  
  # Automatically includes:
  # - AWSManagedRulesCommonRuleSet
  # - AWSManagedRulesKnownBadInputsRuleSet
  # - Rate limiting (2000 req/5min)
}
```

## Monitor Mode

Test rules without blocking:

```hcl
module "waf" {
  source = "terraform-aws-modules/waf/aws"

  name = "my-waf"
  mode = "monitor"  # All block actions become count
  
  simple_rules = [
    {
      name          = "TestGeoBlock"
      priority      = 1
      country_codes = ["CN"]
    }
  ]
}
```

## Auto S3 Logging

No need to create S3 buckets, Firehose, IAM roles manually:

```hcl
module "waf" {
  source = "terraform-aws-modules/waf/aws"

  name = "my-waf"
  
  enable_logging        = true
  logging_mode          = "s3"
  log_retention_days    = 30
  enable_kms_encryption = true
  
  # Everything created automatically
}
```

## Key Advantages

1. **Simpler Syntax** - `simple_rules` DSL reduces boilerplate by 70%
2. **Presets** - Production-ready configurations in one line
3. **Monitor Mode** - Safe testing without blocking traffic
4. **Auto Logging** - Complete logging pipeline with one flag
5. **Path Rate Limits** - Protect specific endpoints easily
6. **Self-Referencing** - No circular dependency issues
