variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "alb_arns" {
  description = "List of Application Load Balancer ARNs to associate with the Web ACL"
  type        = list(string)
  default     = []
}

variable "blocked_ip_cidrs" {
  description = "List of IP CIDR blocks to block"
  type        = list(string)
  default     = ["192.0.2.0/24", "198.51.100.0/24"]
}

variable "rate_limit" {
  description = "Maximum number of requests per 5 minutes per IP for rate-based rule"
  type        = number
  default     = 2000
}
