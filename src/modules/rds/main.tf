variable "subnets" {
  type = "list"
}

variable "identifier" {}

variable "storage_type" {}

variable "allocated_storage" {
  type = "string"
}

variable "db_engine" {}

variable "engine_version" {}

variable "instance_class" {
  type = "string"
}

variable "db_username" {}

variable "db_password" {}

variable "sec_grp_rds" {}

data "aws_availability_zones" "available" {}

resource "aws_db_subnet_group" "db_sub_gr" {
  description = "terrafom db subnet group"
  name        = "main_subnet_group"
  subnet_ids  = ["${var.subnets}"]

  #  subnet_ids = [
  #    "${var.api_dev_int_subnet_ids}"]
  tags {
    Name = "${terraform.workspace}"
  }
}

resource "aws_db_instance" "db" {
  identifier        = "${var.identifier}"
  storage_type      = "${var.storage_type}"
  allocated_storage = "${var.allocated_storage}"
  engine            = "${var.db_engine}"
  engine_version    = "${var.engine_version}"
  instance_class    = "${var.instance_class}"
  name              = "${terraform.workspace}"
  username          = "${var.db_username}"
  password          = "${var.db_password}"

  vpc_security_group_ids = [
    "${var.sec_grp_rds}",
  ]

  db_subnet_group_name = "${aws_db_subnet_group.db_sub_gr.id}"
  storage_encrypted    = false
  skip_final_snapshot  = true
  publicly_accessible  = false
  multi_az             = false

  tags {
    Name = "${terraform.workspace}"
  }
}

output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = "${element(concat(aws_db_subnet_group.db_sub_gr.*.id, list("")), 0)}"
}

output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = "${element(concat(aws_db_subnet_group.db_sub_gr.*.arn, list("")), 0)}"
}

/*
output "db_instance_id" {
  value = "${aws_db_instance.db.id}"
}
output "db_instance_address" {
  value = "${aws_db_instance.db.address}"
}
*/
locals {
  db_instance_address           = "${element(concat(coalescelist(aws_db_instance.db.*.address, aws_db_instance.this.*.address), list("")), 0)}"
  db_instance_arn               = "${element(concat(coalescelist(aws_db_instance.db.*.arn, aws_db_instance.this.*.arn), list("")), 0)}"
  db_instance_availability_zone = "${element(concat(coalescelist(aws_db_instance.db.*.availability_zone, aws_db_instance.this.*.availability_zone), list("")), 0)}"
  db_instance_endpoint          = "${element(concat(coalescelist(aws_db_instance.db.*.endpoint, aws_db_instance.this.*.endpoint), list("")), 0)}"
  db_instance_hosted_zone_id    = "${element(concat(coalescelist(aws_db_instance.db.*.hosted_zone_id, aws_db_instance.this.*.hosted_zone_id), list("")), 0)}"
  db_instance_id                = "${element(concat(coalescelist(aws_db_instance.db.*.id, aws_db_instance.this.*.id), list("")), 0)}"
  db_instance_resource_id       = "${element(concat(coalescelist(aws_db_instance.db.*.resource_id, aws_db_instance.this.*.resource_id), list("")), 0)}"
  db_instance_status            = "${element(concat(coalescelist(aws_db_instance.db.*.status, aws_db_instance.this.*.status), list("")), 0)}"
  db_instance_name              = "${element(concat(coalescelist(aws_db_instance.db.*.name, aws_db_instance.this.*.name), list("")), 0)}"
  db_instance_username          = "${element(concat(coalescelist(aws_db_instance.db.*.username, aws_db_instance.this.*.username), list("")), 0)}"
  db_instance_password          = "${element(concat(coalescelist(aws_db_instance.db.*.password, aws_db_instance.this.*.password), list("")), 0)}"
  db_instance_port              = "${element(concat(coalescelist(aws_db_instance.db.*.port, aws_db_instance.this.*.port), list("")), 0)}"
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = "${local.db_instance_address}"
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = "${local.db_instance_arn}"
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = "${local.db_instance_availability_zone}"
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = "${local.db_instance_endpoint}"
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = "${local.db_instance_hosted_zone_id}"
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = "${local.db_instance_id}"
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = "${local.db_instance_resource_id}"
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = "${local.db_instance_status}"
}

output "db_instance_name" {
  description = "The database name"
  value       = "${local.db_instance_name}"
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = "${local.db_instance_username}"
}

output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = "${local.db_instance_password}"
}

output "db_instance_port" {
  description = "The database port"
  value       = "${local.db_instance_port}"
}