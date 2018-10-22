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

variable "lb_subnets" {
  description = "The public subnets, where the loadbalancer should reside"
  type        = "list"
  default     = []
}

variable "instance_subnets" {
  description = "The private subnets, where the loadbalancer should reside"
  type        = "list"
  default     = []
}

variable "key_name" {
  description = "The SSH KEY reference"
  type        = "string"
}

variable "associate_public_ip_address" {
  description = "Do we want to have a public IP for this instance"
  default     = false
}
