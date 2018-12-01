variable "vpc_id" {
  type = "string"
  description = "VPC id"
}

resource "aws_security_group" "db-sg" {
  name = "hyf-db"

  description = "RDS Main Aurora subnet"
  vpc_id = "${var.vpc_id}"

  # Only postgres in
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Bastion
resource "aws_security_group" "bastion-sg" {
  name   = "bastion-security-group"
  vpc_id = "${var.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "bastion_sg_id" {
  value = "${aws_security_group.bastion-sg.id}"
}

output "db_sg_id" {
  value = "${aws_security_group.db-sg.id}"
}
