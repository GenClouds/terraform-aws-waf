variable "defaults" {
  description = "Map of default values which will be used for each wrapped WAF configuration."
  type        = any
  default     = {}
}

variable "items" {
  description = "Map of WAF configurations to create via the wrapper. Values are passed through to the root module."
  type        = any
  default     = {}
}

