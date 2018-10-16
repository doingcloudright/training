resource "aws_security_group" "instance" {
  vpc_id      = "${var.vpc_id}"
  name_prefix = "${var.name}-instance-sg"

  tags {
    Name = "tf-web-incoming"
  }
}

resource "aws_security_group_rule" "allow_access_out_instance" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.instance.id}"
}

resource "aws_security_group_rule" "allow_http_instance" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.instance.id}"
}

data "aws_ami" "bitnami" {
  filter {
    name   = "name"
    values = ["bitnami-nginx-1.14.0-1-linux-debian-9-x86_64-hvm-ebs"]
  }

  owners = ["979382823631"] # bitnami
}

resource "aws_instance" "this" {
  ami                    = "${data.aws_ami.bitnami.id}"
  instance_type          = "t2.micro"
  user_data              = "${var.user_data}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  associate_public_ip_address = "true"

  tags {
    Name = "${var.name}"
  }
}
