provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region (use us-east-1 for CloudFront)"
  type        = string
  default     = "us-east-1"
}
