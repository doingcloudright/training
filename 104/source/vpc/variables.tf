variable "network_name" {
  description = "What is the name of the network"
}

variable "network" {
  description = "CIDR of the network"
}

variable "availability_zones" {
  type        = "list"
  description = "Which availability zones do we map our subnets to"
}

variable "public_subnets" {
  type        = "list"
  description = "CIDRs of the public subnet"
}

variable "private_subnets" {
  type        = "list"
  description = "CIDRs of the private subnet"
}
