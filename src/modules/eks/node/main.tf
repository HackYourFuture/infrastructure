variable "eks_cluster_name" {
  description = "cluster name"
}

variable "eks_certificate_authority" {
  description = "eks certificate authority"
}

variable "eks_endpoint" {
  description = "eks cluster endpoint"
}

variable "iam_instance_profile" {
  description = "eks instance profile name"
}

variable "security_group_node" {
  description = "eks security group name"
}

variable "subnets" {
  type = "list"
}
data "aws_region" "current" {
    name = "eu-west-1"
}

data "aws_ami" "eks-node" {
  filter {
    name   = "name"
    values = ["amazon-eks-*"]
  }
  most_recent = true
}

data "template_file" "user_data" {
  template = "${file("${path.module}/userdata.tpl")}"

  vars {
    eks_certificate_authority = "${var.eks_certificate_authority}"
    eks_endpoint              = "${var.eks_endpoint}"
    eks_cluster_name          = "${var.eks_cluster_name}"
	workspace 				  = "${terraform.workspace}"
    aws_region_current_name 	= "${data.aws_region.current.name}"
  }
}

resource "null_resource" "export_rendered_template" {
	provisioner "local-exec" {
	command = "cat > /data_output.sh <<EOL\n${data.template_file.user_data.rendered}\nEOL"
	}
}

resource "aws_launch_configuration" "terra" {
  associate_public_ip_address = true
  iam_instance_profile        = "${var.iam_instance_profile}"
  image_id                    = "${data.aws_ami.eks-node.id}"
  instance_type               = "m5.large"
  spot_price                  = "0.001"
  name_prefix                 = "terraform-eks"
  key_name                    = "test_access"
  security_groups             = ["${var.security_group_node}"]
  user_data 				  = "${data.template_file.user_data.rendered}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "terra" {
  desired_capacity     = 1
  launch_configuration = "${aws_launch_configuration.terra.id}"
  max_size             = 2
  min_size             = 1
  name                 = "terraform-eks"
  vpc_zone_identifier  = ["${var.subnets}"]

  tag {
    key                 = "Name"
    value               = "terraform-eks"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.eks_cluster_name}-${terraform.workspace}"
    value               = "owned"
    propagate_at_launch = true
  }
}

// output "node_ip" {
//  value = "${join(", ", aws_instance.tf_server.*.public_ip)}"
// }