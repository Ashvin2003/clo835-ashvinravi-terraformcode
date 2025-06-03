variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public Subnet IP"
  type        = string
  default     = "10.10.1.0/24"
}