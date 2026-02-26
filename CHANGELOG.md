# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of AWS WAFv2 Terraform module
- Web ACL creation with customizable default action
- AWS Managed Rule Groups support with rule action overrides
- Custom Rule Groups with full statement support
- IP Sets (IPv4 and IPv6) with self-referencing capability
- Regex Pattern Sets with self-referencing capability
- Rate-based rules with scope-down statements
- Geo-blocking with forwarded IP configuration
- Statement nesting (AND, OR, NOT)
- Multiple inspection types (byte match, regex, size constraint, SQLi, XSS, label matching)
- Field to match support (body, JSON body, headers, query string, URI path, method, cookies)
- Actions support (allow, block, count, CAPTCHA, challenge)
- Logging configuration (Kinesis Firehose, CloudWatch Logs, S3)
- Web ACL associations (ALB, API Gateway, AppSync, CloudFront)
- Custom response bodies
- CAPTCHA and Challenge configuration
- Comprehensive examples (minimal, cloudfront, alb, apigw, full)
