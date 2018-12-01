variable "security_group_ids" {
  type = "list"
  description = "The security group for the bastion"
  default = []
}

resource "aws_rds_cluster" "default" {
  cluster_identifier = "hyf-db-cluster"
  engine = "aurora"
  database_name = "hyf"
  master_username = "hack"
  master_password = "hackyourfuture"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  engine_mode = "serverless"
  vpc_security_group_ids = ["${split(",", join(",", var.security_group_ids))}"]
}

output "endpoint" {
  value = "${aws_rds_cluster.default.endpoint}"
}
