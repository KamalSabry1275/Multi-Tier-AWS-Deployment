variable "name_prefix" {
  type        = string
  description = "Name prefix for resources"
  default     = "iti"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.42.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnet"
  default     = ["10.42.1.0/24", "10.42.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for private subnet"
  default     = ["10.42.3.0/24", "10.42.4.0/24"]
}

variable "create_nat_per_az" {
  type        = bool
  description = "Create NAT for each AZ (true) or single NAT (false)"
  default     = false
}

variable "extra_tags" {
  type        = map(string)
  description = "Extra tags"
  default     = {}
}
