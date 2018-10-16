module "vpc" {
  source             = "./vpc"
  network_name       = "${var.network_name}"
  network            = "${var.network}"
  public_subnets     = ["${var.public_subnets}"]
  private_subnets    = ["${var.private_subnets}"]
  availability_zones = ["${var.availability_zones}"]
}

module "webserver" {
  source    = "./webserver"
  name      = "webserver"
  vpc_id    = "${module.vpc.vpc_id}"
  subnet_id = "${element(module.vpc.public_subnets_ids, 0)}"
  user_data = "${file("${path.module}/cloud_init.init")}"
}
