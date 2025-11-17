variable "ami_owner" {
  type        = list(string)
  description = "Instance AMI"
  default     = ["amazon"]
}

variable "ami_name_filter" {
  type        = list(string)
  description = "Name pattern of the AMI"
  default     = ["amzn2-ami-hvm-*-x86_64-gp2"]
}

variable "ami_architecture" {
  type        = list(string)
  description = "Architecture of the AMI"
  default     = ["x86_64"]
}

variable "instance_type" {
  type        = string
  description = "Instance Type"
  default     = "t2.micro"
}

variable "instance_name" {
  type        = string
  description = "Instance Name"
  default     = "Instance"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where the instance will be launched"
}

variable "inbound" {
  type = map(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
  }))
  description = "role for inbound traffic"
  default     = {}
}

variable "outbound" {
  type = map(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
  }))
  description = "role for outbound traffic"
  default     = {}
}

variable "vpc_id" {
  type    = string
  default = "vpc id"
}

variable "user_data" {
  type        = string
  description = "user data of instance"
}

variable "extra_tags" {
  type        = map(string)
  description = "Extra tags"
  default     = {}
}

variable "backend_private_ip" {
  description = "Private IP of backend instance"
  type        = string
  default     = ""
}