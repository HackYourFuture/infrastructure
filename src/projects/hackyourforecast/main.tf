variable "security_group_ids" {
  type = "list"
  description = "The security group for the instance"
  default = []
}

variable "vpc_id" {
  type = "string"
  description = "VPC id"
}

resource "aws_security_group" "instance-sg" {
  name   = "instance-security-group"
  vpc_id = "${var.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 5000
    to_port     = 5000
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
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

resource "aws_key_pair" "instance_key" {
  key_name   = "hackyourforecast-mauro"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAOpYrGg08Y56XAa2cRu4BIKUOexg9kvIdB32H0E3xAf0dWS05KCgLJo0mpteD0sHKvK8tjAR+UYlaPRzDnHSK+uZV18ePambksrwVPVelnYRFQKY3yOuYOy2Gghd8fUeOU6H4TnhaBjbfWxA3RQSFiilnTLMqJWiT145SfZz2KsMotUCvLFAPaewocVMktmQKVqpwnP8g1YFAcfsIYDijMo/OUSJu+D2qrJ+zOVsuBHkqx1QFpc/ltMTIzmQijhq3awIa85bWXnaLTdYVbFAujggNIC7cZETsRBJmNxZ6Xm9W7OOUYOEbVOSsVkB0527DrXicN7L6eILiIzEQJxD/ mauro.mandracchia@gmail.com"
}

resource "aws_instance" "instance" {
  ami = "ami-0233214e13e500f77"
  key_name = "${aws_key_pair.instance_key.key_name}"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${split(",", join(",", concat(var.security_group_ids, list(aws_security_group.instance-sg.id))))}"]
  associate_public_ip_address = true
}

output "ip" {
  value = "${aws_instance.instance.public_ip}"
}


output "dns" {
  value = "${aws_instance.instance.public_dns}"
}
