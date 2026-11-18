# Provider configurations
variable "primary_region" {
  description = "Primary region for DR architecture"
  type        = string
  default     = "cn-north-4"
}

variable "dr_region" {
  description = "DR region for failover"
  type        = string
  default     = "cn-east-3"
}

variable "stack_name" {
  description = "Resource name prefix"
  type        = string
  default     = "dr-eks"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}
