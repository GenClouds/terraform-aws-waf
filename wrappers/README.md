# Wrapper for the root WAFv2 module

The configuration in this directory implements the **single-module wrapper** pattern used by the official `terraform-aws-modules` repositories. It allows you to manage **multiple WAF configurations** (Web ACLs) in a single Terragrunt or Terraform layer without duplicating code.

This wrapper does not add any extra functionality; it just passes inputs through to the root WAFv2 module.

## Usage with Terragrunt

`terragrunt.hcl`:

```hcl
terraform {
  source = "tfr:///terraform-aws-modules/waf/aws//wrappers"
  # Or from git:
  # source = "git::git@github.com:terraform-aws-modules/terraform-aws-waf.git//wrappers?ref=main"
}

inputs = {
  defaults = {
    create = true
    scope  = "REGIONAL"
    tags = {
      Terraform   = "true"
      Environment = "dev"
    }
  }

  items = {
    api-waf = {
      name   = "api-waf"
      preset = "api_hardened"
    }

    website-waf = {
      name   = "website-waf"
      preset = "website"
    }
  }
}
```

## Usage with Terraform

```hcl
module "waf_wrapper" {
  source = "terraform-aws-modules/waf/aws//wrappers"

  defaults = {
    create = true
    scope  = "REGIONAL"
  }

  items = {
    api-waf = {
      name   = "api-waf"
      preset = "api_hardened"
    }
    website-waf = {
      name   = "website-waf"
      preset = "website"
    }
  }
}
```

You can pass **any root module argument** via `defaults` or per-item overrides in `items`. The wrapper will merge them using `try(each.value.<var>, var.defaults.<var>, <sensible default>)`.

