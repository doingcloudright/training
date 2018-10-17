variable "name" {
  description = "The name"
}

variable "tags" {
  description = "Extra Tags"
  default     = {}
}

variable "vpc_id" {
  description = "The VPC ID"
}

variable "public_subnets" {
  description = "The public subnets, where the loadbalancer should reside"
  default     = []
}

variable "private_subnets" {
  description = "The private subnets, where the loadbalancer should reside"
  default     = []
}

variable "user_data" {
  description = "The cloud init user-data for the instance"
}
