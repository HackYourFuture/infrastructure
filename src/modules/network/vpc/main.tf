variable "cidr_block" {
  type = "string"
}

variable "eks_cluster_name" {}

# Create a VPC to launch build instances into
resource "aws_vpc" "vpc_id" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  lifecycle {
    create_before_destroy = true
  }

  tags = "${
    map(
     "Name", "terraform-eks-${terraform.workspace}",
     "kubernetes.io/cluster/${var.eks_cluster_name}-${terraform.workspace}", "shared",
    )
  }"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "gw_id" {
  vpc_id = "${aws_vpc.vpc_id.id}"

  tags {
    Name = "${terraform.workspace}"
  }
}

# Create dhcp option setup
resource "aws_vpc_dhcp_options" "vpc_dhcp_id" {
  domain_name         = "us-west-2.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "${terraform.workspace}"
  }
}

output "vpc_id" {
  value = "${aws_vpc.vpc_id.id}"
}

output "vpc_cidr_block" {
  value = "${aws_vpc.vpc_id.cidr_block}"
}

output "gw_id" {
  value = "${aws_internet_gateway.gw_id.id}"
}

output "main_route_table_id" {
  value = "${aws_vpc.vpc_id.main_route_table_id}"
}

output "vpc_dhcp_id" {
  value = "${aws_vpc_dhcp_options.vpc_dhcp_id.id}"
}