################################################################################
# S3 Bucket for WAF Logs
################################################################################

resource "aws_s3_bucket" "waf_logs" {
  count = local.create_logging_resources ? 1 : 0

  bucket        = local.log_bucket_name
  force_destroy = var.log_bucket_force_destroy

  tags = merge(var.tags, {
    Name = local.log_bucket_name
  })
}

resource "aws_s3_bucket_public_access_block" "waf_logs" {
  count = local.create_logging_resources ? 1 : 0

  bucket = aws_s3_bucket.waf_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logs" {
  count = local.create_logging_resources ? 1 : 0

  bucket = aws_s3_bucket.waf_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.enable_kms_encryption ? "aws:kms" : "AES256"
      kms_master_key_id = var.enable_kms_encryption ? aws_kms_key.waf_logs[0].arn : null
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "waf_logs" {
  count = local.create_logging_resources && var.log_retention_days > 0 ? 1 : 0

  bucket = aws_s3_bucket.waf_logs[0].id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    expiration {
      days = var.log_retention_days
    }
  }
}

################################################################################
# KMS Key for Encryption
################################################################################

resource "aws_kms_key" "waf_logs" {
  count = local.create_logging_resources && var.enable_kms_encryption ? 1 : 0

  description             = "KMS key for WAF logs encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "${var.name}-waf-logs-key"
  })
}

resource "aws_kms_alias" "waf_logs" {
  count = local.create_logging_resources && var.enable_kms_encryption ? 1 : 0

  name          = "alias/${var.name}-waf-logs"
  target_key_id = aws_kms_key.waf_logs[0].key_id
}

################################################################################
# IAM Role for Firehose
################################################################################

resource "aws_iam_role" "firehose" {
  count = local.create_logging_resources ? 1 : 0

  name = "${var.name}-waf-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "firehose.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "firehose" {
  count = local.create_logging_resources ? 1 : 0

  name = "${var.name}-waf-firehose-policy"
  role = aws_iam_role.firehose[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.waf_logs[0].arn,
          "${aws_s3_bucket.waf_logs[0].arn}/*"
        ]
      }
      ],
      var.enable_kms_encryption ? [{
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [aws_kms_key.waf_logs[0].arn]
      }] : []
    )
  })
}

################################################################################
# Kinesis Firehose Delivery Stream
################################################################################

resource "aws_kinesis_firehose_delivery_stream" "waf_logs" {
  count = local.create_logging_resources ? 1 : 0

  name        = local.firehose_name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose[0].arn
    bucket_arn = aws_s3_bucket.waf_logs[0].arn
    prefix     = "waf-logs/"

    compression_format = "GZIP"

    dynamic "cloudwatch_logging_options" {
      for_each = var.firehose_cloudwatch_logging ? [1] : []
      content {
        enabled         = true
        log_group_name  = "/aws/kinesisfirehose/${local.firehose_name}"
        log_stream_name = "S3Delivery"
      }
    }
  }

  tags = var.tags

  depends_on = [aws_iam_role_policy.firehose]
}

################################################################################
# WAF Logging Configuration
################################################################################

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = local.create && var.enable_logging ? 1 : 0

  resource_arn = aws_wafv2_web_acl.this[0].arn

  log_destination_configs = var.logging_mode == "s3" ? [
    aws_kinesis_firehose_delivery_stream.waf_logs[0].arn
  ] : var.log_destination_configs

  dynamic "redacted_fields" {
    for_each = var.redacted_fields
    content {
      dynamic "method" {
        for_each = try(redacted_fields.value.method, false) ? [1] : []
        content {}
      }
      dynamic "uri_path" {
        for_each = try(redacted_fields.value.uri_path, false) ? [1] : []
        content {}
      }
      dynamic "query_string" {
        for_each = try(redacted_fields.value.query_string, false) ? [1] : []
        content {}
      }
      dynamic "single_header" {
        for_each = try([redacted_fields.value.single_header], [])
        content {
          name = single_header.value.name
        }
      }
    }
  }

  dynamic "logging_filter" {
    for_each = var.logging_filter != null ? [var.logging_filter] : []
    content {
      default_behavior = logging_filter.value.default_behavior

      dynamic "filter" {
        for_each = logging_filter.value.filter
        content {
          behavior    = filter.value.behavior
          requirement = filter.value.requirement

          dynamic "condition" {
            for_each = try(filter.value.condition, [])
            content {
              dynamic "action_condition" {
                for_each = try([condition.value.action_condition], [])
                content {
                  action = action_condition.value.action
                }
              }
              dynamic "label_name_condition" {
                for_each = try([condition.value.label_name_condition], [])
                content {
                  label_name = label_name_condition.value.label_name
                }
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    aws_kinesis_firehose_delivery_stream.waf_logs,
    aws_s3_bucket.waf_logs
  ]
}
