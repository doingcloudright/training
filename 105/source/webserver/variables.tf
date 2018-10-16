variable "name" {
  description = "The name"
}

variable "vpc_id" {
  description = "The VPC ID"
}

variable "subnet_id" {
  description = "The subnet this instance is placed in"
}

variable "user_data" {
  description = "The cloud init user-data for the instance"
}
