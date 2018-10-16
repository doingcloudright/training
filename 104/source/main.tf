module "vpc" {
  source             = "./vpc"
  network_name       = "${var.network_name}"
  network            = "${var.network}"
  public_subnets     = ["${var.public_subnets}"]
  private_subnets    = ["${var.private_subnets}"]
  availability_zones = ["${var.availability_zones}"]
}
