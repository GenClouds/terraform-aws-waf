# Examples

This directory contains working examples demonstrating different use cases for the AWS WAFv2 Terraform module.

## Available Examples

### [Minimal](./minimal)
Basic Web ACL with AWS Managed Rules Common Rule Set. Perfect starting point for simple WAF deployments.

**Features:**
- AWS Managed Rules Common Rule Set
- Default allow action
- CloudWatch metrics enabled

### [CloudFront](./cloudfront)
WAF configuration for CloudFront distributions with managed rules and rate limiting.

**Features:**
- CLOUDFRONT scope
- AWS Managed Rules (Common + Known Bad Inputs)
- Rate-based rule (2000 requests per 5 minutes)

### [ALB](./alb)
Application Load Balancer protection with IP sets and rate limiting.

**Features:**
- IP set blocking
- Rate-based rule
- ALB association

### [API Gateway](./apigw)
API Gateway protection with geo-blocking and rate limiting.

**Features:**
- Geo-blocking (country-based)
- Rate-based rule
- API Gateway stage association

### [Full](./full)
Comprehensive example demonstrating all module capabilities.

**Features:**
- IP sets with self-referencing
- Regex pattern sets
- Custom rule groups
- Managed rules with action overrides
- Rate limiting
- Multiple rule types
- Resource associations

## Running Examples

1. Navigate to the example directory:
   ```bash
   cd examples/minimal
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

5. Clean up:
   ```bash
   terraform destroy
   ```

## Notes

- All examples use `source = "../.."` to reference the local module
- Update `source` to use the registry version in production: `source = "terraform-aws-modules/waf/aws"`
- Customize variables in each example's `variables.tf` or create a `terraform.tfvars` file
- Ensure you have appropriate AWS credentials configured
