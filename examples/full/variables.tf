variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "resource_arns" {
  description = "List of resource ARNs to associate with the Web ACL (ALB, API Gateway, AppSync, etc.)"
  type        = list(string)
  default     = []
}

variable "admin_ip_cidrs" {
  description = "List of admin IP CIDR blocks to allow"
  type        = list(string)
  default     = ["203.0.113.0/24"]
}

variable "rate_limit" {
  description = "Maximum number of requests per 5 minutes per IP"
  type        = number
  default     = 2000
}
