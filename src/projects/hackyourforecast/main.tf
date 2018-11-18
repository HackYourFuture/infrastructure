## Network
# Create VPC
module "vpc" {
  source           = "./../../modules/network/vpc"
  eks_cluster_name = "${var.eks_cluster_name}"
  cidr_block       = "${var.cidr_block}"
}

# Create Subnets
module "subnets" {
  source           = "./../../modules/network/subnets"
  eks_cluster_name = "${var.eks_cluster_name}"
  vpc_id           = "${module.vpc.vpc_id}"
  vpc_cidr_block   = "${module.vpc.vpc_cidr_block}"
}

# Configure Routes
module "route" {
  source              = "./../../modules/network/route"
  main_route_table_id = "${module.vpc.main_route_table_id}"
  gw_id               = "${module.vpc.gw_id}"

  subnets = [
    "${module.subnets.subnets}",
  ]
}

module "eks_roles" {
  source = "./../../modules/eks/roles"
}

module "eks_sec_group" {
  source           = "./../../modules/eks/sec_group"
  eks_cluster_name = "${var.eks_cluster_name}"
  vpc_id           = "${module.vpc.vpc_id}"
}

module "eks_cluster" {
  source           = "./../../modules/eks/cluster"
  eks_cluster_name = "${var.eks_cluster_name}"
  iam_cluster_arn  = "${module.eks_roles.iam_cluster_arn}"
  iam_node_arn     = "${module.eks_roles.iam_node_arn}"

  subnets = [
    "${module.subnets.subnets}",
  ]

  security_group_cluster = "${module.eks_sec_group.security_group_cluster}"
}

module "eks_node" {
  source                    = "./../../modules/eks/node"
  eks_cluster_name          = "${var.eks_cluster_name}"
  eks_certificate_authority = "${module.eks_cluster.eks_certificate_authority}"
  eks_endpoint              = "${module.eks_cluster.eks_endpoint}"
  iam_instance_profile      = "${module.eks_roles.iam_instance_profile}"
  security_group_node       = "${module.eks_sec_group.security_group_node}"

  subnets = [
    "${module.subnets.subnets}",
  ]
}

module "sec_group_rds" {
  source         = "./../../modules/network/sec_group"
  vpc_id         = "${module.vpc.vpc_id}"
  vpc_cidr_block = "${module.vpc.vpc_cidr_block}"
} 


module "rds" {
  source = "./../../modules/rds"

  subnets = [
    "${module.subnets.subnets}",
  ]

  sec_grp_rds       = "${module.sec_group_rds.sec_grp_rds}"
  identifier        = "${var.identifier}"
  storage_type      = "${var.storage_type}"
  allocated_storage = "${var.allocated_storage}"
  db_engine         = "${var.db_engine}"
  engine_version    = "${var.engine_version}"
  instance_class    = "${var.instance_class}"
  db_username       = "${var.db_username}"
  db_password       = "${var.db_password}"
  sec_grp_rds       = "${module.sec_group_rds.sec_grp_rds}"
}