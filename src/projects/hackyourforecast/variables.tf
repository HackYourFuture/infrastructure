 
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

variable "cidr_block" {
  description = "CIDR for the whole VPC"
  default = "10.10.0.0/16"
}

variable "eks_cluster_name" {
  description = "cluster name"
  default     = "terra"
}

variable "identifier" {
  description = "Identifier for DB"
  default     = "terra-db"
}

variable "storage_type" {
  description = "Type of the storage ssd or magnetic"
  default     = "gp2"
}

variable "allocated_storage" {
  description = "ammount of storage allocated in GB"
  default = "5"
}

variable "db_engine" {
  description = " DB engine"
  default     = "postgres"
}

variable "engine_version" {
  description = "DB engine version"
  default     = "9.6.6"
}

variable "instance_class" {
  description = "mashine type to be used"
  default = "db.t2.micro"
}

variable "db_username" {
  description = "db admin user"
  default     = "root"
}

variable "db_password" {
  description = "password, provide through your tfvars file"
  default = "h4ckf0r3c4st!"
}