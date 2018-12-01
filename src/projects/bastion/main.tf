variable "security_group_ids" {
  type = "list"
  description = "The security group for the bastion"
  default = []
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "mauro"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAOpYrGg08Y56XAa2cRu4BIKUOexg9kvIdB32H0E3xAf0dWS05KCgLJo0mpteD0sHKvK8tjAR+UYlaPRzDnHSK+uZV18ePambksrwVPVelnYRFQKY3yOuYOy2Gghd8fUeOU6H4TnhaBjbfWxA3RQSFiilnTLMqJWiT145SfZz2KsMotUCvLFAPaewocVMktmQKVqpwnP8g1YFAcfsIYDijMo/OUSJu+D2qrJ+zOVsuBHkqx1QFpc/ltMTIzmQijhq3awIa85bWXnaLTdYVbFAujggNIC7cZETsRBJmNxZ6Xm9W7OOUYOEbVOSsVkB0527DrXicN7L6eILiIzEQJxD/ mauro.mandracchia@gmail.com"
}

resource "aws_instance" "bastion" {
  ami = "ami-0233214e13e500f77"
  key_name = "${aws_key_pair.bastion_key.key_name}"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${split(",", join(",", var.security_group_ids))}"]
  associate_public_ip_address = true
}

output "ip" {
  value = "${aws_instance.bastion.public_ip}"
}


output "dns" {
  value = "${aws_instance.bastion.public_dns}"
}
