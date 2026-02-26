module "waf_monitor" {
  source = "../.."

  name        = "monitor-mode-example"
  description = "Monitor mode testing example"
  scope       = "REGIONAL"
  mode        = "monitor"

  simple_rules = [
    {
      name          = "BlockBadIPs"
      priority      = 1
      action        = "block"
      country_codes = ["CN", "RU"]
    }
  ]

  tags = {
    Example = "monitor-mode"
  }
}

output "web_acl_id" {
  value = module.waf_monitor.web_acl_id
}
