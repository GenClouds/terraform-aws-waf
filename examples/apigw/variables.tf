variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "api_gateway_stage_arns" {
  description = "List of API Gateway stage ARNs to associate with the Web ACL (e.g., arn:aws:apigateway:region::/restapis/api-id/stages/stage-name)"
  type        = list(string)
  default     = []
}

variable "blocked_countries" {
  description = "List of country codes to block (ISO 3166-1 alpha-2)"
  type        = list(string)
  default     = ["CN", "RU"]
}

variable "rate_limit" {
  description = "Maximum number of requests per 5 minutes per IP"
  type        = number
  default     = 2000
}
