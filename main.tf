################################################################################
# WAFv2 Module - Main Configuration
################################################################################

################################################################################
# IP Sets
################################################################################

resource "aws_wafv2_ip_set" "this" {
  for_each = local.create ? var.ip_sets : {}

  name               = "${var.name}-${each.key}"
  description        = try(each.value.description, "")
  scope              = var.scope
  ip_address_version = each.value.ip_address_version
  addresses          = each.value.addresses

  tags = merge(var.tags, try(each.value.tags, {}))
}

################################################################################
# Regex Pattern Sets
################################################################################

resource "aws_wafv2_regex_pattern_set" "this" {
  for_each = local.create ? var.regex_pattern_sets : {}

  name        = "${var.name}-${each.key}"
  description = try(each.value.description, "")
  scope       = var.scope

  dynamic "regular_expression" {
    for_each = each.value.regular_expression
    content {
      regex_string = regular_expression.value.regex_string
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}

################################################################################
# Rule Groups
################################################################################

resource "aws_wafv2_rule_group" "this" {
  for_each = local.create ? var.rule_groups : {}

  name        = "${var.name}-${each.key}"
  description = try(each.value.description, "")
  scope       = var.scope
  capacity    = each.value.capacity

  dynamic "rule" {
    for_each = each.value.rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
        dynamic "captcha" {
          for_each = rule.value.action == "captcha" ? [1] : []
          content {}
        }
        dynamic "challenge" {
          for_each = rule.value.action == "challenge" ? [1] : []
          content {}
        }
      }

      statement {
        dynamic "byte_match_statement" {
          for_each = try([rule.value.statement.byte_match_statement], [])
          content {
            positional_constraint = byte_match_statement.value.positional_constraint
            search_string         = byte_match_statement.value.search_string

            dynamic "field_to_match" {
              for_each = try([byte_match_statement.value.field_to_match], [])
              content {
                dynamic "all_query_arguments" {
                  for_each = try([field_to_match.value.all_query_arguments], [])
                  content {}
                }
                dynamic "body" {
                  for_each = try([field_to_match.value.body], [])
                  content {
                    oversize_handling = try(body.value.oversize_handling, null)
                  }
                }
                dynamic "cookies" {
                  for_each = try([field_to_match.value.cookies], [])
                  content {
                    match_scope       = cookies.value.match_scope
                    oversize_handling = cookies.value.oversize_handling
                    match_pattern {
                      included_cookies = try(cookies.value.match_pattern.included_cookies, [])
                      excluded_cookies = try(cookies.value.match_pattern.excluded_cookies, [])
                    }
                  }
                }
                dynamic "json_body" {
                  for_each = try([field_to_match.value.json_body], [])
                  content {
                    match_scope               = json_body.value.match_scope
                    invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                    oversize_handling         = try(json_body.value.oversize_handling, null)
                    match_pattern {
                      included_paths = try(json_body.value.match_pattern.included_paths, [])
                    }
                  }
                }
                dynamic "method" {
                  for_each = try([field_to_match.value.method], [])
                  content {}
                }
                dynamic "query_string" {
                  for_each = try([field_to_match.value.query_string], [])
                  content {}
                }
                dynamic "single_header" {
                  for_each = try([field_to_match.value.single_header], [])
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "single_query_argument" {
                  for_each = try([field_to_match.value.single_query_argument], [])
                  content {
                    name = single_query_argument.value.name
                  }
                }
                dynamic "uri_path" {
                  for_each = try([field_to_match.value.uri_path], [])
                  content {}
                }
              }
            }

            dynamic "text_transformation" {
              for_each = try(byte_match_statement.value.text_transformations, [])
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "ip_set_reference_statement" {
          for_each = try([rule.value.statement.ip_set_reference_statement], [])
          content {
            arn = ip_set_reference_statement.value.arn
            dynamic "ip_set_forwarded_ip_config" {
              for_each = try([ip_set_reference_statement.value.ip_set_forwarded_ip_config], [])
              content {
                header_name       = ip_set_forwarded_ip_config.value.header_name
                fallback_behavior = ip_set_forwarded_ip_config.value.fallback_behavior
                position          = ip_set_forwarded_ip_config.value.position
              }
            }
          }
        }

        dynamic "geo_match_statement" {
          for_each = try([rule.value.statement.geo_match_statement], [])
          content {
            country_codes = geo_match_statement.value.country_codes
            dynamic "forwarded_ip_config" {
              for_each = try([geo_match_statement.value.forwarded_ip_config], [])
              content {
                header_name       = forwarded_ip_config.value.header_name
                fallback_behavior = forwarded_ip_config.value.fallback_behavior
              }
            }
          }
        }

        dynamic "regex_match_statement" {
          for_each = try([rule.value.statement.regex_match_statement], [])
          content {
            regex_string = regex_match_statement.value.regex_string
            dynamic "field_to_match" {
              for_each = try([regex_match_statement.value.field_to_match], [])
              content {
                dynamic "uri_path" {
                  for_each = try([field_to_match.value.uri_path], [])
                  content {}
                }
                dynamic "query_string" {
                  for_each = try([field_to_match.value.query_string], [])
                  content {}
                }
                dynamic "single_header" {
                  for_each = try([field_to_match.value.single_header], [])
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "body" {
                  for_each = try([field_to_match.value.body], [])
                  content {
                    oversize_handling = try(body.value.oversize_handling, null)
                  }
                }
                dynamic "method" {
                  for_each = try([field_to_match.value.method], [])
                  content {}
                }
                dynamic "all_query_arguments" {
                  for_each = try([field_to_match.value.all_query_arguments], [])
                  content {}
                }
              }
            }
            dynamic "text_transformation" {
              for_each = try(regex_match_statement.value.text_transformations, [])
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "regex_pattern_set_reference_statement" {
          for_each = try([rule.value.statement.regex_pattern_set_reference_statement], [])
          content {
            arn = regex_pattern_set_reference_statement.value.arn
            dynamic "field_to_match" {
              for_each = try([regex_pattern_set_reference_statement.value.field_to_match], [])
              content {
                dynamic "uri_path" {
                  for_each = try([field_to_match.value.uri_path], [])
                  content {}
                }
                dynamic "query_string" {
                  for_each = try([field_to_match.value.query_string], [])
                  content {}
                }
                dynamic "single_header" {
                  for_each = try([field_to_match.value.single_header], [])
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "body" {
                  for_each = try([field_to_match.value.body], [])
                  content {
                    oversize_handling = try(body.value.oversize_handling, null)
                  }
                }
                dynamic "method" {
                  for_each = try([field_to_match.value.method], [])
                  content {}
                }
                dynamic "all_query_arguments" {
                  for_each = try([field_to_match.value.all_query_arguments], [])
                  content {}
                }
              }
            }
            dynamic "text_transformation" {
              for_each = try(regex_pattern_set_reference_statement.value.text_transformations, [])
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "size_constraint_statement" {
          for_each = try([rule.value.statement.size_constraint_statement], [])
          content {
            comparison_operator = size_constraint_statement.value.comparison_operator
            size                = size_constraint_statement.value.size
            dynamic "field_to_match" {
              for_each = try([size_constraint_statement.value.field_to_match], [])
              content {
                dynamic "body" {
                  for_each = try([field_to_match.value.body], [])
                  content {
                    oversize_handling = try(body.value.oversize_handling, null)
                  }
                }
                dynamic "uri_path" {
                  for_each = try([field_to_match.value.uri_path], [])
                  content {}
                }
                dynamic "query_string" {
                  for_each = try([field_to_match.value.query_string], [])
                  content {}
                }
                dynamic "single_header" {
                  for_each = try([field_to_match.value.single_header], [])
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "method" {
                  for_each = try([field_to_match.value.method], [])
                  content {}
                }
                dynamic "all_query_arguments" {
                  for_each = try([field_to_match.value.all_query_arguments], [])
                  content {}
                }
              }
            }
            dynamic "text_transformation" {
              for_each = try(size_constraint_statement.value.text_transformations, [])
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "sqli_match_statement" {
          for_each = try([rule.value.statement.sqli_match_statement], [])
          content {
            dynamic "field_to_match" {
              for_each = try([sqli_match_statement.value.field_to_match], [])
              content {
                dynamic "body" {
                  for_each = try([field_to_match.value.body], [])
                  content {
                    oversize_handling = try(body.value.oversize_handling, null)
                  }
                }
                dynamic "uri_path" {
                  for_each = try([field_to_match.value.uri_path], [])
                  content {}
                }
                dynamic "query_string" {
                  for_each = try([field_to_match.value.query_string], [])
                  content {}
                }
                dynamic "single_header" {
                  for_each = try([field_to_match.value.single_header], [])
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "method" {
                  for_each = try([field_to_match.value.method], [])
                  content {}
                }
                dynamic "all_query_arguments" {
                  for_each = try([field_to_match.value.all_query_arguments], [])
                  content {}
                }
                dynamic "json_body" {
                  for_each = try([field_to_match.value.json_body], [])
                  content {
                    match_scope               = json_body.value.match_scope
                    invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                    oversize_handling         = try(json_body.value.oversize_handling, null)
                    match_pattern {
                      included_paths = try(json_body.value.match_pattern.included_paths, [])
                    }
                  }
                }
              }
            }
            dynamic "text_transformation" {
              for_each = try(sqli_match_statement.value.text_transformations, [])
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "xss_match_statement" {
          for_each = try([rule.value.statement.xss_match_statement], [])
          content {
            dynamic "field_to_match" {
              for_each = try([xss_match_statement.value.field_to_match], [])
              content {
                dynamic "body" {
                  for_each = try([field_to_match.value.body], [])
                  content {
                    oversize_handling = try(body.value.oversize_handling, null)
                  }
                }
                dynamic "uri_path" {
                  for_each = try([field_to_match.value.uri_path], [])
                  content {}
                }
                dynamic "query_string" {
                  for_each = try([field_to_match.value.query_string], [])
                  content {}
                }
                dynamic "single_header" {
                  for_each = try([field_to_match.value.single_header], [])
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "method" {
                  for_each = try([field_to_match.value.method], [])
                  content {}
                }
                dynamic "all_query_arguments" {
                  for_each = try([field_to_match.value.all_query_arguments], [])
                  content {}
                }
              }
            }
            dynamic "text_transformation" {
              for_each = try(xss_match_statement.value.text_transformations, [])
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "rate_based_statement" {
          for_each = try([rule.value.statement.rate_based_statement], [])
          content {
            limit              = rate_based_statement.value.limit
            aggregate_key_type = try(rate_based_statement.value.aggregate_key_type, "IP")
            dynamic "scope_down_statement" {
              for_each = try([rate_based_statement.value.scope_down_statement], [])
              content {
                dynamic "geo_match_statement" {
                  for_each = try([scope_down_statement.value.geo_match_statement], [])
                  content {
                    country_codes = geo_match_statement.value.country_codes
                  }
                }
                dynamic "ip_set_reference_statement" {
                  for_each = try([scope_down_statement.value.ip_set_reference_statement], [])
                  content {
                    arn = ip_set_reference_statement.value.arn
                  }
                }
              }
            }
          }
        }

        dynamic "label_match_statement" {
          for_each = try([rule.value.statement.label_match_statement], [])
          content {
            scope = label_match_statement.value.scope
            key   = label_match_statement.value.key
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = try(rule.value.visibility_config.cloudwatch_metrics_enabled, true)
        metric_name                = try(rule.value.visibility_config.metric_name, "${each.key}-${rule.value.name}-metric")
        sampled_requests_enabled   = try(rule.value.visibility_config.sampled_requests_enabled, true)
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = try(each.value.visibility_config.cloudwatch_metrics_enabled, true)
    metric_name                = try(each.value.visibility_config.metric_name, "${var.name}-${each.key}-metric")
    sampled_requests_enabled   = try(each.value.visibility_config.sampled_requests_enabled, true)
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}

################################################################################
# Web ACL
################################################################################

resource "aws_wafv2_web_acl" "this" {
  count = local.create ? 1 : 0

  name        = var.name
  description = var.description
  scope       = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  dynamic "rule" {
    for_each = local.all_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      dynamic "action" {
        for_each = (
          try(rule.value.statement.managed_rule_group_statement, null) == null &&
          try(rule.value.statement.rule_group_reference_statement, null) == null
        ) ? [1] : []
        content {
          dynamic "allow" {
            for_each = try(rule.value.action, "allow") == "allow" ? [1] : []
            content {}
          }
          dynamic "block" {
            for_each = try(rule.value.action, "allow") == "block" ? [1] : []
            content {
              dynamic "custom_response" {
                for_each = try([rule.value.block_config], [])
                content {
                  response_code            = try(custom_response.value.response_code, 403)
                  custom_response_body_key = try(custom_response.value.custom_response_body_key, null)
                  dynamic "response_header" {
                    for_each = try(custom_response.value.response_headers, [])
                    content {
                      name  = response_header.value.name
                      value = response_header.value.value
                    }
                  }
                }
              }
            }
          }
          dynamic "count" {
            for_each = try(rule.value.action, "allow") == "count" ? [1] : []
            content {}
          }
          dynamic "captcha" {
            for_each = try(rule.value.action, "allow") == "captcha" ? [1] : []
            content {}
          }
          dynamic "challenge" {
            for_each = try(rule.value.action, "allow") == "challenge" ? [1] : []
            content {}
          }
        }
      }

      dynamic "override_action" {
        for_each = (
          try(rule.value.statement.managed_rule_group_statement, null) != null ||
          try(rule.value.statement.rule_group_reference_statement, null) != null
        ) ? [1] : []
        content {
          dynamic "none" {
            for_each = try(rule.value.override_action, "none") == "none" || try(rule.value.override_action, null) == null ? [1] : []
            content {}
          }
          dynamic "count" {
            for_each = try(rule.value.override_action, "none") == "count" ? [1] : []
            content {}
          }
        }
      }

      statement {
        dynamic "managed_rule_group_statement" {
          for_each = try([rule.value.statement.managed_rule_group_statement], [])
          content {
            name        = managed_rule_group_statement.value.name
            vendor_name = managed_rule_group_statement.value.vendor_name
            version     = try(managed_rule_group_statement.value.version, null)

            dynamic "rule_action_override" {
              for_each = try(managed_rule_group_statement.value.rule_action_overrides, {})
              content {
                name = rule_action_override.key
                action_to_use {
                  dynamic "allow" {
                    for_each = rule_action_override.value.action == "allow" ? [1] : []
                    content {}
                  }
                  dynamic "block" {
                    for_each = rule_action_override.value.action == "block" ? [1] : []
                    content {}
                  }
                  dynamic "count" {
                    for_each = rule_action_override.value.action == "count" ? [1] : []
                    content {}
                  }
                  dynamic "captcha" {
                    for_each = rule_action_override.value.action == "captcha" ? [1] : []
                    content {}
                  }
                  dynamic "challenge" {
                    for_each = rule_action_override.value.action == "challenge" ? [1] : []
                    content {}
                  }
                }
              }
            }

            dynamic "scope_down_statement" {
              for_each = try([managed_rule_group_statement.value.scope_down_statement], [])
              content {
                dynamic "geo_match_statement" {
                  for_each = try([scope_down_statement.value.geo_match_statement], [])
                  content {
                    country_codes = geo_match_statement.value.country_codes
                  }
                }
                dynamic "ip_set_reference_statement" {
                  for_each = try([scope_down_statement.value.ip_set_reference_statement], [])
                  content {
                    arn = ip_set_reference_statement.value.arn
                  }
                }
              }
            }
          }
        }

        dynamic "rule_group_reference_statement" {
          for_each = try([rule.value.statement.rule_group_reference_statement], [])
          content {
            # Support both arn (external) and rule_group_key (module-created rule groups)
            arn = try(rule_group_reference_statement.value.arn, null) != null ? rule_group_reference_statement.value.arn : aws_wafv2_rule_group.this[rule_group_reference_statement.value.rule_group_key].arn
          }
        }

        dynamic "rate_based_statement" {
          for_each = try([rule.value.statement.rate_based_statement], [])
          content {
            limit              = rate_based_statement.value.limit
            aggregate_key_type = try(rate_based_statement.value.aggregate_key_type, "IP")

            dynamic "scope_down_statement" {
              for_each = try([rate_based_statement.value.scope_down_statement], [])
              content {
                dynamic "geo_match_statement" {
                  for_each = try([scope_down_statement.value.geo_match_statement], [])
                  content {
                    country_codes = geo_match_statement.value.country_codes
                  }
                }
                dynamic "ip_set_reference_statement" {
                  for_each = try([scope_down_statement.value.ip_set_reference_statement], [])
                  content {
                    arn = ip_set_reference_statement.value.arn
                  }
                }
              }
            }
          }
        }

        dynamic "ip_set_reference_statement" {
          for_each = try([rule.value.statement.ip_set_reference_statement], [])
          content {
            # Support both arn (external) and ip_set_key (module-created IP sets)
            arn = try(ip_set_reference_statement.value.arn, null) != null ? ip_set_reference_statement.value.arn : aws_wafv2_ip_set.this[ip_set_reference_statement.value.ip_set_key].arn
          }
        }

        dynamic "geo_match_statement" {
          for_each = try([rule.value.statement.geo_match_statement], [])
          content {
            country_codes = geo_match_statement.value.country_codes
            dynamic "forwarded_ip_config" {
              for_each = try([geo_match_statement.value.forwarded_ip_config], [])
              content {
                header_name       = forwarded_ip_config.value.header_name
                fallback_behavior = forwarded_ip_config.value.fallback_behavior
              }
            }
          }
        }

        dynamic "byte_match_statement" {
          for_each = try([rule.value.statement.byte_match_statement], [])
          content {
            positional_constraint = byte_match_statement.value.positional_constraint
            search_string         = byte_match_statement.value.search_string

            dynamic "field_to_match" {
              for_each = try([byte_match_statement.value.field_to_match], [])
              content {
                dynamic "all_query_arguments" {
                  for_each = try([field_to_match.value.all_query_arguments], [])
                  content {}
                }
                dynamic "body" {
                  for_each = try([field_to_match.value.body], [])
                  content {
                    oversize_handling = try(body.value.oversize_handling, null)
                  }
                }
                dynamic "method" {
                  for_each = try([field_to_match.value.method], [])
                  content {}
                }
                dynamic "query_string" {
                  for_each = try([field_to_match.value.query_string], [])
                  content {}
                }
                dynamic "single_header" {
                  for_each = try([field_to_match.value.single_header], [])
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "uri_path" {
                  for_each = try([field_to_match.value.uri_path], [])
                  content {}
                }
              }
            }

            dynamic "text_transformation" {
              for_each = try(byte_match_statement.value.text_transformations, [])
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "regex_match_statement" {
          for_each = try([rule.value.statement.regex_match_statement], [])
          content {
            regex_string = regex_match_statement.value.regex_string

            dynamic "field_to_match" {
              for_each = try([regex_match_statement.value.field_to_match], [])
              content {
                dynamic "uri_path" {
                  for_each = try([field_to_match.value.uri_path], [])
                  content {}
                }
                dynamic "query_string" {
                  for_each = try([field_to_match.value.query_string], [])
                  content {}
                }
                dynamic "single_header" {
                  for_each = try([field_to_match.value.single_header], [])
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "body" {
                  for_each = try([field_to_match.value.body], [])
                  content {
                    oversize_handling = try(body.value.oversize_handling, null)
                  }
                }
                dynamic "method" {
                  for_each = try([field_to_match.value.method], [])
                  content {}
                }
                dynamic "all_query_arguments" {
                  for_each = try([field_to_match.value.all_query_arguments], [])
                  content {}
                }
              }
            }

            dynamic "text_transformation" {
              for_each = try(regex_match_statement.value.text_transformations, [])
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "regex_pattern_set_reference_statement" {
          for_each = try([rule.value.statement.regex_pattern_set_reference_statement], [])
          content {
            # Support both arn (external) and regex_pattern_set_key (module-created)
            arn = try(regex_pattern_set_reference_statement.value.arn, null) != null ? regex_pattern_set_reference_statement.value.arn : aws_wafv2_regex_pattern_set.this[regex_pattern_set_reference_statement.value.regex_pattern_set_key].arn

            dynamic "field_to_match" {
              for_each = try([regex_pattern_set_reference_statement.value.field_to_match], [])
              content {
                dynamic "uri_path" {
                  for_each = try([field_to_match.value.uri_path], [])
                  content {}
                }
                dynamic "query_string" {
                  for_each = try([field_to_match.value.query_string], [])
                  content {}
                }
                dynamic "single_header" {
                  for_each = try([field_to_match.value.single_header], [])
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "body" {
                  for_each = try([field_to_match.value.body], [])
                  content {
                    oversize_handling = try(body.value.oversize_handling, null)
                  }
                }
                dynamic "method" {
                  for_each = try([field_to_match.value.method], [])
                  content {}
                }
                dynamic "all_query_arguments" {
                  for_each = try([field_to_match.value.all_query_arguments], [])
                  content {}
                }
              }
            }

            dynamic "text_transformation" {
              for_each = try(regex_pattern_set_reference_statement.value.text_transformations, [])
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "size_constraint_statement" {
          for_each = try([rule.value.statement.size_constraint_statement], [])
          content {
            comparison_operator = size_constraint_statement.value.comparison_operator
            size                = size_constraint_statement.value.size

            dynamic "field_to_match" {
              for_each = try([size_constraint_statement.value.field_to_match], [])
              content {
                dynamic "body" {
                  for_each = try([field_to_match.value.body], [])
                  content {
                    oversize_handling = try(body.value.oversize_handling, null)
                  }
                }
                dynamic "uri_path" {
                  for_each = try([field_to_match.value.uri_path], [])
                  content {}
                }
                dynamic "query_string" {
                  for_each = try([field_to_match.value.query_string], [])
                  content {}
                }
                dynamic "single_header" {
                  for_each = try([field_to_match.value.single_header], [])
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "method" {
                  for_each = try([field_to_match.value.method], [])
                  content {}
                }
                dynamic "all_query_arguments" {
                  for_each = try([field_to_match.value.all_query_arguments], [])
                  content {}
                }
              }
            }

            dynamic "text_transformation" {
              for_each = try(size_constraint_statement.value.text_transformations, [])
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "sqli_match_statement" {
          for_each = try([rule.value.statement.sqli_match_statement], [])
          content {
            dynamic "field_to_match" {
              for_each = try([sqli_match_statement.value.field_to_match], [])
              content {
                dynamic "body" {
                  for_each = try([field_to_match.value.body], [])
                  content {
                    oversize_handling = try(body.value.oversize_handling, null)
                  }
                }
                dynamic "uri_path" {
                  for_each = try([field_to_match.value.uri_path], [])
                  content {}
                }
                dynamic "query_string" {
                  for_each = try([field_to_match.value.query_string], [])
                  content {}
                }
                dynamic "single_header" {
                  for_each = try([field_to_match.value.single_header], [])
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "method" {
                  for_each = try([field_to_match.value.method], [])
                  content {}
                }
                dynamic "all_query_arguments" {
                  for_each = try([field_to_match.value.all_query_arguments], [])
                  content {}
                }
                dynamic "json_body" {
                  for_each = try([field_to_match.value.json_body], [])
                  content {
                    match_scope               = json_body.value.match_scope
                    invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                    oversize_handling         = try(json_body.value.oversize_handling, null)
                    match_pattern {
                      included_paths = try(json_body.value.match_pattern.included_paths, [])
                    }
                  }
                }
              }
            }
            dynamic "text_transformation" {
              for_each = try(sqli_match_statement.value.text_transformations, [])
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "xss_match_statement" {
          for_each = try([rule.value.statement.xss_match_statement], [])
          content {
            dynamic "field_to_match" {
              for_each = try([xss_match_statement.value.field_to_match], [])
              content {
                dynamic "body" {
                  for_each = try([field_to_match.value.body], [])
                  content {
                    oversize_handling = try(body.value.oversize_handling, null)
                  }
                }
                dynamic "uri_path" {
                  for_each = try([field_to_match.value.uri_path], [])
                  content {}
                }
                dynamic "query_string" {
                  for_each = try([field_to_match.value.query_string], [])
                  content {}
                }
                dynamic "single_header" {
                  for_each = try([field_to_match.value.single_header], [])
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "method" {
                  for_each = try([field_to_match.value.method], [])
                  content {}
                }
                dynamic "all_query_arguments" {
                  for_each = try([field_to_match.value.all_query_arguments], [])
                  content {}
                }
              }
            }
            dynamic "text_transformation" {
              for_each = try(xss_match_statement.value.text_transformations, [])
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "label_match_statement" {
          for_each = try([rule.value.statement.label_match_statement], [])
          content {
            scope = label_match_statement.value.scope
            key   = label_match_statement.value.key
          }
        }

        dynamic "and_statement" {
          for_each = try([rule.value.statement.and_statement], [])
          content {
            dynamic "statement" {
              for_each = and_statement.value.statements
              content {
                dynamic "ip_set_reference_statement" {
                  for_each = try([statement.value.ip_set_reference_statement], [])
                  content {
                    arn = ip_set_reference_statement.value.arn
                  }
                }
                dynamic "geo_match_statement" {
                  for_each = try([statement.value.geo_match_statement], [])
                  content {
                    country_codes = geo_match_statement.value.country_codes
                  }
                }
                dynamic "byte_match_statement" {
                  for_each = try([statement.value.byte_match_statement], [])
                  content {
                    positional_constraint = byte_match_statement.value.positional_constraint
                    search_string         = byte_match_statement.value.search_string
                    dynamic "field_to_match" {
                      for_each = try([byte_match_statement.value.field_to_match], [])
                      content {
                        dynamic "query_string" {
                          for_each = try([field_to_match.value.query_string], [])
                          content {}
                        }
                        dynamic "single_header" {
                          for_each = try([field_to_match.value.single_header], [])
                          content {
                            name = single_header.value.name
                          }
                        }
                        dynamic "uri_path" {
                          for_each = try([field_to_match.value.uri_path], [])
                          content {}
                        }
                        dynamic "body" {
                          for_each = try([field_to_match.value.body], [])
                          content {}
                        }
                        dynamic "method" {
                          for_each = try([field_to_match.value.method], [])
                          content {}
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = try(byte_match_statement.value.text_transformations, [])
                      content {
                        priority = text_transformation.value.priority
                        type     = text_transformation.value.type
                      }
                    }
                  }
                }
                dynamic "label_match_statement" {
                  for_each = try([statement.value.label_match_statement], [])
                  content {
                    scope = label_match_statement.value.scope
                    key   = label_match_statement.value.key
                  }
                }
              }
            }
          }
        }

        dynamic "or_statement" {
          for_each = try([rule.value.statement.or_statement], [])
          content {
            dynamic "statement" {
              for_each = or_statement.value.statements
              content {
                dynamic "ip_set_reference_statement" {
                  for_each = try([statement.value.ip_set_reference_statement], [])
                  content {
                    arn = ip_set_reference_statement.value.arn
                  }
                }
                dynamic "geo_match_statement" {
                  for_each = try([statement.value.geo_match_statement], [])
                  content {
                    country_codes = geo_match_statement.value.country_codes
                  }
                }
                dynamic "byte_match_statement" {
                  for_each = try([statement.value.byte_match_statement], [])
                  content {
                    positional_constraint = byte_match_statement.value.positional_constraint
                    search_string         = byte_match_statement.value.search_string
                    dynamic "field_to_match" {
                      for_each = try([byte_match_statement.value.field_to_match], [])
                      content {
                        dynamic "query_string" {
                          for_each = try([field_to_match.value.query_string], [])
                          content {}
                        }
                        dynamic "single_header" {
                          for_each = try([field_to_match.value.single_header], [])
                          content {
                            name = single_header.value.name
                          }
                        }
                        dynamic "uri_path" {
                          for_each = try([field_to_match.value.uri_path], [])
                          content {}
                        }
                        dynamic "body" {
                          for_each = try([field_to_match.value.body], [])
                          content {}
                        }
                        dynamic "method" {
                          for_each = try([field_to_match.value.method], [])
                          content {}
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = try(byte_match_statement.value.text_transformations, [])
                      content {
                        priority = text_transformation.value.priority
                        type     = text_transformation.value.type
                      }
                    }
                  }
                }
                dynamic "label_match_statement" {
                  for_each = try([statement.value.label_match_statement], [])
                  content {
                    scope = label_match_statement.value.scope
                    key   = label_match_statement.value.key
                  }
                }
              }
            }
          }
        }

        dynamic "not_statement" {
          for_each = try([rule.value.statement.not_statement], [])
          content {
            dynamic "statement" {
              for_each = [not_statement.value.statement]
              content {
                dynamic "ip_set_reference_statement" {
                  for_each = try([statement.value.ip_set_reference_statement], [])
                  content {
                    arn = ip_set_reference_statement.value.arn
                  }
                }
                dynamic "geo_match_statement" {
                  for_each = try([statement.value.geo_match_statement], [])
                  content {
                    country_codes = geo_match_statement.value.country_codes
                  }
                }
                dynamic "byte_match_statement" {
                  for_each = try([statement.value.byte_match_statement], [])
                  content {
                    positional_constraint = byte_match_statement.value.positional_constraint
                    search_string         = byte_match_statement.value.search_string
                    dynamic "field_to_match" {
                      for_each = try([byte_match_statement.value.field_to_match], [])
                      content {
                        dynamic "query_string" {
                          for_each = try([field_to_match.value.query_string], [])
                          content {}
                        }
                        dynamic "single_header" {
                          for_each = try([field_to_match.value.single_header], [])
                          content {
                            name = single_header.value.name
                          }
                        }
                        dynamic "uri_path" {
                          for_each = try([field_to_match.value.uri_path], [])
                          content {}
                        }
                        dynamic "body" {
                          for_each = try([field_to_match.value.body], [])
                          content {}
                        }
                        dynamic "method" {
                          for_each = try([field_to_match.value.method], [])
                          content {}
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = try(byte_match_statement.value.text_transformations, [])
                      content {
                        priority = text_transformation.value.priority
                        type     = text_transformation.value.type
                      }
                    }
                  }
                }
                dynamic "label_match_statement" {
                  for_each = try([statement.value.label_match_statement], [])
                  content {
                    scope = label_match_statement.value.scope
                    key   = label_match_statement.value.key
                  }
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = try(rule.value.visibility_config.cloudwatch_metrics_enabled, true)
        metric_name                = try(rule.value.visibility_config.metric_name, "${rule.value.name}-metric")
        sampled_requests_enabled   = try(rule.value.visibility_config.sampled_requests_enabled, true)
      }
    }
  }

  dynamic "custom_response_body" {
    for_each = var.custom_response_bodies
    content {
      key          = custom_response_body.key
      content      = custom_response_body.value.content
      content_type = custom_response_body.value.content_type
    }
  }

  dynamic "captcha_config" {
    for_each = var.captcha_config != null ? [var.captcha_config] : []
    content {
      immunity_time_property {
        immunity_time = captcha_config.value.immunity_time_property.immunity_time
      }
    }
  }

  dynamic "challenge_config" {
    for_each = var.challenge_config != null ? [var.challenge_config] : []
    content {
      immunity_time_property {
        immunity_time = challenge_config.value.immunity_time_property.immunity_time
      }
    }
  }

  token_domains = var.token_domains

  visibility_config {
    cloudwatch_metrics_enabled = local.web_acl_visibility_config.cloudwatch_metrics_enabled
    metric_name                = local.web_acl_visibility_config.metric_name
    sampled_requests_enabled   = local.web_acl_visibility_config.sampled_requests_enabled
  }

  tags = merge(var.tags, var.web_acl_tags)
}

################################################################################
# Web ACL Association
################################################################################

resource "aws_wafv2_web_acl_association" "this" {
  for_each = local.create ? toset(var.resource_arns) : []

  resource_arn = each.value
  web_acl_arn  = aws_wafv2_web_acl.this[0].arn
}
