# We create the bucket here
resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "${var.name}"

  # https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl
  acl = "private"

  force_destroy = true // Allows us to remove the bucket easily at the end of the tutorial

  # We keep versioning disabled, for production use, enabling versioning is best practice
  # versioning {
  #  enabled = true
  # }
}

# Policy Document to allow S3 Read-Write Access to given paths
data "aws_iam_policy_document" "bucket_s3_all_permissions" {
  # We need to give access to list the buckets, in this case, list buckets will only return one bucket
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.bucket.arn}"]
  }

  # s3:* mean that all s3 actions will be allowed
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]
  }
}

# Trust Policy
data "aws_iam_policy_document" "ec2_instance_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Creation of the role
resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "${var.name}-ec2-bucket-access"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_instance_trust_policy.json}"
}

resource "aws_iam_role_policy" "this" {
  # Name is optional, please test with and without
  # name = "this_is_not_mandatory"
  role = "${aws_iam_role.ec2_s3_access_role.id}"

  policy = "${data.aws_iam_policy_document.bucket_s3_all_permissions.json}"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-instance-profile"
  role = "${aws_iam_role.ec2_s3_access_role.id}"
}

## Security Groups
resource "aws_security_group" "loadbalancer" {
  vpc_id      = "${var.vpc_id}"
  name_prefix = "${var.name}-loadbalancer-sg"

  tags {
    Name = "tf-lb-incoming"
  }
}

resource "aws_security_group_rule" "allow_lb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.loadbalancer.id}"
}

resource "aws_security_group_rule" "allow_lb_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.loadbalancer.id}"
}

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

resource "aws_security_group_rule" "allow_ssh_instance" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.instance.id}"
}

resource "aws_security_group_rule" "allow_http_instance" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.loadbalancer.id}"
  security_group_id        = "${aws_security_group.instance.id}"
}

## Load Balancing
resource "aws_lb" "this" {
  name_prefix        = "${substr(var.name, 0 , 6)}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.loadbalancer.id}"]
  subnets            = ["${var.lb_subnets}"]

  enable_deletion_protection = false

  tags = "${var.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "this" {
  name_prefix = "${substr(var.name, 0 , 6)}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  tags        = "${var.tags}"
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = "${aws_lb.this.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.this.arn}"
    type             = "forward"
  }
}

data "aws_ami" "bitnami" {
  filter {
    name   = "name"
    values = ["bitnami-nginx-1.14.0-1-linux-debian-9-x86_64-hvm-ebs"]
  }

  owners = ["979382823631"] # bitnami
}

data "template_file" "init" {
  template = "${file("${path.module}/cloud_init.init")}"

  vars {
    bucket_name = "${aws_s3_bucket.bucket.id}"
  }
}

## Creating Launch Configuration
resource "aws_launch_configuration" "this" {
  image_id                    = "${data.aws_ami.bitnami.id}"
  instance_type               = "t2.micro"
  iam_instance_profile        = "${aws_iam_instance_profile.this.arn}"
  security_groups             = ["${aws_security_group.instance.id}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"

  key_name = "${var.key_name}"

  user_data = "${data.template_file.init.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  launch_configuration = "${aws_launch_configuration.this.id}"
  min_size             = 1
  max_size             = 1
  target_group_arns    = ["${aws_lb_target_group.this.arn}"]
  health_check_type    = "ELB"
  vpc_zone_identifier  = ["${var.instance_subnets}"]

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}
