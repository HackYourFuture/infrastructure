variable "vpc_cidr_block" {
  #	type = "map"
}

variable "vpc_id" {}

resource "aws_security_group" "sec_grp_rds" {
  name        = "rds"
  description = "rds securety group"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // This could be a specific a idr block
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // eg: "${var.vpc_cidr_block}"
  }

  tags {
    Name = "${terraform.workspace}"
  }

}
output "sec_grp_rds" {
  value = "${aws_security_group.sec_grp_rds.id}"
}